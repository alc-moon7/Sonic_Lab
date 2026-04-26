import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/main_shell.dart';
import 'features/dust/dust_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/sonic/sonic_lab_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/water/water_screen.dart';

abstract final class AppRoutes {
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String water = 'water';
  static const String dust = 'dust';
  static const String sonic = 'sonic';
  static const String settings = 'settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        name: AppRoutes.splash,
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRoutes.onboarding,
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            name: AppRoutes.water,
            path: '/water',
            builder: (context, state) => const WaterScreen(),
          ),
          GoRoute(
            name: AppRoutes.dust,
            path: '/dust',
            builder: (context, state) => const DustScreen(),
          ),
          GoRoute(
            name: AppRoutes.sonic,
            path: '/sonic',
            builder: (context, state) => const SonicLabScreen(),
          ),
          GoRoute(
            name: AppRoutes.settings,
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

class SonicLabApp extends ConsumerWidget {
  const SonicLabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'SONIC_LAB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
