import 'package:flutter/cupertino.dart';

/// 追加ボタンコンポーネント
class AddQRButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddQRButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 14),
        // より控えめな色に変更
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(10),
        onPressed: onPressed,
        child: const Text(
          '追加',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            // テキスト色も変更
            color: CupertinoColors.darkBackgroundGray,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
