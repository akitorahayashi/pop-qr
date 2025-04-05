import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pop_qr/model/qr_item.dart';
import 'package:pop_qr/provider/qr_items_provider.dart';
import 'package:pop_qr/view/qr_code_library.dart';

class TestQrItems extends AsyncNotifier<List<QrItem>>
    implements QrItemsNotifier {
  final List<QrItem> initialItems;

  TestQrItems({this.initialItems = const []});

  @override
  Future<List<QrItem>> build() async {
    return initialItems;
  }

  @override
  Future<void> addItem({
    required String title,
    required String url,
    required String emoji,
  }) async {
    final newItem = QrItem(id: 'new-id', title: title, url: url, emoji: emoji);

    state = AsyncData([...state.value ?? [], newItem]);
  }

  @override
  Future<void> removeItem(String id) async {
    if (state.value == null) return;

    final currentItems = state.value!;
    final newItems = currentItems.where((item) => item.id != id).toList();
    state = AsyncData(newItems);
  }

  @override
  Future<void> updateEmoji(String id, String emoji) async {
    if (state.value == null) return;

    final currentItems = state.value!;
    final index = currentItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final oldItem = currentItems[index];
      final updatedItem = QrItem(
        id: oldItem.id,
        title: oldItem.title,
        url: oldItem.url,
        emoji: emoji,
      );

      final newItems = List<QrItem>.from(currentItems);
      newItems[index] = updatedItem;
      state = AsyncData(newItems);
    }
  }

  @override
  Future<void> updateTitle(String id, String title) async {
    if (state.value == null) return;

    final currentItems = state.value!;
    final index = currentItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final oldItem = currentItems[index];
      final updatedItem = QrItem(
        id: oldItem.id,
        title: title,
        url: oldItem.url,
        emoji: oldItem.emoji,
      );

      final newItems = List<QrItem>.from(currentItems);
      newItems[index] = updatedItem;
      state = AsyncData(newItems);
    }
  }

  @override
  Future<void> updateUrl(String id, String url) async {
    if (state.value == null) return;

    final currentItems = state.value!;
    final index = currentItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final oldItem = currentItems[index];
      final updatedItem = QrItem(
        id: oldItem.id,
        title: oldItem.title,
        url: url,
        emoji: oldItem.emoji,
      );

      final newItems = List<QrItem>.from(currentItems);
      newItems[index] = updatedItem;
      state = AsyncData(newItems);
    }
  }
}

void main() {
  testWidgets('QRCodeLibraryScreenがQRアイテムをグリッド表示すること', (
    WidgetTester tester,
  ) async {
    // テスト用のアイテム
    final testItems = [
      QrItem(
        id: 'test-id-1',
        title: 'テストQRコード1',
        url: 'https://example.com/1',
        emoji: '📱',
      ),
      QrItem(
        id: 'test-id-2',
        title: 'テストQRコード2',
        url: 'https://example.com/2',
        emoji: '🔍',
      ),
    ];

    // モックデータを使ってホーム画面をレンダリング
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          qrItemsProvider.overrideWith(
            () => TestQrItems(initialItems: testItems),
          ),
        ],
        child: const CupertinoApp(home: QRCodeLibrary()),
      ),
    );

    // 非同期データが読み込まれるまで待機
    await tester.pumpAndSettle();

    // ナビゲーションバーのタイトルが表示されていることを確認
    expect(find.text('マイQRコード'), findsOneWidget);

    // モックデータのアイテムが表示されていることを確認
    expect(find.text('テストQRコード1'), findsOneWidget);
    expect(find.text('テストQRコード2'), findsOneWidget);
    expect(find.text('📱'), findsOneWidget);
    expect(find.text('🔍'), findsOneWidget);
  });

  testWidgets('空のデータ状態でQRCodeLibraryScreenが適切に表示されること', (
    WidgetTester tester,
  ) async {
    // モックデータを使ってホーム画面をレンダリング
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          qrItemsProvider.overrideWith(() => TestQrItems(initialItems: [])),
        ],
        child: const CupertinoApp(home: QRCodeLibrary()),
      ),
    );

    // 非同期データが読み込まれるまで待機
    await tester.pumpAndSettle();

    // 空の状態メッセージが表示されていることを確認
    expect(find.text('QRコードが登録されていません'), findsOneWidget);
    expect(find.text('QRコードを追加'), findsOneWidget);
  });

  testWidgets('追加ボタンがタップできること', (WidgetTester tester) async {
    // テスト用のアイテム
    final testItems = [
      QrItem(
        id: 'test-id-1',
        title: 'テストQRコード1',
        url: 'https://example.com/1',
        emoji: '📱',
      ),
    ];

    // モックデータを使ってホーム画面をレンダリング
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          qrItemsProvider.overrideWith(
            () => TestQrItems(initialItems: testItems),
          ),
        ],
        child: const CupertinoApp(home: QRCodeLibrary()),
      ),
    );

    // 非同期データが読み込まれるまで待機
    await tester.pumpAndSettle();

    // 追加ボタンをタップ
    final addButton = find.byIcon(CupertinoIcons.add);
    expect(addButton, findsOneWidget);

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // ボトムシートが表示されていることを確認
    expect(find.text('QRコードを追加'), findsAtLeastNWidgets(1));
  });
}
