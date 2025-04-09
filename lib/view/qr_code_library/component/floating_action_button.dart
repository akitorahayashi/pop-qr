import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';

/// カスタムフローティングアクションボタン
/// タップエフェクトと影付き
class FloatingActionButton extends HookWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double size;
  final double iconSize;

  const FloatingActionButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.iconColor = CupertinoColors.activeBlue,
    this.backgroundColor = CupertinoColors.systemBackground,
    this.size = 60,
    this.iconSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    // タップ状態を追跡
    final isPressed = useState(false);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();

        // タップエフェクト（押し込み→元に戻す）
        isPressed.value = true;
        Future.delayed(const Duration(milliseconds: 100), () {
          isPressed.value = false;
          onTap();
        });
      },
      onTapDown: (_) {
        isPressed.value = true;
        HapticFeedback.lightImpact();
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
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: isPressed.value ? 0.8 : 1.0,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: CupertinoColors.systemGrey5,
                width: 1.0,
              ),
            ),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
        ),
      ),
    );
  }
}
