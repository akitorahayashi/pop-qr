import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';

import '../../../provider/qr_items_provider.dart';
import '../../../util/validation.dart';
import '../dialog/emoji_input_dialog.dart';
import 'component/add_qr_button.dart';
import 'component/input_field.dart';

class AddQrBottomSheet extends HookConsumerWidget {
  const AddQrBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final urlController = useTextEditingController();
    final emojiController = useTextEditingController();

    // バリデーションエラーメッセージの状態
    final titleError = useState<String?>(null);
    final urlError = useState<String?>(null);

    // フォームが有効かどうかを管理
    final isFormValid = useState(false);

    // 現在選択されている絵文字
    final selectedEmoji = useState<String>('📱');

    // リンク先を表す絵文字リスト
    final linkEmojis = [
      // ウェブサイト/一般
      '🌐', '💻', '📱',
      // ショッピング
      '🛒', '🛍️', '💳',
      // エンタメ/メディア
      '🎬', '📺', '🎮', '🎵', '📚',
      // 飲食
      '🍽️', '☕', '🍕',
      // 場所/旅行
      '📍', '🏨', '✈️', '🚗',
      // ビジネス
      '💼', '📊', '🏢',
      // SNS/通信
      '📸', '💬', '📧',
      // その他
      '🔍', 'ℹ️', '🔗',
    ];

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
      final titleValidationResult = Validation.validateTitle(
        titleController.text,
      );
      final urlValidationResult = Validation.validateUrl(urlController.text);

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

                    // 入力フォーム部分（スクロール可能）
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // タイトル入力
                            InputField(
                              label: 'タイトル',
                              placeholder: 'タイトルを入力',
                              controller: titleController,
                              errorText: titleError.value,
                            ),
                            const SizedBox(height: 24),

                            // URL入力
                            InputField(
                              label: 'URL',
                              placeholder: 'URLを入力 (例: https://example.com)',
                              controller: urlController,
                              errorText: urlError.value,
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 24),

                            // 絵文字入力
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '絵文字',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: CupertinoColors.label,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // 選択中の絵文字表示 + 入力可能なフィールド
                                    GestureDetector(
                                      onTap: () async {
                                        // 新しい絵文字入力ダイアログを表示
                                        final emoji =
                                            await showEmojiInputDialog(
                                              context: context,
                                              initialEmoji: selectedEmoji.value,
                                            );

                                        // 絵文字が選択された場合のみ更新
                                        if (emoji != null) {
                                          selectedEmoji.value = emoji;
                                          setEmoji(emoji);
                                        }
                                      },
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.systemGrey6,
                                          borderRadius: BorderRadius.circular(
                                            21,
                                          ),
                                          border: Border.all(
                                            color: CupertinoColors.systemGrey4,
                                            width: 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            selectedEmoji.value,
                                            style: const TextStyle(
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // テキストフィールドを削除し、代わりにヒントを表示
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          'タップして絵文字を入力、または下から選択',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                CupertinoColors.secondaryLabel,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // 絵文字選択グリッド
                                Text(
                                  'リンクを表す絵文字',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
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
                                            linkEmojis
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
                                // ボタンの上に余白を追加
                                const SizedBox(height: 24),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 追加ボタン
                    AddQRButton(
                      onPressed: submitForm,
                      isEnabled: isFormValid.value,
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
