import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:pop_qr/view/component/add_qr_bottom_sheet/add_qr_bottom_sheet.dart';

import '../provider/qr_items_provider.dart';
import 'sub_view/error_view.dart';
import 'component/qr_item_card.dart';

class QRCodeLibrary extends HookConsumerWidget {
  const QRCodeLibrary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrItemsAsync = ref.watch(qrItemsProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('マイQRコード'),
        backgroundColor: CupertinoColors.systemBackground,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.separator, width: 0.0),
        ),
      ),
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Stack(
          children: [
            qrItemsAsync.when(
              data: (qrItems) {
                if (qrItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.qrcode,
                          size: 32,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'QRコードが登録されていません',
                          style: TextStyle(
                            color: CupertinoColors.secondaryLabel,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _showAddQrBottomSheet(context, ref),
                          child: const Text('QRコードを追加'),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: qrItems.length,
                  itemBuilder: (context, index) {
                    final item = qrItems[index];
                    return QRItemCard(
                      key: ValueKey<String>(item.id),
                      item: item,
                      index: index,
                    );
                  },
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (error, stackTrace) {
                // エラー内容をデバッグモードでのみ出力
                debugPrint('エラーが発生しました: $error');
                debugPrint('Stack trace: $stackTrace');

                return ErrorView(
                  errorMessage: error.toString(),
                  showDetails: false,
                  onRetry: () {
                    // データの再読み込みを実行
                    ref.invalidate(qrItemsProvider);
                  },
                );
              },
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: HookBuilder(
                builder: (context) {
                  // タップ状態を追跡
                  final isPressed = useState(false);

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();

                      // タップエフェクト（押し込み→元に戻す）
                      isPressed.value = true;
                      Future.delayed(const Duration(milliseconds: 100), () {
                        isPressed.value = false;
                        if (context.mounted) {
                          _showAddQrBottomSheet(context, ref);
                        }
                      });
                    },
                    onTapDown: (_) {
                      isPressed.value = true;
                      HapticFeedback.lightImpact();
                    },
                    onTapUp: (_) {
                      isPressed.value = false;
                    },
                    onTapCancel: () {
                      isPressed.value = false;
                    },
                    child: AnimatedScale(
                      scale: isPressed.value ? 0.9 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: isPressed.value ? 0.8 : 1.0,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBackground,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.systemGrey.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                              color: CupertinoColors.systemGrey5,
                              width: 1.0,
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.add,
                            color: CupertinoColors.activeBlue,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddQrBottomSheet(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const AddQrBottomSheet(),
    );
  }
}
