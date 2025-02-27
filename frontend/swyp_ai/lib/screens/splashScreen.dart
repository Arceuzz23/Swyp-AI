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
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final authState = ref.read(authProvider);
    
    // Add any initialization logic here
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (authState.value?.user != null) {
        context.go(AppRoutes.home.path);
      } else {
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
