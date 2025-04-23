# CI/CD Workflows

## ファイル構成

- **`ci-cd-pipeline.yml`** メインとなる統合CI/CDパイプラインですPull Request作成時やmain/masterブランチへのプッシュ時にトリガーされ、後述の他のワークフローを順次実行します
- **`code-quality.yml`** コード品質チェック（Dart format, Dart analyze）を実行します
- **`flutter-test.yml`** Flutterアプリのテスト（ユニットテスト、ウィジェットテスト）を実行し、JUnitレポートを生成します
- **`test-reporter.yml`** テスト結果のレポートを作成し、PRにコメントします
- **`copilot-review.yml`** GitHub CopilotによるPRレビューを自動化します
- **`build-for-production.yml`** 本番用（または開発用）のAndroid (APK/App Bundle) および iOS (IPA) ビルドを実行します
- **`notify-completion.yml`** パイプライン全体の実行結果を要約し、Pull Requestに通知コメントを投稿します

## 機能詳細

### `ci-cd-pipeline.yml`

このワークフローが、パイプライン全体の流れを管理しますトリガー（Push, Pull Request, 手動実行）に応じて、以下のワークフロー（ジョブ）を適切な順序と条件で実行します

1.  **`format-and-analyze` (using `code-quality.yml`)** コード品質をチェックします
2.  **`test` (using `flutter-test.yml`)** テスト（ユニット/ウィジェット）を行います
3.  **`report` (using `test-reporter.yml`)** テスト結果をレポートします (Pull Request時のみ、`test` ジョブ完了後)
4.  **`review` (using `copilot-review.yml`)** GitHub Copilotによる自動レビューを実施します (Pull Request時のみ、`test` ジョブ成功後)
5.  **`release-build` (using `build-for-production.yml`)** 本番用ビルドを生成します (`format-and-analyze`, `test` ジョブが全て成功した場合)
6.  **`notify` (using `notify-completion.yml`)** パイプラインの全ジョブ完了後 (常に実行)、各ジョブの最終ステータスと成果物へのリンクを含む要約コメントをPull Requestに投稿または更新します

### `flutter-test.yml`

`ci-cd-pipeline.yml` の `test` ジョブから呼び出され、主に以下のステップを実行します

1. **Setup** Flutter環境をセットアップし、依存関係をインストールし、`build_runner` を実行します
2. **Testing**
   - `flutter test --machine` を実行して `test/unit_test` および `test/widget_test` 内のテストを実行します
   - 各テストタイプの出力を `junitreport` パッケージ経由で `ci-outputs/test-results/.../junit.xml` として保存します
3. **Result Calculation** ステップの実行結果とJUnitレポート内の失敗/エラー数を基に最終的な成功/失敗を決定します
4. **Artifacts** 生成されたJUnitレポート (`ci-unit-test-results-junit`, `ci-widget-test-results-junit`) をアップロードします

### `code-quality.yml`

`ci-cd-pipeline.yml` の `format-and-analyze` ジョブから呼び出され、コード品質に関するチェックを行います

-   Flutter環境をセットアップし、`build_runner` を実行します
-   `dart format --set-exit-if-changed .` でフォーマットをチェックします
-   `dart analyze` で静的解析を実行します
-   フォーマットやLintに違反があれば、ワークフローを失敗させ、エラーメッセージを出力します

### `test-reporter.yml`

`ci-cd-pipeline.yml` の `report` ジョブから呼び出され (Pull Request時のみ)、`flutter-test.yml` で生成されたテスト結果ファイルを処理します

-   `ci-unit-test-results-junit` および `ci-widget-test-results-junit` アーティファクトをダウンロードします
-   `mikepenz/action-junit-report` アクションを使用して、JUnitレポートをGitHub Checks API (`Flutter Test Suite Results` という名前) に公開します
-   JUnitレポートを解析し、テスト結果のサマリー (`✅ 全ての...`, `❌ ...件が失敗しました`, `⚠️ ...`) を作成します
-   Pull Requestにテスト結果のサマリーと「チェックタブで利用可能です」というテキストを含むコメント (`<!-- flutter-test-report -->`) を投稿または更新します

### `copilot-review.yml`

`ci-cd-pipeline.yml` の `review` ジョブから呼び出され (Pull Request時、テスト成功時のみ)、GitHub Copilotによる自動コードレビューを実行します

-   GitHub Copilot (`copilot`) をレビュアーとして追加し、PRの自動レビューを依頼します
-   レビュアー追加に失敗した場合、リポジトリの設定でGitHub Copilotコードレビュー機能が有効になっているか確認を促す日本語のコメントをPRに追加します

### `build-for-production.yml`

`ci-cd-pipeline.yml` の `release-build` ジョブから呼び出され (先行ジョブ成功時のみ)、本番リリース向けのビルドを実行します

-   **Android** `flutter build appbundle --release` と `flutter build apk --release --split-per-abi` を使用して、リリース用のApp Bundle (.aab) とAPK (.apk) をビルドします (署名設定は現在コメントアウト)ビルド成果物を `ci-outputs/build/android/` 以下に移動し、`ci-android-bundle` と `ci-android-apks` という名前でアーティファクトとしてアップロードします
-   **iOS** `flutter build ipa --release --no-codesign` を使用して、リリース用のIPA (.ipa) をビルドします (現在コード署名は無効、`macos-latest` ランナーが必要)ビルド成果物を `ci-outputs/build/ios/` 以下に移動し、`ci-ios-ipa` という名前でアーティファクトとしてアップロードします
-   **GitHub Release** `release_tag` が指定された場合、ビルド成果物をダウンロードし、`softprops/action-gh-release` を使用してGitHub Releasesに**ドラフト**を作成し、生成されたビルドファイル (aab, apk, ipa) を添付します

### `notify-completion.yml`

`ci-cd-pipeline.yml` の `notify` ジョブから呼び出され (常に実行)、パイプラインの実行結果を要約します

-   Pull Requestの場合のみ動作します
-   先行する各ジョブ（Quality, Test, Report, Review, Prod Build）のステータス（成功 ✅, 失敗 ❌, スキップ ⏭️）を取得します
-   テストレポートのアーティファクト (`ci-unit-test-results-junit`, `ci-widget-test-results-junit`) へのリンクを生成します
-   Pull Requestに、各ジョブのステータスアイコン、テストレポートへのリンク、およびワークフロー実行へのリンクを含む要約コメント (`<!-- cicd-summary-pop-qr -->`) を投稿または更新します

## 使用方法

メインパイプライン (`ci-cd-pipeline.yml`) は以下のタイミングで自動実行されます

-   **プッシュ時** `main` または `master` ブランチへのプッシュ
-   **PR作成/更新時** `main` または `master` ブランチをターゲットとするPull Request
-   **手動実行** GitHub Actionsタブから `ci-cd-pipeline.yml` を選択して実行可能

個別のワークフローは通常、直接実行するのではなく、`ci-cd-pipeline.yml` によって呼び出されます

## ローカルでCIのワークフローをチェック

開発中に、GitHub Actions で実行される主要なチェック（フォーマット、静的解析、テスト）をローカルで事前に確認するためのスクリプトが用意されていますこれにより、PR を作成する前に問題を修正できます

初回実行前に、以下のコマンドでスクリプトに実行権限を付与してください
```shell
chmod +x .github/scripts/run-local-ci.sh
```

### ビルドを含む検証

ローカル環境でビルドからテストやアーカイブを実行し、CIワークフローで実行されるコアな処理が期待通りかを確認します

```shell
# 全てのステップ (ビルド、単体テスト実行・検証、UIテスト実行・検証、アーカイブビルド・検証) を実行
$ ./.github/scripts/run-local-ci.sh

# テスト用ビルド + 単体テストとUIテストの両方を実行・検証
$ ./.github/scripts/run-local-ci.sh --all-tests

# テスト用ビルド + 単体テストのみを実行・検証
$ ./.github/scripts/run-local-ci.sh --unit-test

# テスト用ビルド + UIテストのみを実行・検証
$ ./.github/scripts/run-local-ci.sh --ui-test

# ビルド + アーカイブのみを実行・検証
$ ./.github/scripts/run-local-ci.sh --archive-only
```

## 技術仕様

-   主な実行環境 Ubuntu (大部分のジョブ), macOS (iOSビルド用)
-   Flutterバージョン 3.29.3 (ワークフロー内で指定)
-   テストレポート形式 JUnit XML (`junitreport` パッケージ使用)
-   リリース成果物 Android App Bundle (.aab), Android APK (.apk), iOS IPA (.ipa)
-   主要な出力ディレクトリ `ci-outputs/` (テスト結果、ビルド成果物)
-   アーティファクト保持期間 7日

