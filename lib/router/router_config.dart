import 'package:ayna/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:ayna/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/helpers/ui_helpers.dart';
import '../di.dart';
import '../features/auth/presentation/pages/auth_page.dart';

enum Routes {
  auth(name: 'auth', path: '/'),
  home(name: 'home', path: '/home');

  final String name;
  final String path;

  const Routes({required this.name, required this.path});
}

final GoRouter router = GoRouter(
  initialLocation: _getInitialRoute(),
  navigatorKey: GlobalKey<NavigatorState>(),
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      name: Routes.auth.name,
      path: Routes.auth.path,
      pageBuilder: (context, state) => _buildPage(
        state.pageKey,
        state.name!,
        const AuthPage(),
      ),
    ),
    GoRoute(
      name: Routes.home.name,
      path: Routes.home.path,
      pageBuilder: (context, state) => _buildPage(
        state.pageKey,
        state.name!,
        const HomePage(),
      ),
    ),
  ],
);

final kContext = router.configuration.navigatorKey.currentContext!;
final kScaffoldMessengerKey = sl<GlobalKey<ScaffoldMessengerState>>();

Page<MaterialPage> _buildPage(LocalKey key, String name, Widget child) =>
    MaterialPage(
      key: key,
      name: name,
      child: GestureDetector(
        onTap: UiHelpers.removeFocus,
        child: child,
      ),
    );

String _getInitialRoute() {
  if (AuthLocalDatasource().isAuthenticated()) {
    return Routes.home.path;
  }

  return Routes.auth.path;
}
