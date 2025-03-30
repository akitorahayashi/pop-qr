import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pop_qr/model/qr_item.dart';
import 'package:pop_qr/provider/qr_items_provider.dart';
import 'package:pop_qr/service/storage_service.dart';

// StorageServiceのモッククラス
class MockStorageService implements StorageService {
  List<QrItem> items = [];
  bool initialized = false;

  @override
  Future<void> init() async {
    initialized = true;
    items = [
      QrItem(
        id: 'test-id-1',
        title: 'テストアイテム1',
        url: 'https://example.com/test1',
        emoji: '🔍',
      ),
      QrItem(
        id: 'test-id-2',
        title: 'テストアイテム2',
        url: 'https://example.com/test2',
        emoji: '📱',
      ),
    ];
  }

  @override
  Future<List<QrItem>> getQrItems() async {
    return items;
  }

  @override
  Future<void> saveQrItems(List<QrItem> newItems) async {
    items = newItems;
  }

  @override
  Future<void> addQrItem(QrItem item) async {
    items.add(item);
  }

  @override
  Future<void> deleteQrItem(String id) async {
    items.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> updateQrItem(QrItem updatedItem) async {
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
    }
  }

  @override
  Future<void> resetToDefault() async {
    await init();
  }

  @override
  Future<void> forceAddDefaultItems({int count = 3}) async {
    // テスト用のシンプルな実装
    for (int i = 0; i < count; i++) {
      await addQrItem(
        QrItem(
          id: 'default-$i',
          title: 'デフォルト$i',
          url: 'https://example.com/default$i',
          emoji: '🌟',
        ),
      );
    }
  }
}

void main() {
  late MockStorageService mockStorageService;
  late ProviderContainer container;

  setUp(() async {
    mockStorageService = MockStorageService();
    await mockStorageService.init();

    // カスタムストレージサービスプロバイダー
    final mockStorageServiceProvider = Provider<StorageService>((ref) {
      return mockStorageService;
    });

    container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithProvider(mockStorageServiceProvider),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('QrItemsProvider Tests', () {
    test('初期状態が正しく設定されること', () async {
      // プロバイダーの初期状態を取得
      final asyncValue = await container.read(qrItemsProvider.future);

      expect(asyncValue.length, equals(2));
      expect(asyncValue[0].title, equals('テストアイテム1'));
      expect(asyncValue[1].title, equals('テストアイテム2'));
    });

    test('QRアイテムの追加が正常に動作すること', () async {
      // プロバイダーの初期状態を取得
      await container.read(qrItemsProvider.future);

      // アイテム追加メソッドを呼び出し
      await container
          .read(qrItemsProvider.notifier)
          .addItem(
            title: '新規アイテム',
            url: 'https://example.com/new',
            emoji: '🆕',
          );

      // 更新後の状態を取得して検証
      final updatedItems = await container.read(qrItemsProvider.future);
      expect(updatedItems.length, equals(3));

      // 追加されたアイテムを検証
      final newItem = updatedItems.firstWhere((item) => item.title == '新規アイテム');
      expect(newItem.url, equals('https://example.com/new'));
      expect(newItem.emoji, equals('🆕'));

      // モックの状態も確認
      expect(mockStorageService.items.length, equals(3));
    });

    test('QRアイテムの削除が正常に動作すること', () async {
      // プロバイダーの初期状態を取得
      final initialItems = await container.read(qrItemsProvider.future);
      final itemToDeleteId = initialItems[0].id;

      // アイテム削除メソッドを呼び出し
      await container.read(qrItemsProvider.notifier).removeItem(itemToDeleteId);

      // 更新後の状態を取得して検証
      final updatedItems = await container.read(qrItemsProvider.future);
      expect(updatedItems.length, equals(1));
      expect(updatedItems.any((item) => item.id == itemToDeleteId), isFalse);

      // モックの状態も確認
      expect(mockStorageService.items.length, equals(1));
      expect(
        mockStorageService.items.any((item) => item.id == itemToDeleteId),
        isFalse,
      );
    });

    test('QRアイテムの絵文字更新が正常に動作すること', () async {
      // プロバイダーの初期状態を取得
      final initialItems = await container.read(qrItemsProvider.future);
      final itemToUpdateId = initialItems[0].id;

      // 絵文字更新メソッドを呼び出し
      await container
          .read(qrItemsProvider.notifier)
          .updateEmoji(itemToUpdateId, '🔄');

      // 更新後の状態を取得して検証
      final updatedItems = await container.read(qrItemsProvider.future);
      final updatedItem = updatedItems.firstWhere(
        (item) => item.id == itemToUpdateId,
      );
      expect(updatedItem.emoji, equals('🔄'));

      // モックの状態も確認
      final mockItem = mockStorageService.items.firstWhere(
        (item) => item.id == itemToUpdateId,
      );
      expect(mockItem.emoji, equals('🔄'));
    });

    test('エラー処理の検証', () async {
      // ソースコードを見ると、QrItemsNotifierにはstaticなerrorTestModeフラグがあるが直接変更はできない
      // 代わりに例外をキャッチするテストを行う
      final mockErrorService = MockErrorStorageService();

      // エラーを発生させるStorageServiceを使用するコンテナを作成
      final errorContainer = ProviderContainer(
        overrides: [storageServiceProvider.overrideWithValue(mockErrorService)],
      );

      // プロバイダーの初期状態を取得
      await errorContainer.read(qrItemsProvider.future);

      // addItemメソッド呼び出し時にエラーが発生することを検証
      await expectLater(
        () => errorContainer
            .read(qrItemsProvider.notifier)
            .addItem(
              title: 'エラーテスト',
              url: 'https://example.com/error',
              emoji: '⚠️',
            ),
        throwsException,
      );

      errorContainer.dispose();
    });
  });
}

// エラーを発生させるモッククラス
class MockErrorStorageService implements StorageService {
  @override
  Future<List<QrItem>> getQrItems() async {
    return [];
  }

  @override
  Future<void> addQrItem(QrItem item) async {
    throw Exception('テストのための意図的なエラー');
  }

  @override
  Future<void> deleteQrItem(String id) async {
    throw Exception('テストのための意図的なエラー');
  }

  @override
  Future<void> updateQrItem(QrItem updatedItem) async {
    throw Exception('テストのための意図的なエラー');
  }

  @override
  Future<void> saveQrItems(List<QrItem> items) async {
    throw Exception('テストのための意図的なエラー');
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> resetToDefault() async {}

  @override
  Future<void> forceAddDefaultItems({int count = 3}) async {}
}
