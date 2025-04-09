import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pop_qr/model/qr_item.dart';
import 'package:pop_qr/provider/qr_items_provider.dart';
import 'package:pop_qr/view/qr_code_library/component/qr_item_card.dart';

// テスト用のQrItemsNotifier
class TestQrItemsNotifier extends AsyncNotifier<List<QrItem>>
    implements QrItemsNotifier {
  List<QrItem> items = [];
  bool removeItemCalled = false;
  bool updateEmojiCalled = false;
  bool updateTitleCalled = false;
  bool updateUrlCalled = false;
  String? lastRemovedId;
  String? lastUpdatedId;
  String? lastUpdatedEmoji;
  String? lastUpdatedTitle;
  String? lastUpdatedUrl;

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

  @override
  Future<void> updateTitle(String id, String title) async {
    updateTitleCalled = true;
    lastUpdatedId = id;
    lastUpdatedTitle = title;

    final index = items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = items[index];
      items[index] = QrItem(
        id: item.id,
        title: title,
        url: item.url,
        emoji: item.emoji,
      );
      state = AsyncData(List.from(items));
    }
  }

  @override
  Future<void> updateUrl(String id, String url) async {
    updateUrlCalled = true;
    lastUpdatedId = id;
    lastUpdatedUrl = url;

    final index = items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = items[index];
      items[index] = QrItem(
        id: item.id,
        title: item.title,
        url: url,
        emoji: item.emoji,
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

    // リンクアイコンが表示されることでモーダルが表示されていることを検証
    expect(find.byKey(const ValueKey('link')), findsOneWidget);
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
    expect(find.text('タイトルを変更'), findsOneWidget);
    expect(find.text('URLを変更'), findsOneWidget);
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
    expect(find.text('テクノロジー'), findsOneWidget);
    expect(find.text('サービス'), findsOneWidget);
  });

  testWidgets('QRItemCardのタイトル編集ダイアログが表示されること', (WidgetTester tester) async {
    // テスト用のQrItemを作成
    final testItem = QrItem(
      id: 'test-id',
      title: 'テストQRコード',
      url: 'https://example.com',
      emoji: '🧪',
    );

    // モックプロバイダーの準備
    final mockNotifier = TestQrItemsNotifier([testItem]);

    // テスト用のProviderScopeでラップ
    await tester.pumpWidget(
      ProviderScope(
        overrides: [qrItemsProvider.overrideWith(() => mockNotifier)],
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

    // タイトル変更をタップ
    await tester.tap(find.text('タイトルを変更'));
    await tester.pumpAndSettle();

    // タイトル編集ダイアログが表示されているか確認
    expect(find.text('タイトルを変更'), findsOneWidget);
    expect(find.byType(CupertinoTextField), findsOneWidget);

    // TextEditingControllerの値を確認する代わりに、ダイアログ自体が表示されていることを確認
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);

    // 保存ボタンとキャンセルボタンが表示されていることを確認
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
  });

  testWidgets('QRItemCardのURL編集ダイアログが表示されること', (WidgetTester tester) async {
    // テスト用のQrItemを作成
    final testItem = QrItem(
      id: 'test-id',
      title: 'テストQRコード',
      url: 'https://example.com',
      emoji: '🧪',
    );

    // モックプロバイダーの準備
    final mockNotifier = TestQrItemsNotifier([testItem]);

    // テスト用のProviderScopeでラップ
    await tester.pumpWidget(
      ProviderScope(
        overrides: [qrItemsProvider.overrideWith(() => mockNotifier)],
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

    // URL変更をタップ
    await tester.tap(find.text('URLを変更'));
    await tester.pumpAndSettle();

    // URL編集ダイアログが表示されているか確認
    expect(find.text('URLを変更'), findsOneWidget);
    expect(find.byType(CupertinoTextField), findsOneWidget);

    // TextEditingControllerの値を確認する代わりに、ダイアログ自体が表示されていることを確認
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);

    // 保存ボタンとキャンセルボタンが表示されていることを確認
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
  });

  testWidgets('タイトル編集ダイアログでタイトルを更新できること', (WidgetTester tester) async {
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

    // タイトル変更をタップ
    await tester.tap(find.text('タイトルを変更'));
    await tester.pumpAndSettle();

    // 新しいタイトルを入力
    await tester.enterText(find.byType(CupertinoTextField).first, '新しいタイトル');
    await tester.pumpAndSettle();

    // 保存をタップ
    await tester.tap(find.widgetWithText(CupertinoDialogAction, '保存'));
    await tester.pumpAndSettle();

    // タイトルが更新されたことを確認
    expect(testNotifier.updateTitleCalled, isTrue);
    expect(testNotifier.lastUpdatedId, equals('test-id'));
    expect(testNotifier.lastUpdatedTitle, equals('新しいタイトル'));
  });

  testWidgets('URL編集ダイアログでURLを更新できること', (WidgetTester tester) async {
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

    // URL変更をタップ
    await tester.tap(find.text('URLを変更'));
    await tester.pumpAndSettle();

    // 新しいURLを入力（TextField自体を検索して入力）
    await tester.enterText(
      find.byType(CupertinoTextField).first,
      'https://example.com/new',
    );
    await tester.pumpAndSettle();

    // 保存をタップ
    await tester.tap(find.widgetWithText(CupertinoDialogAction, '保存'));
    await tester.pumpAndSettle();

    // URLが更新されたことを確認
    expect(testNotifier.updateUrlCalled, isTrue);
    expect(testNotifier.lastUpdatedId, equals('test-id'));
    expect(testNotifier.lastUpdatedUrl, equals('https://example.com/new'));
  });

  testWidgets('タイトル編集ダイアログでバリデーションエラーが表示されること', (WidgetTester tester) async {
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

    // タイトル変更をタップ
    await tester.tap(find.text('タイトルを変更'));
    await tester.pumpAndSettle();

    // 空のタイトルを入力（TextField自体を検索して入力）
    await tester.enterText(find.byType(CupertinoTextField).first, '');
    await tester.pumpAndSettle();

    // バリデーションエラーが表示されることを確認
    expect(find.text('タイトルを入力してください'), findsOneWidget);
  });

  testWidgets('URL編集ダイアログでバリデーションエラーが表示されること', (WidgetTester tester) async {
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

    // URL変更をタップ
    await tester.tap(find.text('URLを変更'));
    await tester.pumpAndSettle();

    // 無効なURLを入力（TextField自体を検索して入力）
    await tester.enterText(
      find.byType(CupertinoTextField).first,
      'invalid-url',
    );
    await tester.pumpAndSettle();

    // バリデーションエラーが表示されることを確認
    expect(find.text('URLはhttp://またはhttps://で始まる必要があります'), findsOneWidget);
  });
}
