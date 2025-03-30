# Pop QR - パーソナルQRコード管理アプリ

## プロジェクト概要

Pop QRは、個人のURLリンク（SNSプロフィール、ポートフォリオサイト、連絡先情報など）をQRコードとして保存・管理するためのiOS風Flutterアプリケーションです。直感的なギャラリー形式のレイアウトと滑らかなアニメーションを組み合わせることで、QRコードの追加・表示をスムーズに行うことができます。

各QRコードはカード形式で表示され、タップすると滑らかなアニメーションとともに拡大表示されます。洗練されたiOS風のデザイン言語を採用しており、Cupertinoウィジェットを活用した一貫性のあるユーザーインターフェースを提供します。

<img width="200" alt="サンプル画像" src="https://via.placeholder.com/300x600/1E88E5/FFFFFF?text=Pop+QR" />

## アーキテクチャ

本プロジェクトはクリーンアーキテクチャの原則に従い、以下の構成を採用しています：

- **プレゼンテーション層**: UIコンポーネントとユーザー入力の処理
- **ドメイン層**: ビジネスロジックとデータモデル
- **データ層**: データの永続化とリポジトリ

### 状態管理パターン

状態管理にはRiverpodを採用し、宣言的かつリアクティブなデータフローを実現しています：

```
UI → Provider → Service → Storage → Provider → UI（更新）
```

- **UI**: ユーザー操作を受け付け、Providerにアクションを通知
- **Provider**: 状態管理と更新ロジックを提供
- **Service**: ビジネスロジックとデータ操作
- **Storage**: ローカルデータの永続化

## ディレクトリ構成

```
pop_qr/
├── lib/
│   ├── model/                      # データモデル
│   │   └── qr_item.dart            # QRコードアイテムの定義
│   │
│   ├── provider/                   # 状態管理
│   │   └── qr_items_provider.dart  # QRコードアイテムの状態管理
│   │
│   ├── router/                     # ルーティング
│   │   └── app_router.dart         # アプリのルーティング設定
│   │
│   ├── screen/                     # 画面
│   │   ├── home_screen.dart        # ホーム画面
│   │   └── qr_detail_screen.dart   # QRコード詳細画面
│   │
│   ├── service/                    # サービス
│   │   └── storage_service.dart    # データ永続化サービス
│   │
│   ├── widget/                     # 再利用可能なウィジェット
│   │   ├── qr_item_card.dart       # QRコードアイテムカード
│   │   └── add_qr_bottom_sheet.dart # QRコード追加ボトムシート
│   │
│   └── main.dart                   # アプリのエントリーポイント
│
├── build.yaml                      # ビルド設定
└── pubspec.yaml                    # 依存関係管理
```

## 技術スタック

### 言語とフレームワーク
- **Dart**: Flutter SDKで使用されるプログラミング言語
- **Flutter**: クロスプラットフォームUIフレームワーク

### 使用パッケージ

#### UI関連
- **flutter_cupertino**: iOS風のUIコンポーネント
- **cupertino_icons**: iOSスタイルのアイコンセット
- **qr_flutter**: QRコード生成ライブラリ

#### 状態管理
- **flutter_riverpod**: 状態管理フレームワーク
- **hooks_riverpod**: RiverpodとFlutter Hooksの統合
- **flutter_hooks**: 再利用可能なステート処理ロジック

#### データモデル・シリアライズ
- **freezed**: イミュータブルなデータクラス生成
- **freezed_annotation**: Freezed用アノテーション
- **json_serializable**: JSONシリアライズ/デシリアライズ
- **json_annotation**: JSONシリアライズ用アノテーション

#### ルーティング
- **go_router**: 宣言的ルーティングライブラリ

#### データ永続化
- **shared_preferences**: キー・バリュー形式のデータ保存

#### ユーティリティ
- **uuid**: 一意のID生成

## 主要機能

### ギャラリー形式のQRコード表示
ホーム画面では、保存したQRコードをグリッドレイアウトで表示します。各アイテムは視認性の高いカードUIで表示され、一目でタイトルとアイコンが分かるようになっています。ユーザーは視覚的に情報を素早く把握でき、目的のQRコードにすぐアクセスできます。

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

### スムーズなアニメーションとヒーロートランジション
QRコードカードをタップすると、Heroアニメーションによって滑らかに詳細画面へ遷移します。このアニメーションによって、ユーザーは操作の連続性を視覚的に理解でき、アプリのUXが向上します。

```dart
Hero(
  tag: 'qr_card_${item.id}',
  child: Container(
    // カードのコンテンツ
  ),
)
```

### iOS風のボトムシート
QRコード追加時には、iOSのUIガイドラインに沿ったモーダルボトムシートが表示されます。Cupertinoウィジェットを活用し、ネイティブiOSアプリと同様の操作感を実現しています。

```dart
showCupertinoModalPopup(
  context: context,
  builder: (context) => const AddQrBottomSheet(),
);
```

### カスタマイザブルなアイコン選択
QRコードアイテムには12種類のCupertinoIconsから選択できるアイコンを設定できます。これにより、各QRコードの内容や目的を視覚的に区別しやすくなります。アイコン選択UIは直感的で、選択中のアイコンがハイライト表示されます。

```dart
// アイコン選択オプション
final availableIcons = [
  AppIconData(CupertinoIcons.link, 'link'),
  AppIconData(CupertinoIcons.globe, 'globe'),
  // その他のアイコン
];
```