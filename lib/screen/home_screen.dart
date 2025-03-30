import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pop_qr/screen/add_qr_bottom_sheet/add_qr_bottom_sheet.dart';

import '../provider/qr_items_provider.dart';
import 'component/qr_item_card.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrItems = ref.watch(qrItemsProvider);

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
            qrItems.isEmpty
                ? const Center(
                  child: Text(
                    'QRコードが登録されていません',
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 16,
                    ),
                  ),
                )
                : GridView.builder(
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
                    return QrItemCard(
                      item: item,
                      onTap: () => context.go('/qr/${item.id}'),
                    );
                  },
                ),
            Positioned(
              right: 16,
              bottom: 16,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showAddQrBottomSheet(context, ref),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.add,
                    color: CupertinoColors.white,
                    size: 30,
                  ),
                ),
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
