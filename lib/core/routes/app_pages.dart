import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/display/presentation/display_page.dart';
import 'app_routes.dart';

class Pages {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

final appPages = GoRouter(
  navigatorKey: Pages.navigatorKey,
  initialLocation: Routes.splashPath,
  routes: [
    GoRoute(
      path: Routes.splashPath,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: Routes.loginPath,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: Routes.settingsPath,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: Routes.displayPath,
      builder: (context, state) => const DisplayPage(),
    ),
  ],
);
