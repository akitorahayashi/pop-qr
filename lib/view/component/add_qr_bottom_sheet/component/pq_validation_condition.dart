import 'package:flutter/cupertino.dart';

/// バリデーション条件の表示コンポーネント（シンプルなキャプションスタイル）
class PQValidationCondition extends StatelessWidget {
  final List<String> conditions;

  const PQValidationCondition({super.key, required this.conditions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            conditions
                .map(
                  (condition) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      condition,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
