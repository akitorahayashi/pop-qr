import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';

import '../../../../../resource/emoji_list.dart';

/// 絵文字セレクターコンポーネント
/// ボトムシートではなくインラインで使用可能
class EmojiSelector extends HookConsumerWidget {
  final String value;
  final Function(String) onChanged;
  final double? height;

  const EmojiSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在選択中の絵文字
    final selectedEmoji = useState<String>(value);

    // 選択が変更されたらコールバックを呼び出す
    useEffect(() {
      // 初期値と異なる場合のみコールバック
      if (selectedEmoji.value != value) {
        onChanged(selectedEmoji.value);
      }
      return null;
    }, [selectedEmoji.value]);

    // 現在表示中のカテゴリー
    final currentCategory = useState<EmojiCategory>(EmojiCategory.technology);

    // カテゴリーを選択
    void selectCategory(EmojiCategory category) {
      currentCategory.value = category;
      HapticFeedback.lightImpact();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // カテゴリ選択タブ
        Container(
          height: 40,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListView(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            children:
                EmojiCategory.displayCategories.map((category) {
                  final isSelected = currentCategory.value == category;
                  return GestureDetector(
                    onTap: () => selectCategory(category),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isSelected
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.systemGrey5,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category.label,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? CupertinoColors.white
                                    : CupertinoColors.label,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),

        // 絵文字グリッド
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemSize = (constraints.maxWidth - 8 * 5) / 6;
                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        currentCategory.value.emojis.map((emoji) {
                          final isSelected = selectedEmoji.value == emoji;
                          return GestureDetector(
                            onTap: () {
                              selectedEmoji.value = emoji;
                              HapticFeedback.selectionClick();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: itemSize,
                              height: itemSize,
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemBackground,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? CupertinoColors.activeBlue
                                          : CupertinoColors.systemGrey5,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow:
                                    isSelected
                                        ? [
                                          BoxShadow(
                                            color: CupertinoColors.activeBlue
                                                .withOpacity(0.3),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                        : null,
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> showEmojiSelectorSheet({
  required BuildContext context,
  required String initialEmoji,
  required Function(String) onEmojiSelected,
  String title = '絵文字を選択',
}) {
  // ValueNotifierを使用して状態を管理
  final emojiNotifier = ValueNotifier<String>(initialEmoji);

  return showCupertinoModalPopup<void>(
    context: context,
    builder:
        (BuildContext context) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            children: [
              // ヘッダー
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.systemGrey5,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // 選択中の絵文字表示
                    ValueListenableBuilder<String>(
                      valueListenable: emojiNotifier,
                      builder:
                          (context, emoji, _) => Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(23),
                              border: Border.all(
                                color: CupertinoColors.systemGrey4,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 150),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  emoji,
                                  key: ValueKey<String>(emoji),
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                    ),
                    const SizedBox(width: 12),
                    // タイトル
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // 決定ボタン
                    CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      child: const Text('決定'),
                      onPressed: () {
                        onEmojiSelected(emojiNotifier.value);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),

              // 絵文字セレクター
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: EmojiSelector(
                    value: initialEmoji,
                    onChanged: (emoji) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        emojiNotifier.value = emoji;
                      });
                    },
                    height: null,
                  ),
                ),
              ),
            ],
          ),
        ),
  );
}
