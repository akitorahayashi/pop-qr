import 'package:flutter/cupertino.dart';

/// 入力フィールドコンポーネント
class PQInputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String validationContent;

  const PQInputField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.keyboardType = TextInputType.text,
    required this.validationContent,
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
                border: Border.all(color: CupertinoColors.systemGrey5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 1),
              child: Text(
                validationContent,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
