import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../provider/qr_items_provider.dart';
import '../../util/validation.dart';
import 'component/add_qr_button.dart';
import 'component/qr_icon_selector.dart';
import 'component/input_field.dart';
import 'component/qr_icon_data.dart';

class AddQrBottomSheet extends HookConsumerWidget {
  const AddQrBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final urlController = useTextEditingController();
    final selectedIconIndex = useState(0);

    // バリデーションエラーメッセージの状態
    final titleError = useState<String?>(null);
    final urlError = useState<String?>(null);

    // フォームが有効かどうかを管理
    final isFormValid = useState(false);

    final availableIcons = [
      QRIconData(CupertinoIcons.link, 'link'),
      QRIconData(CupertinoIcons.globe, 'globe'),
      QRIconData(CupertinoIcons.device_phone_portrait, 'phone'),
      QRIconData(CupertinoIcons.briefcase, 'briefcase'),
      QRIconData(CupertinoIcons.camera, 'camera'),
      QRIconData(CupertinoIcons.game_controller, 'game'),
      QRIconData(CupertinoIcons.music_note, 'music'),
      QRIconData(CupertinoIcons.book, 'book'),
      QRIconData(CupertinoIcons.chat_bubble, 'chat'),
      QRIconData(CupertinoIcons.cart, 'cart'),
      QRIconData(CupertinoIcons.desktopcomputer, 'computer'),
      QRIconData(CupertinoIcons.person, 'person'),
    ];

    // シートを閉じる処理
    void closeSheet(bool saveData) {
      if (saveData) {
        ref
            .read(qrItemsProvider.notifier)
            .addItem(
              title: titleController.text,
              url: urlController.text,
              icon: availableIcons[selectedIconIndex.value].name,
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

    // テキスト変更時のリスナー（デバウンス処理付き）
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

    // 初回レンダリング時にも必ずバリデーションを実行（ボタンが最初は無効になるように）
    useEffect(() {
      // わずかな遅延を入れて確実に初期化後に実行
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
                      child: Padding(
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

                            // アイコン選択
                            QRIconSelector(
                              icons: availableIcons,
                              selectedIndex: selectedIconIndex.value,
                              onIconSelected:
                                  (index) => selectedIconIndex.value = index,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 追加ボタン - isEnabled状態を明示的に渡す
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
