import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/qr_item.dart';
import '../resource/default_qr_items.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static const String _qrItemsKey = 'qr_items';
  static const String _isFirstLaunchKey = 'is_first_launch';

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _checkAndSetupDefaultItems();
  }

  /// 初回起動時には初期QRコードデータをセットアップする
  Future<void> _checkAndSetupDefaultItems() async {
    final isFirstLaunch = _prefs!.getBool(_isFirstLaunchKey) ?? true;

    if (isFirstLaunch) {
      // 初期データをセットアップ
      final defaultItems = DefaultQrItems.getItems();
      await saveQrItems(defaultItems);

      // 初回起動フラグをfalseに設定
      await _prefs!.setBool(_isFirstLaunchKey, false);
    }
  }

  Future<List<QrItem>> getQrItems() async {
    if (_prefs == null) await init();

    final String? itemsJson = _prefs!.getString(_qrItemsKey);
    if (itemsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(itemsJson);
    return decoded.map((item) => QrItem.fromJson(item)).toList();
  }

  Future<void> saveQrItems(List<QrItem> items) async {
    if (_prefs == null) await init();

    final String encoded = jsonEncode(
      items.map((item) => item.toJson()).toList(),
    );
    await _prefs!.setString(_qrItemsKey, encoded);
  }

  /// 指定した数の初期データを強制的に追加する（デバッグや初期化用）
  Future<void> forceAddDefaultItems({int count = 3}) async {
    final defaultItems = DefaultQrItems.getItems().take(count).toList();
    for (final item in defaultItems) {
      await addQrItem(item);
    }
  }

  /// 全てのデータを初期データにリセットする
  Future<void> resetToDefault() async {
    final defaultItems = DefaultQrItems.getItems();
    await saveQrItems(defaultItems);
  }

  Future<void> addQrItem(QrItem item) async {
    final items = await getQrItems();
    items.add(item);
    await saveQrItems(items);
  }

  Future<void> deleteQrItem(String id) async {
    final items = await getQrItems();
    items.removeWhere((item) => item.id == id);
    await saveQrItems(items);
  }

  Future<void> updateQrItem(QrItem updatedItem) async {
    final items = await getQrItems();
    final index = items.indexWhere((item) => item.id == updatedItem.id);

    if (index != -1) {
      items[index] = updatedItem;
      await saveQrItems(items);
    }
  }
}
