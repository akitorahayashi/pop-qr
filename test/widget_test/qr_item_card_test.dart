import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pop_qr/model/qr_item.dart';
import 'package:pop_qr/provider/qr_items_provider.dart';
import 'package:pop_qr/view/component/qr_item_card.dart';

// テスト用のQrItemsNotifier
class TestQrItemsNotifier extends AsyncNotifier<List<QrItem>>
    implements QrItemsNotifier {
  List<QrItem> items = [];
  bool removeItemCalled = false;
  bool updateEmojiCalled = false;
  String? lastRemovedId;
  String? lastUpdatedId;
  String? lastUpdatedEmoji;

  TestQrItemsNotifier(this.items);

  @override
  Future<List<QrItem>> build() async {
    return items;
  }

  @override
  Future<void> addItem({
    required String title,
    required String url,
    required String emoji,
  }) async {}

  @override
  Future<void> removeItem(String id) async {
    removeItemCalled = true;
    lastRemovedId = id;
    items.removeWhere((item) => item.id == id);
    state = AsyncData(List.from(items));
  }

  @override
  Future<void> updateEmoji(String id, String emoji) async {
    updateEmojiCalled = true;
    lastUpdatedId = id;
    lastUpdatedEmoji = emoji;

    final index = items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = items[index];
      items[index] = QrItem(
        id: item.id,
        title: item.title,
        url: item.url,
        emoji: emoji,
      );
      state = AsyncData(List.from(items));
    }
  }
}

void main() {
  testWidgets('QRItemCardが正しく表示されること', (WidgetTester tester) async {
    // テスト用のQrItemを作成
    final testItem = QrItem(
      id: 'test-id',
      title: 'テストQRコード',
      url: 'https://example.com',
      emoji: '🧪',
    );

    // テスト用のProviderScopeでラップ
    await tester.pumpWidget(
      ProviderScope(
        child: CupertinoApp(
          home: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: QRItemCard(item: testItem),
            ),
          ),
        ),
      ),
    );

    // ウィジェットがレンダリングされるまで待機
    await tester.pumpAndSettle();

    // 指定したタイトルと絵文字が表示されているか確認
    expect(find.text('テストQRコード'), findsOneWidget);
    expect(find.text('🧪'), findsOneWidget);
  });

  testWidgets('QRItemCardをタップしたときQRコード詳細が表示されること', (WidgetTester tester) async {
    // テスト用のQrItemを作成
    final testItem = QrItem(
      id: 'test-id',
      title: 'テストQRコード',
      url: 'https://example.com',
      emoji: '🧪',
    );

    // テスト用のProviderScopeでラップ
    await tester.pumpWidget(
      ProviderScope(
        child: CupertinoApp(
          home: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: QRItemCard(item: testItem),
            ),
          ),
        ),
      ),
    );

    // ウィジェットがレンダリングされるまで待機
    await tester.pumpAndSettle();

    // カードをタップ
    await tester.tap(find.byType(QRItemCard));

    // ダイアログのアニメーションが完了するまで十分な時間を待つ
    // アニメーションは270ms + 追加の待機時間
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // コピーアイコンが表示されることでモーダルが表示されていることを検証
    expect(find.byKey(const ValueKey('copy')), findsOneWidget);
  });

  testWidgets('QRItemCardを長押しするとアクションシートが表示されること', (WidgetTester tester) async {
    // テスト用のQrItemを作成
    final testItem = QrItem(
      id: 'test-id',
      title: 'テストQRコード',
      url: 'https://example.com',
      emoji: '🧪',
    );

    // テスト用のProviderScopeでラップ（シンプルなプロバイダーを使用）
    await tester.pumpWidget(
      ProviderScope(
        child: CupertinoApp(
          home: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: QRItemCard(item: testItem),
            ),
          ),
        ),
      ),
    );

    // ウィジェットがレンダリングされるまで待機
    await tester.pumpAndSettle();

    // カードを長押し
    await tester.longPress(find.byType(QRItemCard));
    await tester.pumpAndSettle();

    // アクションシートが表示されているか確認
    expect(find.text('このQRコードに対して実行する操作を選んでください'), findsOneWidget);
    expect(find.text('絵文字を変更'), findsOneWidget);
    expect(find.text('削除'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
  });

  testWidgets('削除オプションを選択するとQRアイテムが削除されること', (WidgetTester tester) async {
    // テスト用のQrItemを作成
    final testItem = QrItem(
      id: 'test-id',
      title: 'テストQRコード',
      url: 'https://example.com',
      emoji: '🧪',
    );

    // テスト用のモックNotifier
    final testNotifier = TestQrItemsNotifier([testItem]);

    // テスト用のProviderScopeでラップ
    await tester.pumpWidget(
      ProviderScope(
        overrides: [qrItemsProvider.overrideWith(() => testNotifier)],
        child: CupertinoApp(
          home: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: QRItemCard(item: testItem),
            ),
          ),
        ),
      ),
    );

    // ウィジェットがレンダリングされるまで待機
    await tester.pumpAndSettle();

    // カードを長押し
    await tester.longPress(find.byType(QRItemCard));
    await tester.pumpAndSettle();

    // 削除オプションをタップ
    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();

    // removeItemが呼ばれたことを確認
    expect(testNotifier.removeItemCalled, isTrue);
    expect(testNotifier.lastRemovedId, equals('test-id'));
  });

  testWidgets('絵文字変更オプションを選択すると絵文字選択画面が表示されること', (WidgetTester tester) async {
    // テスト用のQrItemを作成
    final testItem = QrItem(
      id: 'test-id',
      title: 'テストQRコード',
      url: 'https://example.com',
      emoji: '🧪',
    );

    // テスト用のモックNotifier
    final testNotifier = TestQrItemsNotifier([testItem]);

    // テスト用のProviderScopeでラップ
    await tester.pumpWidget(
      ProviderScope(
        overrides: [qrItemsProvider.overrideWith(() => testNotifier)],
        child: CupertinoApp(
          home: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: QRItemCard(item: testItem),
            ),
          ),
        ),
      ),
    );

    // ウィジェットがレンダリングされるまで待機
    await tester.pumpAndSettle();

    // カードを長押し
    await tester.longPress(find.byType(QRItemCard));
    await tester.pumpAndSettle();

    // 絵文字変更オプションをタップ
    await tester.tap(find.text('絵文字を変更'));
    await tester.pumpAndSettle();

    // 絵文字選択シートのタイトルが表示されることを確認
    expect(find.text('絵文字を選択'), findsOneWidget);

    // カテゴリタブが表示されていることを確認（実際の表示に合わせて）
    expect(find.text('SNS'), findsOneWidget);
    expect(find.text('ビジネス'), findsOneWidget);
  });
}
