import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../screen/home_screen.dart';
import '../screen/qr_detail_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: const HomeScreen()),
      routes: [
        GoRoute(
          path: 'qr/:id',
          name: 'qr_detail',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id'] as String;
            return CupertinoPage(
              key: state.pageKey,
              child: QrDetailScreen(id: id),
            );
          },
        ),
      ],
    ),
  ],
  debugLogDiagnostics: true,
);
