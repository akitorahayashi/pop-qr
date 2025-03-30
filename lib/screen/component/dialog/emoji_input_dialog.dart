import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 絵文字入力用のダイアログを表示する
///
/// [initialEmoji]: 初期表示する絵文字
/// 選択された絵文字を返す。キャンセルの場合はnullを返す
Future<String?> showEmojiInputDialog({
  required BuildContext context,
  required String initialEmoji,
}) async {
  return showCupertinoDialog<String?>(
    context: context,
    barrierDismissible: true,
    builder: (context) => _EmojiInputDialog(initialEmoji: initialEmoji),
  );
}

class _EmojiInputDialog extends HookWidget {
  final String initialEmoji;

  const _EmojiInputDialog({required this.initialEmoji});

  @override
  Widget build(BuildContext context) {
    final emojiTextController = useTextEditingController(text: initialEmoji);

    return CupertinoAlertDialog(
      title: const Text('絵文字を入力'),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Text('現在の絵文字: $initialEmoji', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: emojiTextController,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
              autofocus: true,
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
              // 先頭の1文字だけを使用
              final firstChar = emoji.characters.first;
              // 触覚フィードバック
              HapticFeedback.mediumImpact();
              Navigator.pop(context, firstChar);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
