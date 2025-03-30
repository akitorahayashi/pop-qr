import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pop_qr/app.dart';

import 'service/storage_service.dart';

/// 環境変数
// 広告テストモードを管理するフラグ
final adTestModeProvider = Provider<bool>((ref) => true);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ストレージサービスの初期化
  final storageService = StorageService();
  await storageService.init();

  runApp(const ProviderScope(child: PopQRApp()));
}
