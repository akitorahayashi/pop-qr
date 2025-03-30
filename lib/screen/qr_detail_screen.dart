import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';

import '../provider/qr_items_provider.dart';

class QrDetailScreen extends HookConsumerWidget {
  final String id;

  const QrDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrItems = ref.watch(qrItemsProvider);
    final qrItem = qrItems.firstWhere(
      (item) => item.id == id,
      orElse: () => throw Exception('QR item not found'),
    );

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
              Text(
                qrItem.url,
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
