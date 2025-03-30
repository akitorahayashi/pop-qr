import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/qr_item.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static const String _qrItemsKey = 'qr_items';

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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
