import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';

import '../../model/qr_item.dart';
import '../../provider/qr_items_provider.dart';

class QRItemCard extends HookConsumerWidget {
  final QrItem item;

  const QRItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // タップ状態を追跡
    final isPressed = useState(false);

    return GestureDetector(
      // 通常タップで詳細画面へ
      onTap: () {
        context.go('/qr/${item.id}');
      },
      // 長押しでアクションシート
      onLongPress: () {
        _showActionSheet(context, ref);
      },
      onTapDown: (_) => isPressed.value = true,
      onTapUp: (_) => isPressed.value = false,
      onTapCancel: () => isPressed.value = false,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: isPressed.value ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: CupertinoColors.systemBackground,
            border: Border.all(color: CupertinoColors.systemGrey5, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey3.withOpacity(0.3),
                offset: const Offset(0, 3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 絵文字の表示
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // タイトル
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: Text(item.title),
            message: const Text('このQRコードに対して実行する操作を選んでください'),
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _showEmojiInputDialog(context, ref);
                },
                child: const Text('絵文字を変更'),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  // 削除処理
                  ref.read(qrItemsProvider.notifier).removeItem(item.id);
                  Navigator.pop(context);
                },
                child: const Text('削除'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
          ),
    );
  }

  void _showEmojiInputDialog(BuildContext context, WidgetRef ref) {
    final emojiTextController = TextEditingController(text: item.emoji);

    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('絵文字を入力'),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Text(
                  '現在の絵文字: ${item.emoji}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: emojiTextController,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                  autofocus: true,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      String firstChar = value.characters.first;
                      if (value.length > 1) {
                        // 1文字のみ使用するように制限
                        emojiTextController.text = firstChar;
                        emojiTextController.selection = TextSelection.collapsed(
                          offset: firstChar.length,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text('決定'),
              onPressed: () {
                final emoji = emojiTextController.text;
                if (emoji.isNotEmpty) {
                  // 絵文字を更新
                  ref
                      .read(qrItemsProvider.notifier)
                      .updateEmoji(item.id, emoji);
                  // 更新成功フィードバック
                  HapticFeedback.mediumImpact();
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
