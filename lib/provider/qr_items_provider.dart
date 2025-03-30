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
  // 環境定数
  static const bool errorTestMode = false;
  static const bool extendedLoading = true;
  static const Duration loadingDelay = Duration(seconds: 2);

  final _uuid = const Uuid();

  @override
  Future<List<QrItem>> build() async {
    final storageService = ref.watch(storageServiceProvider);

    // エラーテストモード確認
    if (errorTestMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      throw Exception('エラーテストモードによる意図的なエラー：データ読み込みに失敗しました');
    }

    // 開発時のローディングUI確認のための遅延
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

    // エラーテストモード確認
    if (errorTestMode) {
      throw Exception('エラーテストモードによる意図的なエラー：アイテム追加に失敗しました');
    }

    final newItem = QrItem(
      id: _uuid.v4(),
      title: title,
      url: url,
      emoji: emoji,
    );

    // 楽観的更新
    state = AsyncData([...state.value ?? [], newItem]);

    // データを永続化
    try {
      await storageService.addQrItem(newItem);
    } catch (e) {
      // エラーが発生した場合は、古い状態に戻す
      state = await AsyncValue.guard(() => storageService.getQrItems());
      // エラーを再スロー
      rethrow;
    }
  }

  Future<void> removeItem(String id) async {
    final storageService = ref.read(storageServiceProvider);

    // エラーテストモード確認
    if (errorTestMode) {
      throw Exception('エラーテストモードによる意図的なエラー：アイテム削除に失敗しました');
    }

    // 楽観的更新
    final currentItems = state.value ?? [];
    final newItems = currentItems.where((item) => item.id != id).toList();
    state = AsyncData(newItems);

    // データを永続化
    try {
      await storageService.deleteQrItem(id);
    } catch (e) {
      // エラーが発生した場合は、古い状態に戻す
      state = await AsyncValue.guard(() => storageService.getQrItems());
      // エラーを再スロー
      rethrow;
    }
  }

  Future<void> updateEmoji(String id, String emoji) async {
    final storageService = ref.read(storageServiceProvider);

    // エラーテストモード確認
    if (errorTestMode) {
      throw Exception('エラーテストモードによる意図的なエラー：絵文字更新に失敗しました');
    }

    final currentItems = state.value ?? [];

    // 変更するアイテムを探す
    final itemIndex = currentItems.indexWhere((item) => item.id == id);
    if (itemIndex == -1) return;

    // 更新されたアイテムを作成
    final oldItem = currentItems[itemIndex];
    final updatedItem = QrItem(
      id: oldItem.id,
      title: oldItem.title,
      url: oldItem.url,
      emoji: emoji,
    );

    // 楽観的更新
    final newItems = List<QrItem>.from(currentItems);
    newItems[itemIndex] = updatedItem;
    state = AsyncData(newItems);

    // データを永続化
    try {
      await storageService.updateQrItem(updatedItem);
    } catch (e) {
      // エラーが発生した場合は、古い状態に戻す
      state = await AsyncValue.guard(() => storageService.getQrItems());
      // エラーを再スロー
      rethrow;
    }
  }
}
