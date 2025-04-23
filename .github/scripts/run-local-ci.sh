# =======================
# このスクリプトは、CIで行われる主要なチェック (フォーマット、静的解析、テスト、ビルド、アーカイブ) をローカルで実行します。
# PR作成前に問題を検出するのに役立ちます。
#
#   ./.github/scripts/run-local-ci.sh                   # 全てのデフォルトステップ (フォーマット、解析、デバッグビルド、単体テスト、アーカイブ)
#   ./.github/scripts/run-local-ci.sh --all-tests       # デバッグビルド + 単体/UIテスト
#   ./.github/scripts/run-local-ci.sh --unit-test       # デバッグビルド + 単体テスト
#   ./.github/scripts/run-local-ci.sh --ui-test         # デバッグビルド + UIテスト
#   ./.github/scripts/run-local-ci.sh --archive-only    # リリースビルド (APK/AAB/IPA)
# =======================

#!/bin/bash
set -e

# === Log Functions ===
step() {
  echo ""
  echo "──────────────────────────────────────────────────────────────────────"
  echo "▶️  $1"
  echo "──────────────────────────────────────────────────────────────────────"
}

success() {
  echo "✅ $1"
}

fail() {
  echo "❌ Error: $1"
  exit 1
}

# === Argument Parsing ===
RUN_PUB_GET=true
RUN_BUILD_RUNNER=true
RUN_FORMAT=true
RUN_ANALYZE=true
RUN_UNIT_TEST=false
RUN_UI_TEST=false
RUN_BUILD_DEBUG=false
RUN_ARCHIVE=false
TEST_WITHOUT_BUILDING=false
BUILD_FOR_TESTING=false

# デフォルト: 引数がない場合は、すべての標準チェックを実行
if [ $# -eq 0 ]; then
  RUN_UNIT_TEST=true
  RUN_BUILD_DEBUG=true
  # RUN_ARCHIVE=true # アーカイブは一般的ではないため、デフォルトでは実行しない
else
  # 引数を解析
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      --all-tests)
        RUN_UNIT_TEST=true
        RUN_UI_TEST=true
        BUILD_FOR_TESTING=true
        shift
        ;;
      --unit-test)
        RUN_UNIT_TEST=true
        BUILD_FOR_TESTING=true # テストにはビルドが必要
        shift
        ;;
      --ui-test)
        RUN_UI_TEST=true
        BUILD_FOR_TESTING=true # テストにはビルドが必要
        shift
        ;;
      --archive-only)
        RUN_ARCHIVE=true
        # アーカイブのみの場合でも基本的なチェックが行われることを確認
        # RUN_FORMAT=true
        # RUN_ANALYZE=true
        shift
        ;;
      --test-without-building)
        TEST_WITHOUT_BUILDING=true
        RUN_PUB_GET=false # 依存関係は取得済みと仮定
        RUN_BUILD_RUNNER=false # コード生成は完了済みと仮定
        RUN_FORMAT=false # チェックをスキップ
        RUN_ANALYZE=false # チェックをスキップ
        RUN_BUILD_DEBUG=false # ビルドをスキップ
        RUN_ARCHIVE=false # アーカイブをスキップ
        # どのテストを実行するかを知る必要がある
        # これと一緒に特定のテストフラグが指定されていない場合は、すべてを実行
        if [[ ! "$*" =~ "--unit-test" ]] && [[ ! "$*" =~ "--ui-test" ]]; then
             RUN_UNIT_TEST=true
             RUN_UI_TEST=true
        fi
        shift
        ;;
      *)    # 不明なオプション
        echo "Unknown option: $1"
        echo "Usage: $0 [--all-tests] [--unit-test] [--ui-test] [--archive-only] [--test-without-building]"
        exit 1
        ;;
    esac
  done
fi

# === Execution Steps ===

# --- Prerequisites ---
if [ "$RUN_PUB_GET" = true ]; then
  step "Running flutter pub get"
  flutter pub get || fail "flutter pub get failed"
fi

if [ "$RUN_BUILD_RUNNER" = true ]; then
  step "Running build_runner"
  flutter pub run build_runner build --delete-conflicting-outputs || fail "build_runner failed"
fi

# --- Code Quality ---
if [ "$RUN_FORMAT" = true ]; then
  step "Checking dart format"
  dart format --set-exit-if-changed . || fail "dart format check failed"
fi

if [ "$RUN_ANALYZE" = true ]; then
  step "Running dart analyze"
  dart analyze || fail "dart analyze failed"
fi

# --- Building ---
# テストまたはアーカイブに必要で、ビルドをスキップしない場合にのみビルド
if { [ "$BUILD_FOR_TESTING" = true ] || [ "$RUN_ARCHIVE" = true ] || [ "$RUN_BUILD_DEBUG" = true ]; } && [ "$TEST_WITHOUT_BUILDING" = false ]; then
    BUILD_NEEDED=true
else
    BUILD_NEEDED=false
fi

if [ "$BUILD_NEEDED" = true ]; then
    step "Building Debug Versions"
    flutter build apk --debug || fail "flutter build apk --debug failed"

    if [[ "$(uname)" == "Darwin" ]]; then
      step "Building iOS Debug Version for Simulator (macOS only)"
      flutter build ios --simulator --debug --no-codesign || fail "flutter build ios --debug failed"
      success "iOS Debug Build completed."
    else
      step "Skipping iOS debug build (not on macOS)."
    fi
else
    echo "ℹ️ Skipping Build step as it's not required by the selected options."
fi


# --- Testing ---
TESTS_TO_RUN=false
if [ "$RUN_UNIT_TEST" = true ] || [ "$RUN_UI_TEST" = true ]; then
    TESTS_TO_RUN=true
fi

if [ "$TESTS_TO_RUN" = true ]; then
    step "Running Tests"
    TEST_CMD="flutter test"

    # 実行するテストを選択
    TEST_PATHS=""
    if [ "$RUN_UNIT_TEST" = true ]; then
        TEST_PATHS="$TEST_PATHS test/unit_test" # 必要に応じてパスを調整
        echo "Including Unit Tests"
    fi
     if [ "$RUN_UI_TEST" = true ]; then
        TEST_PATHS="$TEST_PATHS test/widget_test" # UIテストがウィジェットテストまたはintegration_testにあると仮定
         echo "Including UI/Widget Tests"
         # UIテストがデバイス/シミュレーターを必要とする統合テストの場合:
         # TEST_CMD="flutter test integration_test" # 例
         # ビルドが行われたことを確認するか、統合テストのために`--test-without-building`を適切に処理
    fi

    if [ -z "$TEST_PATHS" ]; then
        echo "⚠️ No specific tests selected to run."
    else
         # テストを実行
        $TEST_CMD $TEST_PATHS || fail "flutter test execution failed"
        success "Tests completed."
    fi
else
    echo "ℹ️ Skipping Test step as it's not required by the selected options."
fi

# --- Archiving ---
# 要求され、ビルドをスキップしない場合にのみアーカイブを実行
if [ "$RUN_ARCHIVE" = true ] && [ "$TEST_WITHOUT_BUILDING" = false ]; then
  step "Running Archive Builds"
  flutter build appbundle --release || fail "flutter build appbundle failed"
  flutter build apk --release --split-per-abi || fail "flutter build apk --release failed"

  if [[ "$(uname)" == "Darwin" ]]; then
    step "Running flutter build ipa --release (macOS only)"
    flutter build ipa --release --no-codesign || fail "flutter build ipa failed"
  else
    step "Skipping iOS release build (not on macOS)."
  fi
  success "Archive builds completed."
elif [ "$RUN_ARCHIVE" = true ] && [ "$TEST_WITHOUT_BUILDING" = true ]; then
     echo "⚠️ Cannot run archive build with --test-without-building flag."
     # fail "Cannot run archive build with --test-without-building flag." # オプションで失敗させる
else
    echo "ℹ️ Skipping Archive step as it's not required by the selected options."
fi


# === Final Success Message ===
ALL_CHECKS_PASSED=true # 初期値は true と仮定
# 特定のステップが失敗したが終了しなかった場合（例：オプションのステップ）にチェックをここに追加

if [ "$ALL_CHECKS_PASSED" = true ]; then
    final_message="Local CI script finished successfully with selected options:"
    [ "$RUN_PUB_GET" = true ] && final_message="$final_message pub_get"
    [ "$RUN_BUILD_RUNNER" = true ] && final_message="$final_message build_runner"
    [ "$RUN_FORMAT" = true ] && final_message="$final_message format"
    [ "$RUN_ANALYZE" = true ] && final_message="$final_message analyze"
    [ "$BUILD_NEEDED" = true ] && final_message="$final_message build_debug"
    [ "$RUN_UNIT_TEST" = true ] && final_message="$final_message unit_test"
    [ "$RUN_UI_TEST" = true ] && final_message="$final_message ui_test"
    [ "$RUN_ARCHIVE" = true ] && [ "$TEST_WITHOUT_BUILDING" = false ] && final_message="$final_message archive"
    success "$final_message"
else
    fail "One or more selected steps failed."
fi 