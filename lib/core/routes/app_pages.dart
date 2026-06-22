import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../features/auth/auth.dart';
import '../../features/display/display.dart';
import '../../features/settings/settings.dart';
import '../../features/splash/splash.dart';
import '../di/service_locator.dart';
import 'app_routes.dart';

class Pages {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

String? _authGuard(BuildContext context, GoRouterState state) {
  final authRepo = sl<IAuthRepository>();
  final loggedIn = authRepo.currentUser != null;
  final passwordChangeRequired =
      authRepo.currentUser?.passwordChangeRequired == true;
  final isPublicRoute =
      state.matchedLocation == Routes.splashPath ||
      state.matchedLocation == Routes.loginPath;
  final isPasswordOnboarding =
      state.matchedLocation == Routes.passwordOnboardingPath;

  if (!loggedIn && !isPublicRoute) return Routes.loginPath;
  if (loggedIn && passwordChangeRequired && !isPasswordOnboarding) {
    return Routes.passwordOnboardingPath;
  }
  if (loggedIn && !passwordChangeRequired && isPasswordOnboarding) {
    return Routes.splashPath;
  }
  return null;
}

final appPages = GoRouter(
  navigatorKey: Pages.navigatorKey,
  initialLocation: Routes.splashPath,
  redirect: _authGuard,
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
      path: Routes.passwordOnboardingPath,
      builder: (context, state) => const PasswordOnboardingPage(),
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
