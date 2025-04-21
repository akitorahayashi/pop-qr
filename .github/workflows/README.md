# CI/CD Workflows

このディレクトリには Pop QR アプリケーション用の GitHub Actions ワークフローファイルが含まれています。

## ファイル構成

- **`ci-cd-pipeline.yml`**: メインとなる統合CI/CDパイプラインです。Pull Request作成時やmain/masterブランチへのプッシュ時にトリガーされ、後述の他のワークフローを順次実行します。
- **`code-quality.yml`**: コード品質チェック（Dart format, Dart analyze）を実行します。
- **`flutter-test.yml`**: Flutterアプリのテスト（ユニットテスト、ウィジェットテスト）を実行し、JUnitレポートを生成します。
- **`test-reporter.yml`**: テスト結果のレポートを作成し、PRにコメントします。
- **`copilot-review.yml`**: GitHub CopilotによるPRレビューを自動化します。
- **`build-for-production.yml`**: 本番用（または開発用）のAndroid (APK/App Bundle) および iOS (IPA) ビルドを実行します。

## 機能詳細

### `ci-cd-pipeline.yml`

このワークフローが、パイプライン全体の流れを管理します。トリガー（Push, Pull Request, 手動実行）に応じて、以下のワークフローを適切な順序と条件で実行します。

1.  `code-quality.yml` を実行し、コード品質をチェックします。
2.  `flutter-test.yml` を実行し、テスト（ユニット/ウィジェット）を行います。
3.  `test-reporter.yml` を実行し、テスト結果をレポートします (Pull Request時のみ)。
4.  Pull Requestの場合、`copilot-review.yml` を実行し、GitHub Copilotによる自動レビューを実施します (テスト成功時のみ)。
5.  main/masterブランチへのPushの場合、`build-for-production.yml` を実行し、本番用ビルドを生成します (品質チェックとテスト成功時のみ)。
6.  最後に、パイプライン全体の完了ステータスをPull Requestにコメントします。

### `flutter-test.yml`

`ci-cd-pipeline.yml` から呼び出され、主に以下のステップを実行します:

1. **Setup**: Flutter環境をセットアップし、依存関係をインストールし、`build_runner` を実行します。
2. **Testing**:
   - `flutter test --machine` を実行して全てのユニットテストとウィジェットテストを実行します。
   - 出力を `junitreport` パッケージ経由で `ci-outputs/test-results/.../junit.xml` として保存します。
3. **Artifacts**: 生成されたJUnitレポート (`test-results-unit-junit`, `test-results-widget-junit`) をアップロードします。

### `code-quality.yml`

`ci-cd-pipeline.yml` から呼び出され、コード品質に関するチェックを行います:

-   Flutter環境をセットアップし、`build_runner` を実行します。
-   `dart format --set-exit-if-changed .` でフォーマットをチェックします。
-   `dart analyze` で静的解析を実行します。
-   フォーマットやLintに違反があれば、ワークフローを失敗させ、エラーメッセージを出力します。

### `test-reporter.yml`

`ci-cd-pipeline.yml` から呼び出され (Pull Request時のみ)、`flutter-test.yml` で生成されたテスト結果ファイルを処理します:

-   `ci-unit-test-results-junit` および `ci-widget-test-results-junit` アーティファクトをダウンロードし、`ci-outputs/test-results` 以下に展開します。
-   `mikepenz/action-junit-report` アクションを使用して、JUnitレポートをGitHub Checks APIに公開します。
-   JUnitレポートを解析し、テスト結果のサマリーを作成します。
-   Pull Requestにテスト結果のサマリー（✅ または ❌）とChecksタブへのリンクを含むコメントを投稿または更新します。

### `copilot-review.yml`

Pull Request時に `ci-cd-pipeline.yml` から呼び出され (テスト成功時のみ)、GitHub Copilotによる自動コードレビューを実行します:

-   GitHub Copilot (`copilot`) をレビュアーとして追加し、PRの自動レビューを依頼します。
-   レビュアー追加に失敗した場合、リポジトリの設定でGitHub Copilotコードレビュー機能が有効になっているか確認を促す日本語のコメントをPRに追加します。
-   GitHub Copilotによるレビューは、コードの品質向上や潜在的な問題の早期発見に役立ちます。

### `build-for-production.yml`

main/masterブランチへのPush時に `ci-cd-pipeline.yml` から呼び出され (品質チェックとテスト成功時のみ)、本番リリース向けのビルドを実行します:

-   **Android**: `flutter build appbundle --release` と `flutter build apk --release` を使用して、リリース用のApp Bundle (.aab) とAPK (.apk) をビルドします (署名設定は現在コメントアウト)。ビルド成果物を `ci-outputs/build/android/` 以下に移動し、`ci-android-bundle` と `ci-android-apks` という名前でアーティファクトとしてアップロードします。
-   **iOS**: `flutter build ipa --release` を使用して、リリース用のIPA (.ipa) をビルドします (現在コード署名は無効、macOSランナーが必要)。ビルド成果物を `ci-outputs/build/ios/` 以下に移動し、`ci-ios-ipa` という名前でアーティファクトとしてアップロードします。
-   **GitHub Release**: `release_tag` が指定された場合、ビルド成果物をダウンロードし、`softprops/action-gh-release` を使用してGitHub Releasesにドラフトを作成し、生成されたファイルを添付します。

## 使用方法

メインパイプライン (`ci-cd-pipeline.yml`) は以下のタイミングで自動実行されます:

-   **プッシュ時**: `main` または `master` ブランチへのプッシュ
-   **PR作成/更新時**: `main` または `master` ブランチをターゲットとするPull Request
-   **手動実行**: GitHub Actionsタブから `ci-cd-pipeline.yml` を選択して実行可能

個別のワークフローは通常、直接実行するのではなく、`ci-cd-pipeline.yml` によって呼び出されます。

## ローカルでのCIチェック実行

開発中に、GitHub Actions で実行される主要なチェック（フォーマット、静的解析、テスト）をローカルで事前に確認するためのスクリプトが用意されています。これにより、PR を作成する前に問題を修正できます。

**実行方法:**
以下のコマンドを実行します
```bash
$ .github/scripts/local-ci-check.sh
```

このスクリプトは以下の処理を実行します

- `flutter pub get`
- `flutter pub run build_runner build --delete-conflicting-outputs`
- `dart format --set-exit-if-changed .`
- `dart analyze`
- `flutter test`
- `flutter build apk --debug` (Androidのデバッグビルド確認)
- `flutter build ios --debug --no-codesign` (macOS環境の場合のみ、iOSのデバッグビルド確認)

スクリプトがエラーなく完了すれば、CI の主要なチェックは成功する可能性が高いです。

## 技術仕様

-   主な実行環境: Ubuntu (大部分のジョブ), macOS (iOSビルド用)
-   Flutterバージョン: 3.29.3 (ワークフロー内で指定)
-   テストレポート形式: JUnit XML (`junitreport` パッケージ使用)
-   リリース成果物: Android App Bundle (.aab), Android APK (.apk), iOS IPA (.ipa)
-   主要な出力ディレクトリ: `ci-outputs/` (テスト結果、ビルド成果物)
-   アーティファクト保持期間: 7日

