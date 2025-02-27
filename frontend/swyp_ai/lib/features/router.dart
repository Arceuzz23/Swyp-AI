import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/home.dart';
import '../screens/authentication_screen.dart';
import '../core/providers/auth_provider.dart';

enum AppRoutes {
  home('/'),
  login('/login');

  const AppRoutes(this.path);
  final String path;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.login.path,
    redirect: (context, state) {
      final isLoggedIn = authState.value?.user != null;
      final isLoginRoute = state.uri.path == AppRoutes.login.path;

      // If not logged in and not on login page, redirect to login
      if (!isLoggedIn && !isLoginRoute) {
        return AppRoutes.login.path;
      }

      // If logged in and on login page, redirect to home
      if (isLoggedIn && isLoginRoute) {
        return AppRoutes.home.path;
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
    ],
    errorBuilder:
        (context, state) =>
            Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
});
