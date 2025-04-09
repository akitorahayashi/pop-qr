# Pop QR

Pop QRは、URLリンクをQRコードとして保存して、対面で共有するためのアプリです。
QRコードはカード形式で表示され、タップするとQRコードを表示します。

## アーキテクチャ
- **UI層**: 画面表示と入力の処理
- **ロジック層**: データ操作の処理
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
│   │   └── qr_item.dart
│   │
│   ├── provider/                   
│   │   └── qr_items_provider.dart
│   │
│   ├── service/                    
│   │   └── storage_service.dart
│   │
│   ├── view/                       
│   │   ├── pop_up_qr.dart
│   │   │
│   │   ├── qr_code_library/
│   │   │   ├── qr_code_library.dart
│   │   │   │
│   │   │   └── component/              
│   │   │       ├── qr_item_card.dart
│   │   │       ├── floating_action_button.dart
│   │   │       │
│   │   │       └── add_qr_bottom_sheet/  
│   │   │           ├── add_qr_bottom_sheet.dart
│   │   │           │
│   │   │           └── component/          
│   │   │               ├── add_qr_button.dart
│   │   │               ├── pq_input_field.dart
│   │   │               ├── emoji_selector.dart
│   │   │               ├── pq_validation_condition.dart
│   │   │               └── qr_icon_data.dart
│   │   │
│   │   ├── dialog/               
│   │   │   └── editable_field_dialog.dart
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

### QRコードの詳細のモーダル表示とURL開く機能
QRコードカードをタップすると、モーダルでQRコードを表示します。URLをタップするとブラウザや App Store などでそのURLを開きます。

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
  mode: LaunchMode.externalApplication,
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
  title: 'Pop QR アプリ',
  url: 'https://apps.apple.com/jp/app/youtube/id544007664',
  emoji: '📲',
),
```

## バリデーション

QRコードの追加時には、入力値のバリデーションを行います：

- タイトルは1文字以上20文字以内
- URLは http:// または https:// で始まる有効なURL形式

バリデーション条件はフォーム下部にグレーテキストで常に表示されます。
