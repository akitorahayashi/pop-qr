import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/qr_item.dart';

/// QRコード詳細表示用モーダル
///
/// 背景がマスクされ、QRコードがふわっと浮かび上がるアニメーション付き
void showQrDetailModal({
  required BuildContext context,
  required QrItem qrItem,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "QR Detail",
    barrierColor: CupertinoColors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 270),
    pageBuilder: (_, __, ___) => Container(), // Will not be used
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // アニメーション効果の定義
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuint,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curvedAnimation),
          child: _QrDetailModalContent(qrItem: qrItem),
        ),
      );
    },
  );
}

/// QRコード詳細モーダルの内容
class _QrDetailModalContent extends HookConsumerWidget {
  final QrItem qrItem;

  const _QrDetailModalContent({required this.qrItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // URL開く処理の状態管理
    final isOpening = useState(false);

    // URLを開く関数
    Future<void> launchUrlInApp() async {
      final url = Uri.parse(qrItem.url);

      // URL開始中に設定
      isOpening.value = true;

      try {
        // URLを外部ブラウザで開く
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        // エラー処理 - オーバーレイでメッセージを表示
        if (context.mounted) {
          _showMessage(context, 'URLを開けませんでした');
        }
      } finally {
        // 処理完了したら状態リセット
        if (context.mounted) {
          isOpening.value = false;
        }
      }
    }

    return GestureDetector(
      // 背景タップでモーダルを閉じる
      onTap: () => Navigator.of(context).pop(),
      child: Center(
        child: GestureDetector(
          // モーダル内部のタップはキャプチャして親へ伝播させない
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ヘッダー部分
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(qrItem.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        qrItem.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // QRコード部分
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey4.withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrItem.url,
                    version: QrVersions.auto,
                    size: 230.0,
                  ),
                ),

                const SizedBox(height: 20),

                // URL表示部分
                GestureDetector(
                  onTap: () {
                    if (!isOpening.value) {
                      // ハプティックフィードバック
                      HapticFeedback.lightImpact();
                      launchUrlInApp();
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // リンクアイコン
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child:
                            isOpening.value
                                ? const CupertinoActivityIndicator(
                                  key: ValueKey('loading'),
                                  radius: 8,
                                )
                                : const Icon(
                                  CupertinoIcons.link,
                                  key: ValueKey('link'),
                                  size: 18,
                                  color: CupertinoColors.systemGrey,
                                ),
                      ),
                      const SizedBox(width: 8),
                      // URL
                      Flexible(
                        child: Text(
                          qrItem.url,
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// メッセージをオーバーレイで表示
  void _showMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 80,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.darkBackgroundGray.withValues(
                    alpha: 0.8,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: CupertinoColors.white),
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    // 2秒後に通知を消す
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
