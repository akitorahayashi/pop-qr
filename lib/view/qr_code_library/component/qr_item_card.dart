import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pop_qr/model/qr_item.dart';
import 'package:pop_qr/provider/qr_items_provider.dart';
import 'package:pop_qr/util/pq_validation.dart';
import 'package:pop_qr/view/dialog/editable_field_dialog.dart';
import 'package:pop_qr/view/pop_up_qr.dart';
import 'package:pop_qr/view/qr_code_library/component/add_qr_bottom_sheet/component/emoji_selector.dart';

class AnimatedCard extends HookWidget {
  final Widget child;
  final ValueNotifier<bool> isRemoving;
  final int index;

  const AnimatedCard({
    super.key,
    required this.child,
    required this.isRemoving,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    // User interaction state
    final isPressed = useState(false);

    return GestureDetector(
      onTapDown: (_) {
        isPressed.value = true;
      },
      onTapUp: (_) {
        isPressed.value = false;
      },
      onTapCancel: () {
        isPressed.value = false;
      },
      child: AnimatedScale(
        scale: isPressed.value ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: child,
      ),
    );
  }
}

/// タップ可能なカード（押し込み効果付き）
class PressableCard extends HookWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const PressableCard({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // タップ状態の管理
    final isPressed = useState(false);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      onLongPress: onLongPress,
      onTapDown: (_) {
        isPressed.value = true;
      },
      onTapUp: (_) {
        isPressed.value = false;
      },
      onTapCancel: () {
        isPressed.value = false;
      },
      child: AnimatedScale(
        scale: isPressed.value ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: child,
      ),
    );
  }
}

class QRItemCard extends HookConsumerWidget {
  final QrItem item;
  final int index;

  const QRItemCard({super.key, required this.item, this.index = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // タップ状態を追跡
    final isPressed = useState(false);
    // タップ処理中かどうかのフラグ
    final isProcessingTap = useState(false);
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
        if (!context.mounted) return; // Avoid error after dispose
        if (controller.isCompleted) return;
        controller.forward();
      });
      return null; // Let flutter_hooks handle the controller disposal
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
      // 通常タップでQRコード詳細モーダルを表示
      onTap: () {
        if (isProcessingTap.value) return; // 処理中なら重複実行を防止

        isProcessingTap.value = true;
        HapticFeedback.mediumImpact(); // Change from selectionClick to mediumImpact

        // 縮小→待機→元に戻る→モーダル表示
        isPressed.value = true;
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!context.mounted) return;
          isPressed.value = false;
          Future.delayed(const Duration(milliseconds: 50), () {
            if (!context.mounted) return;
            isProcessingTap.value = false;
            popUpQR(context: context, qrItem: item); // Use popUpQR
          });
        });
      },
      // 長押しでアクションシート
      onLongPress: () {
        HapticFeedback.mediumImpact(); // Feedback for long press
        _showActionSheet(context, ref, removeController, isRemoving);
      },
      onLongPressUp: () {
        if (isPressed.value) {
          isPressed.value = false; // Release press state
        }
      },
      onTapDown: (_) {
        if (!isProcessingTap.value) {
          isPressed.value = true;
          // HapticFeedback.lightImpact(); // Removed, added selectionClick on tap
        }
      },
      onTapUp: (_) {
        // Do not reset isPressed here for tap, handled in onTap logic
      },
      onTapCancel: () {
        isPressed.value = false;
        isProcessingTap.value = false;
      },
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
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (
                          Widget child,
                          Animation<double> animation,
                        ) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          item.emoji,
                          key: ValueKey<String>(item.emoji),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // タイトル
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      item.title,
                      key: ValueKey<String>(item.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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
      // When the sheet is dismissed, reset the pressed state
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: Text(item.title),
            message: const Text('このQRコードに対して実行する操作を選んでください'),
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _showTitleEditDialog(context, ref);
                },
                child: const Text('タイトルを変更'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _showUrlEditDialog(context, ref);
                },
                child: const Text('URLを変更'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _showEmojiSelectSheet(context, ref);
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
                    if (context.mounted) {
                      ref.read(qrItemsProvider.notifier).removeItem(item.id);
                    }
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
    ).whenComplete(() {
      // Ensure isPressed is false if dismissed by tapping outside
    });
  }

  void _showTitleEditDialog(BuildContext context, WidgetRef ref) {
    showEditableFieldDialog(
      context: context,
      title: 'タイトルを変更',
      initialValue: item.title,
      placeholder: 'タイトルを入力',
      onValidate: PQValidation.validateTitle,
      onConfirm: (newTitle) {
        if (newTitle != item.title) {
          ref.read(qrItemsProvider.notifier).updateTitle(item.id, newTitle);
        }
      },
    );
  }

  void _showUrlEditDialog(BuildContext context, WidgetRef ref) {
    showEditableFieldDialog(
      context: context,
      title: 'URLを変更',
      initialValue: item.url,
      placeholder: 'URLを入力',
      onValidate: PQValidation.validateUrl,
      onConfirm: (newUrl) {
        if (newUrl != item.url) {
          ref.read(qrItemsProvider.notifier).updateUrl(item.id, newUrl);
        }
      },
    );
  }

  void _showEmojiSelectSheet(BuildContext context, WidgetRef ref) {
    showEmojiSelectorSheet(
      context: context,
      initialEmoji: item.emoji,
      onEmojiSelected: (emoji) {
        ref.read(qrItemsProvider.notifier).updateEmoji(item.id, emoji);
      },
    );
  }
}
