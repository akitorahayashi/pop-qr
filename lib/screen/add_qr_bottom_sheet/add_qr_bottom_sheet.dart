import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';

import '../../provider/qr_items_provider.dart';
import '../../util/validation.dart';
import 'component/add_button.dart';
import 'component/icon_selector.dart';
import 'component/input_field.dart';
import 'component/qr_icon_data.dart';

class AddQrBottomSheet extends HookConsumerWidget {
  const AddQrBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final urlController = useTextEditingController();
    final selectedIconIndex = useState(0);
    final isVisible = useState(false);

    // ドラッグによるシート位置の状態
    final dragOffset = useState(0.0);
    final isDragging = useState(false);

    // バリデーションエラーメッセージの状態
    final titleError = useState<String?>(null);
    final urlError = useState<String?>(null);

    // ボタン押下時のアニメーション状態
    final isButtonPressed = useState(false);

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
      isVisible.value = false;

      // アニメーションの完了を待つ
      Future.delayed(const Duration(milliseconds: 300), () {
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
      });
    }

    // モーダル表示時にアニメーション開始
    useEffect(() {
      // マイクロタスクを使用して確実に状態を更新
      Future.microtask(() {
        isVisible.value = true;
      });
      return null;
    }, const []);

    // 入力値が変更されたらエラーをリセット
    useEffect(() {
      void listener() {
        titleError.value = null;
      }

      titleController.addListener(listener);
      return () => titleController.removeListener(listener);
    }, [titleController]);

    useEffect(() {
      void listener() {
        urlError.value = null;
      }

      urlController.addListener(listener);
      return () => urlController.removeListener(listener);
    }, [urlController]);

    // フォーム送信処理
    void submitForm() {
      // タップフィードバックアニメーション
      isButtonPressed.value = true;
      Future.delayed(const Duration(milliseconds: 150), () {
        isButtonPressed.value = false;
      });

      // バリデーションを実行
      final titleValidationResult = Validation.validateTitle(
        titleController.text,
      );
      final urlValidationResult = Validation.validateUrl(urlController.text);

      // エラーメッセージを設定
      titleError.value = titleValidationResult;
      urlError.value = urlValidationResult;

      // バリデーションに問題がなければデータを保存
      if (titleValidationResult == null && urlValidationResult == null) {
        // 閉じるアニメーション
        closeSheet(true);
      }
    }

    // キーボードを閉じる
    void dismissKeyboard() {
      FocusScope.of(context).unfocus();
    }

    // ドラッグ処理
    void handleDrag(DragUpdateDetails details) {
      // 下方向へのドラッグのみ反応
      if (details.delta.dy > 0) {
        dragOffset.value += details.delta.dy;
        isDragging.value = true;
      }
    }

    // ドラッグ終了処理
    void handleDragEnd(DragEndDetails details) {
      // 速度が下向きに早い場合や、ある程度下げた場合は閉じる
      final velocity = details.velocity.pixelsPerSecond.dy;

      if (velocity > 300 || dragOffset.value > 60) {
        // 速度に基づいて閉じるアニメーションの調整
        final screenHeight = MediaQuery.of(context).size.height;
        final initialOffset = dragOffset.value;

        // 閉じるアニメーション時間を速度に合わせて調整
        final animDuration =
            velocity > 1000
                ? const Duration(milliseconds: 100)
                : const Duration(milliseconds: 200);

        // アニメーションの開始時間を記録
        final startTime = DateTime.now();

        // アニメーションタイマー
        Timer.periodic(const Duration(milliseconds: 16), (timer) {
          final elapsedTime =
              DateTime.now().difference(startTime).inMilliseconds;
          final t = (elapsedTime / animDuration.inMilliseconds).clamp(0.0, 1.0);

          // イージング関数で滑らかなアニメーション
          final easedT = Curves.easeOut.transform(t);

          // 現在位置から画面高さまでのアニメーション
          dragOffset.value =
              initialOffset + (screenHeight - initialOffset) * easedT;

          // アニメーション完了時
          if (t >= 1.0) {
            timer.cancel();
            closeSheet(false);
          }
        });
      } else {
        // 戻るアニメーション
        final initialOffset = dragOffset.value;
        const animDuration = Duration(milliseconds: 300);

        // アニメーションの開始時間を記録
        final startTime = DateTime.now();

        // アニメーションタイマー
        Timer.periodic(const Duration(milliseconds: 16), (timer) {
          final elapsedTime =
              DateTime.now().difference(startTime).inMilliseconds;
          final t = (elapsedTime / animDuration.inMilliseconds).clamp(0.0, 1.0);

          // スプリングバックのような効果
          final easedT = Curves.elasticOut.transform(t);

          // 現在位置から0までアニメーション
          dragOffset.value = initialOffset * (1 - easedT);

          // アニメーション完了時
          if (t >= 1.0) {
            timer.cancel();
            dragOffset.value = 0;
            isDragging.value = false;
          }
        });
      }
    }

    return GestureDetector(
      // シート外のオーバーレイ部分をタップしたら閉じる
      onTap: () => closeSheet(false),
      // オーバーレイタップとシート内タップを区別
      behavior: HitTestBehavior.opaque,
      child: GestureDetector(
        // シート内タップイベントの伝播を防止
        onTap: () {},
        child: AnimatedOpacity(
          opacity: isVisible.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, dragOffset.value, 0),
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
            // シート全体をドラッグ可能に
            child: GestureDetector(
              onVerticalDragUpdate: handleDrag,
              onVerticalDragEnd: handleDragEnd,
              // タップでキーボードを閉じる
              onTap: dismissKeyboard,
              // タップの伝播を防ぐ
              behavior: HitTestBehavior.translucent,
              child: SafeArea(
                bottom: true,
                child: Column(
                  children: [
                    // ドラッグハンドル
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Center(
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
                            const SizedBox(height: 32),

                            // URL入力
                            InputField(
                              label: 'URL',
                              placeholder: 'URLを入力 (例: https://example.com)',
                              controller: urlController,
                              errorText: urlError.value,
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 32),

                            // アイコン選択
                            QRIconSelector(
                              icons: availableIcons,
                              selectedIndex: selectedIconIndex.value,
                              onIconSelected:
                                  (index) => selectedIconIndex.value = index,
                            ),
                            // スペーサーを追加して余白を確保
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),

                    // 追加ボタン
                    AddQRButton(onPressed: submitForm),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
