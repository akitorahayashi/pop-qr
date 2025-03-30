import 'package:flutter/cupertino.dart';
import 'qr_icon_data.dart';

/// アイコン選択コンポーネント
class QRIconSelector extends StatelessWidget {
  final List<QRIconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onIconSelected;

  const QRIconSelector({
    super.key,
    required this.icons,
    required this.selectedIndex,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'アイコン',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CupertinoColors.systemGrey5),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: List.generate(icons.length, (index) {
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () => onIconSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.all(8),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? CupertinoColors.systemBlue.withOpacity(0.2)
                            : CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        isSelected
                            ? Border.all(
                              color: CupertinoColors.systemBlue,
                              width: 2,
                            )
                            : Border.all(
                              color: CupertinoColors.systemGrey4,
                              width: 1,
                            ),
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: 1.0,
                    child: Center(
                      child: Icon(
                        icons[index].icon,
                        color:
                            isSelected
                                ? CupertinoColors.systemBlue
                                : CupertinoColors.systemGrey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
