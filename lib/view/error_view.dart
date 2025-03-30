import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// エラー表示用のウィジェット
///
/// エラー内容を視覚的に伝え、再試行機能を提供します。
class ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final bool showDetails;

  const ErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // エラーアイコン
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: CupertinoColors.systemRed,
              size: 32,
            ),
            const SizedBox(height: 16),

            // エラータイトル
            const Text(
              'エラーが発生しました',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // エラーメッセージ（省略可）
            if (showDetails) ...[
              Text(
                errorMessage,
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 8),

            // 再試行ボタン (iOSスタイルのテキストボタン)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                HapticFeedback.lightImpact();
                onRetry();
              },
              child: const Text(
                '再試行',
                style: TextStyle(
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
