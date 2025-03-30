import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';

import '../../model/qr_item.dart';
import '../../provider/qr_items_provider.dart';
import 'dialog/emoji_input_dialog.dart';

class QRItemCard extends HookConsumerWidget {
  final QrItem item;
  final int index;

  const QRItemCard({super.key, required this.item, this.index = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // タップ状態を追跡
    final isPressed = useState(false);
    // 削除アニメーション用の状態
    final isRemoving = useState(false);

    // アニメーションコントローラー
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 500),
      initialValue: 0.0,
    );

    // 削除アニメーション用コントローラー
    final removeController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    // アニメーションの遅延（カードごとに少しずつずらす）
    final delay = (index * 70) + 50;

    // マウント時（初回表示時）に一度だけ実行
    useEffect(() {
      Future.delayed(Duration(milliseconds: delay), () {
        if (controller.isCompleted) return;
        controller.forward();
      });
      return null;
    }, const []);

    // 不透明度アニメーション
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutQuart),
      ),
    );

    // スケールアニメーション
    final scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Y軸移動アニメーション（少し下から上に上がってくる）
    final slideAnimation = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // 削除時のアニメーション
    final removeOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: removeController, curve: Curves.easeOut));

    final removeScaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: removeController, curve: Curves.easeInOut),
    );

    // カードのウィジェット
    final cardWidget = GestureDetector(
      // 通常タップで詳細画面へ
      onTap: () {
        context.go('/qr/${item.id}');
      },
      // 長押しでアクションシート
      onLongPress: () {
        _showActionSheet(context, ref, removeController, isRemoving);
      },
      onTapDown: (_) {
        isPressed.value = true;
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => isPressed.value = false,
      onTapCancel: () => isPressed.value = false,
      child: AnimatedScale(
        scale: isPressed.value ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: isPressed.value ? 0.8 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: CupertinoColors.systemBackground,
              border: Border.all(
                color: CupertinoColors.systemGrey5,
                width: 1.0,
              ),
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
      ),
    );

    // アニメーションを適用
    return AnimatedBuilder(
      animation: Listenable.merge([controller, removeController]),
      builder: (context, child) {
        // 削除中の場合は、削除アニメーションを適用
        if (isRemoving.value) {
          return Opacity(
            opacity: removeOpacityAnimation.value,
            child: Transform.scale(
              scale: removeScaleAnimation.value,
              child: child,
            ),
          );
        }

        // 通常の表示アニメーション
        return Opacity(
          opacity: fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, slideAnimation.value),
            child: Transform.scale(scale: scaleAnimation.value, child: child),
          ),
        );
      },
      child: cardWidget,
    );
  }

  void _showActionSheet(
    BuildContext context,
    WidgetRef ref,
    AnimationController removeController,
    ValueNotifier<bool> isRemoving,
  ) {
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
                  Navigator.pop(context);
                  // 削除アニメーションを開始
                  isRemoving.value = true;
                  removeController.forward().then((_) {
                    // アニメーション完了後に実際に削除
                    ref.read(qrItemsProvider.notifier).removeItem(item.id);
                  });
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

  void _showEmojiInputDialog(BuildContext context, WidgetRef ref) async {
    final emoji = await showEmojiInputDialog(
      context: context,
      initialEmoji: item.emoji,
    );

    if (emoji != null) {
      ref.read(qrItemsProvider.notifier).updateEmoji(item.id, emoji);
    }
  }
}
