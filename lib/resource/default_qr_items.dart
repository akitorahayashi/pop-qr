import 'package:uuid/uuid.dart';
import '../model/qr_item.dart';

/// アプリの初期状態で表示されるサンプルQRコードデータ
class DefaultQrItems {
  static final _uuid = Uuid();

  /// デフォルトのQRコードアイテムのリストを取得
  static List<QrItem> getItems() {
    return [
      // X（旧Twitter）
      QrItem(
        id: _uuid.v4(),
        title: 'X（旧Twitter）',
        url: 'https://x.com',
        emoji: '✖️',
      ),

      // LINE
      QrItem(
        id: _uuid.v4(),
        title: 'LINE友だち追加',
        url: 'https://line.me/R/ti/p/@yourname',
        emoji: '💬',
      ),

      // 入力フォーム
      QrItem(
        id: _uuid.v4(),
        title: 'アンケートフォーム',
        url: 'https://docs.google.com/forms',
        emoji: '📝',
      ),
    ];
  }
}
