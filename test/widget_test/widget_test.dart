import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pop_qr/app.dart';
import 'package:pop_qr/model/qr_item.dart';
import 'package:pop_qr/provider/qr_items_provider.dart';

// テスト用のQrItemsNotifier
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
}

void main() {
  testWidgets('アプリが正常に起動しホーム画面が表示されること', (WidgetTester tester) async {
    // サンプルアイテム
    final sampleItems = [
      QrItem(
        id: 'sample-id-1',
        title: 'サンプルQR 1',
        url: 'https://example.com/sample1',
        emoji: '🌟',
      ),
      QrItem(
        id: 'sample-id-2',
        title: 'サンプルQR 2',
        url: 'https://example.com/sample2',
        emoji: '📱',
      ),
    ];

    // アプリをレンダリング
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          qrItemsProvider.overrideWith(
            () => TestQrItems(initialItems: sampleItems),
          ),
        ],
        child: const PopQRApp(),
      ),
    );

    // 非同期データが読み込まれるまで待機
    await tester.pumpAndSettle();

    // アプリタイトルとQRアイテムが表示されていることを確認
    expect(find.text('マイQRコード'), findsOneWidget);
    expect(find.text('サンプルQR 1'), findsOneWidget);
    expect(find.text('サンプルQR 2'), findsOneWidget);
    expect(find.text('🌟'), findsOneWidget);
    expect(find.text('📱'), findsOneWidget);

    // 追加ボタンが表示されていることを確認
    expect(find.byIcon(CupertinoIcons.add), findsOneWidget);
  });

  testWidgets('QRアイテムをタップするとQRコード詳細が表示されること', (WidgetTester tester) async {
    // サンプルアイテム
    final sampleItems = [
      QrItem(
        id: 'sample-id-1',
        title: 'サンプルQR',
        url: 'https://example.com/sample',
        emoji: '🌟',
      ),
    ];

    // アプリをレンダリング
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          qrItemsProvider.overrideWith(
            () => TestQrItems(initialItems: sampleItems),
          ),
        ],
        child: const PopQRApp(),
      ),
    );

    // 非同期データが読み込まれるまで待機
    await tester.pumpAndSettle();

    // QRアイテムをタップ
    await tester.tap(find.text('サンプルQR'));

    // ダイアログのアニメーションが完了するまで十分な時間を待つ
    // アニメーションは270ms + 追加の待機時間
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // リンクアイコンが表示されることでモーダルが表示されていることを検証
    expect(find.byKey(const ValueKey('link')), findsOneWidget);
  });

  testWidgets('初回起動時にQRアイテムが空の場合は適切なメッセージが表示されること', (
    WidgetTester tester,
  ) async {
    // アプリをレンダリング（空のアイテムリスト）
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          qrItemsProvider.overrideWith(() => TestQrItems(initialItems: [])),
        ],
        child: const PopQRApp(),
      ),
    );

    // 非同期データが読み込まれるまで待機
    await tester.pumpAndSettle();

    // 空の状態メッセージが表示されていることを確認
    expect(find.text('QRコードが登録されていません'), findsOneWidget);
    expect(find.text('QRコードを追加'), findsOneWidget);
  });
}
