import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../provider/qr_items_provider.dart';

class QrDetailScreen extends HookConsumerWidget {
  final String id;

  const QrDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrItemsAsync = ref.watch(qrItemsProvider);

    return qrItemsAsync.when(
      data: (qrItems) {
        // データがロードされた場合
        final qrItem = qrItems.firstWhere(
          (item) => item.id == id,
          orElse: () => throw Exception('QR item not found'),
        );

        // アイコンの状態を管理
        final isCopied = useState(false);

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(qrItem.title),
            backgroundColor: CupertinoColors.systemBackground,
            border: Border(
              bottom: BorderSide(color: CupertinoColors.separator, width: 0.0),
            ),
            leading: CupertinoNavigationBarBackButton(
              onPressed: () => context.go('/'),
              color: CupertinoColors.activeBlue,
            ),
          ),
          backgroundColor: CupertinoColors.systemBackground,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: qrItem.url,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    qrItem.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          // URLをクリップボードにコピー
                          Clipboard.setData(ClipboardData(text: qrItem.url));

                          // アイコンをチェックマークに変更
                          isCopied.value = true;

                          // コピー成功を表示
                          _showCopiedMessage(context);

                          // 3秒後にアイコンを元に戻す
                          Future.delayed(const Duration(seconds: 3), () {
                            if (context.mounted) {
                              isCopied.value = false;
                            }
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (
                                Widget child,
                                Animation<double> animation,
                              ) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child:
                                  isCopied.value
                                      ? const Icon(
                                        CupertinoIcons.checkmark,
                                        key: ValueKey('check'),
                                        size: 16,
                                        color: CupertinoColors.secondaryLabel,
                                      )
                                      : const Icon(
                                        CupertinoIcons.doc_on_doc,
                                        key: ValueKey('copy'),
                                        size: 16,
                                        color: CupertinoColors.secondaryLabel,
                                      ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                qrItem.url,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading:
          () => const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          ),
      error:
          (error, stack) => CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(middle: Text('エラー')),
            child: Center(
              child: Text(
                'エラーが発生しました: $error',
                style: const TextStyle(color: CupertinoColors.destructiveRed),
              ),
            ),
          ),
    );
  }

  void _showCopiedMessage(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 50,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.darkBackgroundGray.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Text(
                  'URLをコピーしました',
                  style: TextStyle(color: CupertinoColors.white),
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

    // ハプティックフィードバックを追加
    HapticFeedback.lightImpact();
  }
}
