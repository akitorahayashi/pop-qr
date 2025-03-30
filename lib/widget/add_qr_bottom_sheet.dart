import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../provider/qr_items_provider.dart';
import '../util/validation.dart';

// アイコンデータのクラス
class AppIconData {
  final IconData icon;
  final String name;

  const AppIconData(this.icon, this.name);
}

// シートヘッダーコンポーネント
class SheetHeader extends StatelessWidget {
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;

  const SheetHeader({
    Key? key,
    required this.onDragUpdate,
    required this.onDragEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ドラッグハンドル領域
        GestureDetector(
          onVerticalDragStart: (_) {},
          onVerticalDragUpdate: (details) {
            // 下方向へのドラッグのみ許可
            if (details.delta.dy > 0) {
              onDragUpdate(details.delta.dy);
            }
          },
          onVerticalDragEnd: (_) => onDragEnd(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                // ドラッグハンドル
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
      ],
    );
  }
}

// 入力フィールドコンポーネント
class InputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final String? errorText;
  final TextInputType keyboardType;

  const InputField({
    Key? key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.errorText,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

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

// アイコン選択コンポーネント
class IconSelector extends StatelessWidget {
  final List<AppIconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onIconSelected;

  const IconSelector({
    Key? key,
    required this.icons,
    required this.selectedIndex,
    required this.onIconSelected,
  }) : super(key: key);

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

// 追加ボタンコンポーネント
class AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddButton({Key? key, required this.onPressed}) : super(key: key);

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
      AppIconData(CupertinoIcons.link, 'link'),
      AppIconData(CupertinoIcons.globe, 'globe'),
      AppIconData(CupertinoIcons.device_phone_portrait, 'phone'),
      AppIconData(CupertinoIcons.briefcase, 'briefcase'),
      AppIconData(CupertinoIcons.camera, 'camera'),
      AppIconData(CupertinoIcons.game_controller, 'game'),
      AppIconData(CupertinoIcons.music_note, 'music'),
      AppIconData(CupertinoIcons.book, 'book'),
      AppIconData(CupertinoIcons.chat_bubble, 'chat'),
      AppIconData(CupertinoIcons.cart, 'cart'),
      AppIconData(CupertinoIcons.desktopcomputer, 'computer'),
      AppIconData(CupertinoIcons.person, 'person'),
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
            height: MediaQuery.of(context).size.height * 0.7,
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
              // タップの伝播を防ぐ
              behavior: HitTestBehavior.translucent,
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
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
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
                          const SizedBox(height: 16),

                          // URL入力
                          InputField(
                            label: 'URL',
                            placeholder: 'URLを入力 (例: https://example.com)',
                            controller: urlController,
                            errorText: urlError.value,
                            keyboardType: TextInputType.url,
                          ),
                          const SizedBox(height: 16),

                          // アイコン選択
                          IconSelector(
                            icons: availableIcons,
                            selectedIndex: selectedIconIndex.value,
                            onIconSelected:
                                (index) => selectedIconIndex.value = index,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 追加ボタン
                  AddButton(onPressed: submitForm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
