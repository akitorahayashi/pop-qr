import 'package:flutter/cupertino.dart';
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
    // 表示アニメーション用
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 400),
      initialValue: 1.0,
    );

    // 削除アニメーション用のエフェクト
    useEffect(() {
      if (isRemoving.value) {
        animationController.reverse();
      }
      return null;
    }, [isRemoving.value]);

    // 表示時のアニメーション
    useEffect(() {
      animationController.reset();
      Future.delayed(Duration(milliseconds: 100 * index), () {
        animationController.forward();
      });
      return null;
    }, const []);

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
      child: child,
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
        scale: isPressed.value ? 0.95 : 1.0,
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
    // 削除アニメーション用の状態
    final isRemoving = useState(false);

    // カードのコンテンツ
    final cardContent = Container(
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    return FadeTransition(opacity: animation, child: child);
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
              transitionBuilder: (Widget child, Animation<double> animation) {
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
    );

    // アニメーション付きのカード
    return AnimatedCard(
      isRemoving: isRemoving,
      index: index,
      child: PressableCard(
        onTap: () {
          if (context.mounted) {
            popUpQR(context: context, qrItem: item);
          }
        },
        onLongPress: () {
          _showActionSheet(context, ref, isRemoving);
        },
        child: cardContent,
      ),
    );
  }

  void _showActionSheet(
    BuildContext context,
    WidgetRef ref,
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

                  showEmojiSelectorSheet(
                    context: context,
                    initialEmoji: item.emoji,
                    onEmojiSelected: (emoji) {
                      ref
                          .read(qrItemsProvider.notifier)
                          .updateEmoji(item.id, emoji);
                    },
                  );
                },
                child: const Text('絵文字を変更'),
              ),
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
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  _removeItem(ref, isRemoving);
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

  void _removeItem(WidgetRef ref, ValueNotifier<bool> isRemoving) {
    // 削除アニメーションを開始
    isRemoving.value = true;
    // カードのアニメーションコントローラーに直接アクセスできないので、
    // 一定時間後にアイテムを削除
    Future.delayed(const Duration(milliseconds: 300), () {
      ref.read(qrItemsProvider.notifier).removeItem(item.id);
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
        ref.read(qrItemsProvider.notifier).updateTitle(item.id, newTitle);
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
        ref.read(qrItemsProvider.notifier).updateUrl(item.id, newUrl);
      },
    );
  }
}
