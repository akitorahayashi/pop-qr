import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../model/qr_item.dart';
import '../service/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final qrItemsProvider = StateNotifierProvider<QrItemsNotifier, List<QrItem>>((
  ref,
) {
  final storageService = ref.watch(storageServiceProvider);
  return QrItemsNotifier(storageService);
});

class QrItemsNotifier extends StateNotifier<List<QrItem>> {
  final StorageService _storageService;
  final _uuid = const Uuid();

  QrItemsNotifier(this._storageService) : super([]) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _storageService.getQrItems();
    state = items;
  }

  Future<void> addItem({
    required String title,
    required String url,
    required String emoji,
  }) async {
    final newItem = QrItem(
      id: _uuid.v4(),
      title: title,
      url: url,
      emoji: emoji,
    );

    state = [...state, newItem];
    await _storageService.addQrItem(newItem);
  }

  Future<void> removeItem(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _storageService.deleteQrItem(id);
  }

  Future<void> updateEmoji(String id, String emoji) async {
    state =
        state.map((item) {
          if (item.id == id) {
            final updatedItem = QrItem(
              id: item.id,
              title: item.title,
              url: item.url,
              emoji: emoji,
            );
            _storageService.updateQrItem(updatedItem);
            return updatedItem;
          }
          return item;
        }).toList();
  }
}
