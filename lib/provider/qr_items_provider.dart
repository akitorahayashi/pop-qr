import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../model/qr_item.dart';
import '../service/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final qrItemsProvider = AsyncNotifierProvider<QrItemsNotifier, List<QrItem>>(
  QrItemsNotifier.new,
);

class QrItemsNotifier extends AsyncNotifier<List<QrItem>> {
  static const bool errorTestMode = false;
  static const bool extendedLoading = false;
  static const Duration loadingDelay = Duration(seconds: 2);

  final _uuid = const Uuid();

  @override
  Future<List<QrItem>> build() async {
    final storageService = ref.watch(storageServiceProvider);

    if (errorTestMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      throw Exception('エラーテストモードによる意図的なエラー：データ読み込みに失敗しました');
    }

    if (extendedLoading) {
      await Future.delayed(loadingDelay);
    }

    return await storageService.getQrItems();
  }

  Future<void> addItem({
    required String title,
    required String url,
    required String emoji,
  }) async {
    final storageService = ref.read(storageServiceProvider);

    if (errorTestMode) {
      throw Exception('エラーテストモードによる意図的なエラー：アイテム追加に失敗しました');
    }

    final newItem = QrItem(
      id: _uuid.v4(),
      title: title,
      url: url,
      emoji: emoji,
    );

    state = AsyncData([...state.value ?? [], newItem]);

    try {
      await storageService.addQrItem(newItem);
    } catch (e) {
      state = await AsyncValue.guard(() => storageService.getQrItems());
      rethrow;
    }
  }

  Future<void> removeItem(String id) async {
    final storageService = ref.read(storageServiceProvider);

    if (errorTestMode) {
      throw Exception('エラーテストモードによる意図的なエラー：アイテム削除に失敗しました');
    }

    final currentItems = state.value ?? [];
    final newItems = currentItems.where((item) => item.id != id).toList();
    state = AsyncData(newItems);

    try {
      await storageService.deleteQrItem(id);
    } catch (e) {
      state = await AsyncValue.guard(() => storageService.getQrItems());
      rethrow;
    }
  }

  Future<void> updateEmoji(String id, String emoji) async {
    final storageService = ref.read(storageServiceProvider);

    if (errorTestMode) {
      throw Exception('エラーテストモードによる意図的なエラー：絵文字更新に失敗しました');
    }

    final currentItems = state.value ?? [];

    final itemIndex = currentItems.indexWhere((item) => item.id == id);
    if (itemIndex == -1) return;

    final oldItem = currentItems[itemIndex];
    final updatedItem = QrItem(
      id: oldItem.id,
      title: oldItem.title,
      url: oldItem.url,
      emoji: emoji,
    );

    final newItems = List<QrItem>.from(currentItems);
    newItems[itemIndex] = updatedItem;
    state = AsyncData(newItems);

    try {
      await storageService.updateQrItem(updatedItem);
    } catch (e) {
      state = await AsyncValue.guard(() => storageService.getQrItems());
      rethrow;
    }
  }

  Future<void> updateTitle(String id, String title) async {
    final storageService = ref.read(storageServiceProvider);

    if (errorTestMode) {
      throw Exception('エラーテストモードによる意図的なエラー：タイトル更新に失敗しました');
    }

    final currentItems = state.value ?? [];

    final itemIndex = currentItems.indexWhere((item) => item.id == id);
    if (itemIndex == -1) return;

    final oldItem = currentItems[itemIndex];
    final updatedItem = QrItem(
      id: oldItem.id,
      title: title,
      url: oldItem.url,
      emoji: oldItem.emoji,
    );

    final newItems = List<QrItem>.from(currentItems);
    newItems[itemIndex] = updatedItem;
    state = AsyncData(newItems);

    try {
      await storageService.updateQrItem(updatedItem);
    } catch (e) {
      state = await AsyncValue.guard(() => storageService.getQrItems());
      rethrow;
    }
  }

  Future<void> updateUrl(String id, String url) async {
    final storageService = ref.read(storageServiceProvider);

    if (errorTestMode) {
      throw Exception('エラーテストモードによる意図的なエラー：URL更新に失敗しました');
    }

    final currentItems = state.value ?? [];

    final itemIndex = currentItems.indexWhere((item) => item.id == id);
    if (itemIndex == -1) return;

    final oldItem = currentItems[itemIndex];
    final updatedItem = QrItem(
      id: oldItem.id,
      title: oldItem.title,
      url: url,
      emoji: oldItem.emoji,
    );

    final newItems = List<QrItem>.from(currentItems);
    newItems[itemIndex] = updatedItem;
    state = AsyncData(newItems);

    try {
      await storageService.updateQrItem(updatedItem);
    } catch (e) {
      state = await AsyncValue.guard(() => storageService.getQrItems());
      rethrow;
    }
  }
}
