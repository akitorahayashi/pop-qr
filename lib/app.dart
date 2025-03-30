import 'package:flutter/cupertino.dart';
import 'package:pop_qr/view/home_screen.dart';

class PopQRApp extends StatelessWidget {
  const PopQRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Pop QR',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: CupertinoColors.systemBackground,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
