import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

Future<void> showEditableFieldDialog({
  required BuildContext context,
  required String title,
  required String initialValue,
  required String placeholder,
  required String? Function(String) onValidate,
  required Function(String) onConfirm,
  String confirmText = '保存',
  String cancelText = 'キャンセル',
}) {
  return showCupertinoDialog<void>(
    context: context,
    barrierDismissible: true,
    builder:
        (BuildContext context) => _EditableFieldDialog(
          title: title,
          initialValue: initialValue,
          placeholder: placeholder,
          onValidate: onValidate,
          onConfirm: onConfirm,
          confirmText: confirmText,
          cancelText: cancelText,
        ),
  );
}

class _EditableFieldDialog extends HookWidget {
  final String title;
  final String initialValue;
  final String placeholder;
  final String? Function(String) onValidate;
  final Function(String) onConfirm;
  final String confirmText;
  final String cancelText;

  const _EditableFieldDialog({
    required this.title,
    required this.initialValue,
    required this.placeholder,
    required this.onValidate,
    required this.onConfirm,
    required this.confirmText,
    required this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController(text: initialValue);
    final errorText = useState<String?>(null);
    final isValid = useState(true);

    // 初期検証
    useEffect(() {
      errorText.value = onValidate(initialValue);
      isValid.value = errorText.value == null;
      return null;
    }, const []);

    // 入力検証
    void validateInput() {
      final result = onValidate(textController.text);
      errorText.value = result;
      isValid.value = result == null;
    }

    return CupertinoAlertDialog(
      title: Text(title),
      content: Column(
        children: [
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: textController,
            placeholder: placeholder,
            autofocus: true,
            padding: const EdgeInsets.all(12),
            onChanged: (_) => validateInput(),
            decoration: BoxDecoration(
              border: Border.all(
                color: CupertinoColors.systemGrey4,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          if (errorText.value != null) ...[
            const SizedBox(height: 8),
            Text(
              errorText.value!,
              style: const TextStyle(
                color: CupertinoColors.destructiveRed,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          isDefaultAction: false,
          child: Text(cancelText),
        ),
        CupertinoDialogAction(
          onPressed:
              isValid.value
                  ? () {
                    onConfirm(textController.text);
                    Navigator.of(context).pop();
                  }
                  : null,
          isDefaultAction: true,
          isDestructiveAction: false,
          child: Text(
            confirmText,
            style: TextStyle(
              color:
                  isValid.value
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.systemGrey,
            ),
          ),
        ),
      ],
    );
  }
}
