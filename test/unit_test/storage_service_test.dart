import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pop_qr/service/storage_service.dart';
import 'package:pop_qr/model/qr_item.dart';

void main() {
  late StorageService storageService;

  setUp(() async {
    // モックのSharedPreferencesをセットアップ
    SharedPreferences.setMockInitialValues({});
    storageService = StorageService();
    await storageService.init();
  });

  group('StorageService Tests', () {
    test('初期化時にデフォルトアイテムが設定されること', () async {
      // デフォルトアイテムは初期化時に設定されるので、取得するだけで検証可能
      final items = await storageService.getQrItems();

      // デフォルトアイテムがあることを確認
      expect(items, isNotEmpty);
      expect(items.length, equals(2));

      // デフォルトアイテムの構造を確認
      final firstItem = items.first;
      expect(firstItem.id, isNotEmpty);
      expect(firstItem.title, isNotEmpty);
      expect(firstItem.url, isNotEmpty);
      expect(firstItem.emoji, isNotEmpty);
    });

    test('QRアイテムの追加と取得が正常に動作すること', () async {
      // 新しいアイテムを作成
      final newItem = QrItem(
        id: 'test-id-123',
        title: 'テストアイテム',
        url: 'https://example.com/test',
        emoji: '🧪',
      );

      // アイテムを追加
      await storageService.addQrItem(newItem);

      // 全アイテムを取得
      final items = await storageService.getQrItems();

      // 追加したアイテムが含まれていることを確認
      final addedItem = items.firstWhere((item) => item.id == 'test-id-123');
      expect(addedItem.title, equals('テストアイテム'));
      expect(addedItem.url, equals('https://example.com/test'));
      expect(addedItem.emoji, equals('🧪'));
    });

    test('QRアイテムの削除が正常に動作すること', () async {
      // 削除用のテストアイテムを追加
      final itemToDelete = QrItem(
        id: 'delete-test-id',
        title: '削除用テストアイテム',
        url: 'https://example.com/delete',
        emoji: '❌',
      );
      await storageService.addQrItem(itemToDelete);

      // 削除前にアイテムが存在することを確認
      var items = await storageService.getQrItems();
      expect(items.any((item) => item.id == 'delete-test-id'), isTrue);

      // アイテムを削除
      await storageService.deleteQrItem('delete-test-id');

      // 削除後にアイテムが存在しないことを確認
      items = await storageService.getQrItems();
      expect(items.any((item) => item.id == 'delete-test-id'), isFalse);
    });

    test('QRアイテムの更新が正常に動作すること', () async {
      // 更新用のテストアイテムを追加
      final originalItem = QrItem(
        id: 'update-test-id',
        title: '更新前タイトル',
        url: 'https://example.com/original',
        emoji: '📝',
      );
      await storageService.addQrItem(originalItem);

      // 更新用のアイテムを作成
      final updatedItem = QrItem(
        id: 'update-test-id',
        title: '更新後タイトル',
        url: 'https://example.com/updated',
        emoji: '✅',
      );

      // アイテムを更新
      await storageService.updateQrItem(updatedItem);

      // 更新後のアイテムを取得して確認
      final items = await storageService.getQrItems();
      final retrievedItem = items.firstWhere(
        (item) => item.id == 'update-test-id',
      );

      expect(retrievedItem.title, equals('更新後タイトル'));
      expect(retrievedItem.url, equals('https://example.com/updated'));
      expect(retrievedItem.emoji, equals('✅'));
    });

    test('存在しないIDの更新はエラーにならないこと', () async {
      // 存在しないIDを持つアイテム
      final nonExistentItem = QrItem(
        id: 'non-existent-id',
        title: '存在しないアイテム',
        url: 'https://example.com/non-existent',
        emoji: '👻',
      );

      // 更新実行（エラーが発生しないことを確認）
      await expectLater(
        storageService.updateQrItem(nonExistentItem),
        completes,
      );
    });

    test('初期化後のリセットで正しくデフォルトアイテムに戻ること', () async {
      // 最初のデフォルトアイテムを記録
      final initialItems = await storageService.getQrItems();
      final initialCount = initialItems.length;

      // いくつかのアイテムを追加
      await storageService.addQrItem(
        QrItem(
          id: 'extra-item-1',
          title: '追加アイテム1',
          url: 'https://example.com/extra1',
          emoji: '1️⃣',
        ),
      );
      await storageService.addQrItem(
        QrItem(
          id: 'extra-item-2',
          title: '追加アイテム2',
          url: 'https://example.com/extra2',
          emoji: '2️⃣',
        ),
      );

      // アイテム数が増えていることを確認
      var itemsAfterAddition = await storageService.getQrItems();
      expect(itemsAfterAddition.length, greaterThan(initialCount));

      // リセット実行
      await storageService.resetToDefault();

      // リセット後のアイテムを取得
      final resetItems = await storageService.getQrItems();

      // リセット後はデフォルトアイテム数に戻ることを確認
      expect(resetItems.length, equals(initialCount));

      // 追加したアイテムが含まれていないことを確認
      expect(resetItems.any((item) => item.id == 'extra-item-1'), isFalse);
      expect(resetItems.any((item) => item.id == 'extra-item-2'), isFalse);
    });
  });
}
