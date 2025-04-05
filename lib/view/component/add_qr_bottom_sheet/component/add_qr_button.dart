import 'package:flutter/cupertino.dart';

/// 追加ボタンコンポーネント
class AddQRButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isEnabled;

  const AddQRButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  State<AddQRButton> createState() => _AddQRButtonState();
}

class _AddQRButtonState extends State<AddQRButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _backgroundStartColorAnimation;
  late Animation<Color?> _backgroundEndColorAnimation;
  late Animation<double> _shadowOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundStartColorAnimation = ColorTween(
      begin: const Color(0xFFCCCCCC), // 無効状態の色
      end: const Color(0xFF4770FF), // 有効状態の開始色
    ).animate(_animationController);

    _backgroundEndColorAnimation = ColorTween(
      begin: const Color(0xFFBBBBBB), // 無効状態の色
      end: const Color(0xFF624AF2), // 有効状態の終了色
    ).animate(_animationController);

    _shadowOpacityAnimation = Tween<double>(
      begin: 0.0, // 無効状態の影の不透明度
      end: 0.3, // 有効状態の影の不透明度
    ).animate(_animationController);

    // 初期状態を設定
    if (widget.isEnabled) {
      _animationController.value = 1.0;
    } else {
      _animationController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(AddQRButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 有効/無効状態が変化したらアニメーションを実行
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            // ボタン全体の透明度をアニメーションさせる
            // 無効時: 0.6, 有効時: 1.0
            opacity: 0.6 + (0.4 * _animationController.value),
            child: Container(
              decoration: BoxDecoration(
                // アニメーションするグラデーション
                gradient: LinearGradient(
                  colors: [
                    _backgroundStartColorAnimation.value!,
                    _backgroundEndColorAnimation.value!,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                // アニメーションする影
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(
                      71,
                      112,
                      255,
                      _shadowOpacityAnimation.value,
                    ),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: const Color.fromRGBO(0, 0, 0, 0), // 透明色
                borderRadius: BorderRadius.circular(14),
                // 無効状態でもタップ可能にするが、動作は有効状態でのみ
                onPressed: widget.isEnabled ? widget.onPressed : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.5 + (0.5 * _animationController.value),
                      child: const Icon(
                        CupertinoIcons.add,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Opacity(
                      opacity: 0.5 + (0.5 * _animationController.value),
                      child: const Text(
                        'QRコードを追加',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
