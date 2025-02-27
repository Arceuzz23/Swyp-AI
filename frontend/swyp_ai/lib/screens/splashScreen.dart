import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/router.dart';
import '../core/providers/auth_provider.dart';
import '../widgets/gradient_text.dart';
import '../utils/logger.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize auth state from stored credentials
      await ref.read(authStateProvider.notifier).initializeAuthState();
      
      if (mounted) {
        // The router will automatically handle the redirect based on auth state
        context.go(AppRoutes.home.path);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize app', e, stackTrace);
      if (mounted) {
        context.go(AppRoutes.login.path);
      }
    }
  }

  @override
  void dispose() {
    AppLogger.debug('SplashScreen disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GradientText(
              text: "Swyp",
              gradient: LinearGradient(
                colors: [Color(0xFF1f3d91), Color(0xFF4385f3)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              fontSize: 55,
            ),
            SizedBox(height: 40),
            Text(
              "👋 ♾️",
              style: TextStyle(fontSize: 32, decoration: TextDecoration.none),
            ),
            SizedBox(height: 40),
            Text(
              'Create what you consume',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
