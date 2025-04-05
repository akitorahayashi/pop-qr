import 'package:flutter/cupertino.dart';

/// 入力フィールドコンポーネント
class PQInputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final String? errorText;
  final TextInputType keyboardType;

  const PQInputField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.errorText,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              padding: const EdgeInsets.all(12),
              style: TextStyle(color: CupertinoColors.label),
              placeholderStyle: TextStyle(
                color: CupertinoColors.placeholderText,
              ),
              keyboardType: keyboardType,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(10),
                border:
                    errorText != null
                        ? Border.all(color: CupertinoColors.systemRed)
                        : Border.all(color: CupertinoColors.systemGrey5),
              ),
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  errorText!,
                  style: const TextStyle(
                    color: CupertinoColors.systemRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
