# Pop QR - QRコードを介したリンク共有アプリ

## プロジェクト概要

Pop QRは、URLリンクをQRコードとして保存して共有するためのアプリです。

QRコードはカード形式で表示され、タップするとモーダルでQRコードを表示します。iOS風のデザインを採用しています。

## アーキテクチャ

本プロジェクトは関心の分離を意識した設計を採用しています：

- **UI層**: 画面表示とユーザー入力の処理
- **ビジネスロジック層**: データ操作の処理
- **データ層**: データの永続化

### 状態管理
```
UI → Provider → StorageService → Provider → UI（更新）
```

- **UI**: ユーザーの操作を受け付ける
- **Provider**: 状態を管理する
- **StorageService**: ストレージ操作を行う

## ディレクトリ構成

```
pop_qr/
├── lib/
│   ├── app.dart
│   ├── main.dart
│   │
│   ├── model/                      
│   │   ├── qr_item.dart
│   │   └── generate/
│   │
│   ├── provider/                   
│   │   └── qr_items_provider.dart
│   │
│   ├── service/                    
│   │   └── storage_service.dart
│   │
│   ├── view/                       
│   │   ├── qr_code_library.dart
│   │   │
│   │   ├── component/              
│   │   │   ├── qr_item_card.dart
│   │   │   ├── qr_detail_modal.dart
│   │   │   ├── qr_icon_selector.dart
│   │   │   │
│   │   │   └── add_qr_bottom_sheet/  
│   │   │       ├── add_qr_bottom_sheet.dart
│   │   │       └── component/          
│   │   │           ├── add_qr_button.dart
│   │   │           ├── pq_input_field.dart
│   │   │           └── qr_icon_data.dart
│   │   │
│   │   └── sub_view/               
│   │       └── error_view.dart
│   │
│   ├── resource/                   
│   │   ├── default_qr_items.dart
│   │   └── emoji_list.dart
│   │
│   └── util/                       
│       └── pq_validation.dart
│
├── test/                          
│   ├── unit_test/
│   └── widget_test/
│       ├── widget_test.dart
│       ├── qr_code_library_test.dart
│       ├── qr_item_card_test.dart
│       └── add_qr_bottom_sheet_test.dart
│
└── pubspec.yaml
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

### 外部連携
- **url_launcher** # QRコードのURLを開くため

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

### QRコード詳細のモーダル表示とURL開く機能
QRコードカードをタップすると、モーダルでQRコードを表示します。URLをタップするとアプリ内ブラウザでそのURLを開きます。

```dart
showGeneralDialog(
  context: context,
  barrierDismissible: true,
  barrierLabel: "QR Detail",
  transitionDuration: const Duration(milliseconds: 270),
  // ...
);

// URLを開く処理
await launchUrl(
  url,
  mode: LaunchMode.inAppWebView,
  webViewConfiguration: const WebViewConfiguration(
    enableJavaScript: true,
    enableDomStorage: true,
  ),
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
  emoji: '💬',
),

QrItem(
  id: _uuid.v4(),
  title: 'Pop QR',
  url: 'https://apps.apple.com/jp/app/youtube/id544007664',
  emoji: '📲',
),
```

## バリデーション

QRコードの追加時には、入力値のバリデーションを行います：

- タイトルは1文字以上20文字以内
- URLはhttp://またはhttps://で始まる有効なURL形式

バリデーション条件はフォーム下部にグレーテキストで常に表示されます。

## テスト

### ユニットテスト
StorageServiceとQrItemsProviderのテストを実装しています。

### ウィジェットテスト
主要なUIコンポーネントの機能テストを実装しています。テストは実際のデバイスを使用しないFlutterのウィジェットテスト環境で実行されます。

## CI/CD ( flutter-ci.yml )

- フォーマットチェック
- 静的解析
- テスト実行
- Android/iOSビルド
