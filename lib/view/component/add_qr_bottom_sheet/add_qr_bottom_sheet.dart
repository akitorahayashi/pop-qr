import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';

import '../../../provider/qr_items_provider.dart';
import '../../../resource/emoji_list.dart';
import '../../../util/pq_validation.dart';
import 'component/add_qr_button.dart';
import 'component/pq_input_field.dart';

/// QRコード追加のためのボトムシート
class AddQrBottomSheet extends HookConsumerWidget {
  const AddQrBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final urlController = useTextEditingController();
    final emojiController = useTextEditingController();

    // 絵文字グリッドのキー
    final emojiGridKey = useMemoized(() => GlobalKey());

    // バリデーションエラーメッセージの状態
    final titleError = useState<String?>(null);
    final urlError = useState<String?>(null);

    // フォームが有効かどうかを管理
    final isFormValid = useState(false);

    // 現在選択されている絵文字
    final selectedEmoji = useState<String>('📱');

    // カテゴリ選択
    final currentCategory = useState<EmojiCategory>(EmojiCategory.technology);

    // カテゴリ選択処理
    void selectCategory(EmojiCategory category) {
      currentCategory.value = category;
      HapticFeedback.lightImpact();
    }

    // シートを閉じる処理
    void closeSheet(bool saveData) {
      if (saveData) {
        ref
            .read(qrItemsProvider.notifier)
            .addItem(
              title: titleController.text,
              url: urlController.text,
              emoji: selectedEmoji.value,
            );
      }
      Navigator.of(context).pop();
    }

    // フォームの入力内容を検証
    void validateForm() {
      final titleValidationResult = PQValidation.validateTitle(
        titleController.text,
      );
      final urlValidationResult = PQValidation.validateUrl(urlController.text);

      // エラーメッセージを設定
      titleError.value = titleValidationResult;
      urlError.value = urlValidationResult;

      // 両方のフィールドが有効な場合のみフォームは有効
      isFormValid.value =
          titleValidationResult == null && urlValidationResult == null;
    }

    // 選択した絵文字を入力欄に反映
    void setEmoji(String emoji) {
      emojiController.text = emoji;
      selectedEmoji.value = emoji; // 選択状態を更新
    }

    // テキスト変更時のリスナー
    useEffect(() {
      void listener() {
        // タイトルのバリデーションを実行
        validateForm();
      }

      titleController.addListener(listener);
      return () => titleController.removeListener(listener);
    }, [titleController]);

    useEffect(() {
      void listener() {
        // URLのバリデーションを実行
        validateForm();
      }

      urlController.addListener(listener);
      return () => urlController.removeListener(listener);
    }, [urlController]);

    // 初回レンダリング時にも必ずバリデーションを実行
    useEffect(() {
      Future.microtask(() {
        validateForm();
      });
      return null;
    }, const []);

    // フォーム送信処理
    void submitForm() {
      // バリデーションに問題がなければデータを保存
      if (isFormValid.value) {
        closeSheet(true);
      } else {
        // バリデーションに失敗した場合は再度検証して表示を更新
        validateForm();
      }
    }

    // キーボードを閉じる
    void dismissKeyboard() {
      FocusScope.of(context).unfocus();
    }

    return Stack(
      children: [
        // 背景のオーバーレイ部分（タップで閉じる）
        Positioned.fill(
          child: GestureDetector(
            onTap: () => closeSheet(false),
            behavior: HitTestBehavior.opaque,
          ),
        ),
        // 実際のシート部分
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            // イベントをキャプチャしてシート外へ伝播させない
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Listener(
              onPointerDown: (_) => dismissKeyboard(),
              child: Container(
                // シートを画面いっぱいに表示する（ステータスバー部分を除く）
                height:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // ヘッダー部分（タイトルとバツボタン）
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // タイトル
                          Center(
                            child: Text(
                              'QRコードを追加',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.label,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          // 閉じるボタン（右上）
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () => closeSheet(false),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  CupertinoIcons.xmark,
                                  color: CupertinoColors.systemGrey,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 入力フォーム部分
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // タイトル入力
                            PQInputField(
                              label: 'タイトル',
                              placeholder: 'タイトルを入力',
                              controller: titleController,
                              validationContent: '1文字以上20文字以内で入力してください',
                            ),
                            const SizedBox(height: 24),

                            // URL入力
                            PQInputField(
                              label: 'URL',
                              placeholder: 'URLを入力 (例: https://example.com)',
                              controller: urlController,
                              keyboardType: TextInputType.url,
                              validationContent:
                                  'http://またはhttps://で始まるURLを入力してください',
                            ),
                            const SizedBox(height: 24),

                            // 絵文字入力
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 12.0,
                                      ),
                                      child: Text(
                                        '絵文字',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: CupertinoColors.label,
                                        ),
                                      ),
                                    ),
                                    // 選択中の絵文字を表示
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemGrey6,
                                        borderRadius: BorderRadius.circular(21),
                                        border: Border.all(
                                          color: CupertinoColors.systemGrey4,
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 150,
                                          ),
                                          transitionBuilder: (
                                            Widget child,
                                            Animation<double> animation,
                                          ) {
                                            // フェードと拡大縮小のアニメーション
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                          child: Text(
                                            selectedEmoji.value,
                                            key: ValueKey<String>(
                                              selectedEmoji.value,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // カテゴリ選択タブ
                                Container(
                                  height: 40,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children:
                                        EmojiCategory.displayCategories.map((
                                          category,
                                        ) {
                                          final isSelected =
                                              currentCategory.value == category;
                                          return GestureDetector(
                                            onTap:
                                                () => selectCategory(category),
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isSelected
                                                        ? CupertinoColors
                                                            .activeBlue
                                                        : CupertinoColors
                                                            .systemGrey6,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color:
                                                      isSelected
                                                          ? CupertinoColors
                                                              .activeBlue
                                                          : CupertinoColors
                                                              .systemGrey5,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  category.label,
                                                  style: TextStyle(
                                                    color:
                                                        isSelected
                                                            ? CupertinoColors
                                                                .white
                                                            : CupertinoColors
                                                                .label,
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
                                Container(
                                  key: emojiGridKey,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey6,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final itemSize =
                                          (constraints.maxWidth - 8 * 5) / 6;
                                      return Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children:
                                            currentCategory.value.emojis
                                                .map(
                                                  (emoji) => GestureDetector(
                                                    onTap: () {
                                                      setEmoji(emoji);
                                                      // タップ時のハプティックフィードバック
                                                      HapticFeedback.selectionClick();
                                                    },
                                                    child: AnimatedContainer(
                                                      duration: const Duration(
                                                        milliseconds: 200,
                                                      ),
                                                      width: itemSize,
                                                      height: itemSize,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            CupertinoColors
                                                                .systemBackground,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              selectedEmoji
                                                                          .value ==
                                                                      emoji
                                                                  ? CupertinoColors
                                                                      .activeBlue
                                                                  : CupertinoColors
                                                                      .systemGrey5,
                                                          width:
                                                              selectedEmoji
                                                                          .value ==
                                                                      emoji
                                                                  ? 2
                                                                  : 1,
                                                        ),
                                                        boxShadow:
                                                            selectedEmoji
                                                                        .value ==
                                                                    emoji
                                                                ? [
                                                                  BoxShadow(
                                                                    color: CupertinoColors
                                                                        .activeBlue
                                                                        .withOpacity(
                                                                          0.3,
                                                                        ),
                                                                    blurRadius:
                                                                        4,
                                                                    spreadRadius:
                                                                        1,
                                                                  ),
                                                                ]
                                                                : null,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          emoji,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 24,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      );
                                    },
                                  ),
                                ),
                                // スクロール領域の下部に余白を追加（ボタンの高さ分）
                                const SizedBox(height: 80),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 追加ボタン - 画面下部に固定
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        border: Border(
                          top: BorderSide(
                            color: CupertinoColors.systemGrey5,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: AddQRButton(
                        onPressed: submitForm,
                        isEnabled: isFormValid.value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
