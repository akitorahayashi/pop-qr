import '../model/qr_item.dart';

/// アプリの初期状態で表示されるサンプルQRコードデータ
class DefaultQrItems {
  /// デフォルトのQRコードアイテムのリストを取得
  static List<QrItem> getItems() {
    return [
      // X（旧Twitter）
      QrItem(
        id: "x.id",
        title: 'X（旧Twitter）',
        url: 'https://x.com',
        emoji: '💬',
      ),

      // Pop QR
      QrItem(
        id: "popqr.id",
        title: 'Pop QR アプリ',
        url: 'https://apps.apple.com/jp/app/youtube/id544007664',
        emoji: '📲',
      ),
    ];
  }
}
