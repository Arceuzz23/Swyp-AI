import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swyp_ai/utils/logger.dart';
import '../screens/home.dart';
import '../screens/authentication_screen.dart';
import '../screens/register_screen.dart';
import '../core/providers/auth_provider.dart';

enum AppRoutes {
  home('/'),
  login('/login'),
  register('/register');

  const AppRoutes(this.path);
  final String path;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthRoute =
          state.matchedLocation == AppRoutes.login.path ||
          state.matchedLocation == AppRoutes.register.path;

      if (authState.value?.accessToken != null && isAuthRoute) {
        return AppRoutes.home.path;
      }

      if (authState.value?.accessToken == null && !isAuthRoute) {
        return AppRoutes.login.path;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home.path,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.login.path,
        name: 'login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.register.path,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
    errorBuilder:
        (context, state) =>
            Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
});
