import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../model/qr_item.dart';

class QRItemCard extends HookConsumerWidget {
  final QrItem item;

  const QRItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // タップ状態を追跡
    final isPressed = useState(false);

    return GestureDetector(
      onTap: () {
        // ディテール画面へ遷移
        context.go('/qr/${item.id}');
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
}
