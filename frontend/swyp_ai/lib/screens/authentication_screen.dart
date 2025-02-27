// lib/screens/auth_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:swyp_ai/screens/register_screen.dart';
import 'package:swyp_ai/services/googleSignIn.dart';
import 'package:swyp_ai/widgets/gradient_text.dart';
import '../constants/constants.dart'; // Import CustomTheme
import '../utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../features/router.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppLogger.debug('AuthScreen initialized');
  }

  @override
  void dispose() {
    AppLogger.debug('AuthScreen disposed');
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    AppLogger.info('Initiating login process');
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AppLogger.warning('Empty credentials attempted');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      AppLogger.debug('Processing login for $email');
      final response = await ref
          .read(authProvider.notifier)
          .login(email, password);

      // Update the auth state after successful login
      if (response != null) {
        await ref
            .read(authStateProvider.notifier)
            .setAuthState(
              user: response.user,
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
            );
      }

      if (!mounted) return;
      AppLogger.logNavigation('AuthScreen', 'HomePage');
      context.go(AppRoutes.home.path);
    } catch (e) {
      AppLogger.error('Login process failed', e);
      AppLogger.debug('Error type: ${e.runtimeType}');

      if (!mounted) return;

      if (e is DioException) {
        AppLogger.debug('Response data: ${e.response?.data}');
        AppLogger.debug('Response status: ${e.response?.statusCode}');
        AppLogger.debug('Error type: ${e.type}');
        AppLogger.debug('Error message: ${e.message}');

        final errorData = e.response?.data;
        AppLogger.debug('Error data: $errorData');
        final errorMessage =
            errorData is Map
                ? errorData['errors']?.toString()
                : errorData?.toString() ?? 'Unknown error';

        AppLogger.debug('Processed error message: $errorMessage');

        if (errorMessage?.contains('Username not found') ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not found. Please register first.'),
              duration: Duration(seconds: 3),
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            context.go(AppRoutes.register.path);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage ?? 'Unknown error'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomTheme.theme.scaffoldBackgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                GradientText(
                  text: "Welcome Back to Swyp",
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1f3d91), Color(0xFF4385f3)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  fontSize: 33,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your personalized experience',
                  style: CustomTheme.theme.textTheme.bodyLarge?.copyWith(
                    color: CustomTheme.disabledColor,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Email or Username',
                  style: CustomTheme.theme.textTheme.bodyLarge?.copyWith(
                    color: CustomTheme.disabledColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  style: CustomTheme.theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Enter your email or username',
                    filled: true,
                    fillColor: const Color(0xFF111827),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Password',
                  style: CustomTheme.theme.textTheme.bodyLarge?.copyWith(
                    color: CustomTheme.disabledColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: CustomTheme.theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    filled: true,
                    fillColor: const Color(0xFF111827),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Add forgot password functionality
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: CustomTheme.accentColor),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade900, // Color of the line
                        thickness: 1, // Thickness of the line
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Or continue with",
                        style: TextStyle(
                          color: CustomTheme.disabledColor,
                        ), // Customize as needed
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey.shade900, thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          // Add Google sign in functionality
                          await GoogleServices.loginWithGoogle();
                        },
                        icon: const Icon(
                          Icons.g_mobiledata_sharp,
                          color: CustomTheme.textColor,
                        ),
                        label: const Text(
                          'Google',
                          style: TextStyle(
                            color: CustomTheme.textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.grey.shade900),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Add Apple sign in functionality
                        },
                        icon: const Icon(
                          Icons.apple,
                          color: CustomTheme.textColor,
                        ),
                        label: const Text(
                          'Apple',
                          style: TextStyle(
                            color: CustomTheme.textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.grey.shade900),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: CustomTheme.disabledColor,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(AppRoutes.register.path);
                        },
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            color: CustomTheme.accentColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
