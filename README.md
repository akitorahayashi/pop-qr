# Pop QR - QRコード管理アプリ

## プロジェクト概要

Pop QRは、URLリンクをQRコードとして保存・管理するためのFlutterアプリです。シンプルなUIでQRコードの追加・表示を行うことができます。

QRコードはカード形式で表示され、タップするとモーダルでQRコードを表示します。iOS風のデザインを採用し、Cupertinoウィジェットを活用しています。

## アーキテクチャ

本プロジェクトは関心の分離を意識した設計を採用しています：

- **UI層**: 画面表示とユーザー入力の処理
- **ビジネスロジック層**: データ操作の処理
- **データ層**: データの永続化

### 状態管理

状態管理にはRiverpodを使用しています：

```
UI → Provider → Service → Storage → Provider → UI（更新）
```

- **UI**: ユーザーの操作を受け付ける
- **Provider**: 状態を管理する
- **Service**: データ操作を行う
- **Storage**: データを保存する

## ディレクトリ構成

```
pop_qr/
├── lib/
│   ├── app.dart                    # アプリケーションのルート
│   ├── main.dart                   # エントリーポイント
│   │
│   ├── model/                      
│   │   ├── qr_item.dart            # QRコードモデルの定義
│   │   └── generate/               # 自動生成コード
│   │
│   ├── provider/                   
│   │   └── qr_items_provider.dart  # QRコードアイテムの状態管理
│   │
│   ├── service/                    
│   │   └── storage_service.dart    # データの永続化
│   │
│   ├── view/                       
│   │   ├── home_screen.dart        # ホーム画面
│   │   ├── error_view.dart         # エラー表示画面
│   │   │
│   │   ├── component/              
│   │   │   ├── qr_item_card.dart   # QRコードアイテムカード
│   │   │   └── qr_detail_modal.dart # QRコードの詳細のポップアップ
│   │   │
│   │   └── add_qr_bottom_sheet/    
│   │       ├── add_qr_bottom_sheet.dart # QRコードのデータを追加するシート
│   │       └── component/          
│   │           ├── add_qr_button.dart  # 追加ボタンコンポーネント
│   │           ├── input_field.dart    # 入力フィールドコンポーネント
│   │           ├── qr_icon_selector.dart # アイコン選択コンポーネント
│   │           └── qr_icon_data.dart   # アイコンデータ定義
│   │
│   ├── resource/                   
│   │   ├── default_qr_items.dart   # デフォルトQRアイテム
│   │   └── emoji_list.dart         # 絵文字リスト
│   │
│   └── util/                       
│       └── validation.dart         # 入力検証ユーティリティ
│
├── test/                          
│   ├── unit_test/                 # ユニットテスト
│   └── widget_test/               # ウィジェットテスト
│
├── assets/                        # アセットファイル（画像など）
├── .github/workflows/            # GitHub Actions ワークフロー
├── android/                      # Android プラットフォーム固有のコード
├── ios/                          # iOS プラットフォーム固有のコード
├── macos/                        # macOS プラットフォーム固有のコード
├── web/                          # Webプラットフォーム固有のコード
├── linux/                        # Linux プラットフォーム固有のコード
├── windows/                      # Windows プラットフォーム固有のコード
├── build.yaml                    # freezedによってスキャンする範囲の限定
└── pubspec.yaml                  # 依存関係管理
```

## 使用パッケージ

### UI関連
- **cupertino_icons**
- **qr_flutter**

### 状態管理
- **flutter_riverpod**
- **hooks_riverpod**
- **flutter_hooks**

### データモデル
- **freezed**
- **json_serializable**

### データ永続化
- **shared_preferences**

### その他
- **uuid**

## 主要機能

### QRコードのグリッド表示
ホーム画面では、保存したQRコードの情報をグリッドレイアウトで表示します。

```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
  // ...
)
```

### ポップアップ表示によるQRコード詳細
QRコードカードをタップすると、ポップアップでQRコードを表示します。

```dart
showCupertinoModalPopup(
  context: context,
  builder: (context) => QrDetailModal(item: item),
);
```

### QRコード追加機能
ボトムシートを使用してQRコードを追加できます。

```dart
showCupertinoModalPopup(
  context: context,
  builder: (context) => const AddQrBottomSheet(),
);
```

### 絵文字による識別
QRコードに絵文字を設定することで、視覚的に区別できます。

```dart
// デフォルトのQRコードアイテム例
QrItem(
  id: _uuid.v4(),
  title: 'X（旧Twitter）',
  url: 'https://x.com',
  emoji: '🐤',
),

QrItem(
  id: _uuid.v4(),
  title: 'Pop QR',
  url: 'https://apps.apple.com/jp/app/youtube/id544007664',
  emoji: '📲',
),
```

## テスト

### ユニットテスト
StorageServiceとQrItemsProviderのテストを実装しています。

### ウィジェットテスト
主要なUIコンポーネントの機能テストを実装しています。

## CI/CD

GitHub Actionsによる自動化：

### flutter-ci.yml
テスト、コード解析、ビルドを行うワークフロー：
- フォーマットチェック
- 静的解析
- テスト実行
- Android/iOSビルド

### flutter-test.yml
テスト実行のみを行うワークフロー

どちらも基本的にはmainブランチへのプッシュやPRで自動実行されますが、以下の方法で柔軟に運用できます：

1. **特定のワークフローだけを手動実行**
   - GitHubリポジトリの「Actions」タブから「workflow_dispatch」で実行
   - 特定の変更に対して必要なワークフローだけを実行可能

2. **ブランチの設定の変更**
   - 例えば、開発ブランチでは軽量なテストのみ実行
   - リリースブランチではフルバージョンを実行

3. **コミットメッセージによるスキップ**
   - `[skip ci]`などのキーワードをコミットメッセージに含めて実行を制御

これにより、状況に応じて最適なワークフローだけを実行できます。