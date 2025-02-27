import 'package:flutter/material.dart';
import 'package:swyp_ai/core/providers/auth_provider.dart';
import '../constants/constants.dart';
import 'package:swyp_ai/widgets/gradient_text.dart';
import '../utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swyp_ai/core/providers/api_providers.dart';
import 'package:swyp_ai/widgets/custom_snackbar.dart';
import 'package:swyp_ai/screens/authentication_screen.dart';
import 'package:go_router/go_router.dart';
import '../features/router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    AppLogger.debug('RegisterScreen initialized');
  }

  @override
  void dispose() {
    AppLogger.debug('RegisterScreen disposed');
    _usernameController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    AppLogger.info('Registration attempt started');

    if (!_formKey.currentState!.validate()) {
      AppLogger.warning('Form validation failed');
      return;
    }

    try {
      final username = _usernameController.text;
      final password = _passwordController.text;
      final age = int.parse(_ageController.text);

      // Log registration details
      AppLogger.debug(
        'Registration details: ${{'username': username, 'gender': _selectedGender, 'age': age, 'passwordLength': password.length}}',
      );

      AppLogger.debug('Registration data validated');
      AppLogger.logApi(
        '/register',
        request: {
          'username': username,
          'gender': _selectedGender,
          'age': age,
          'passwordLength': password.length,
        },
      );

      // Call the registration API
      final authApi = ref.read(authApiProvider);
      final response = await authApi.register(
        username: username,
        password: password,
        gender: _selectedGender,
        age: age,
      );

      // Log successful response details
      AppLogger.info(
        'Registration successful: ${{'userId': response.user.id, 'username': response.user.username, 'createdAt': response.user.createdAt.toIso8601String(), 'hasAccessToken': response.accessToken.isNotEmpty, 'hasRefreshToken': response.refreshToken.isNotEmpty}}',
      );

      if (response.user.id.isNotEmpty) {
        // Update auth state with the new user and tokens
        await ref
            .read(authStateProvider.notifier)
            .setAuthState(
              user: response.user,
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
            );

        // Show success message
        if (!mounted) return;
        CustomSnackBar.show(
          context: context,
          message: 'Registration successful!',
          type: SnackBarType.success,
        );

        AppLogger.logNavigation('RegisterScreen', 'HomePage');
        context.go(AppRoutes.home.path);
      } else {
        throw Exception('Registration failed: Invalid response');
      }
    } catch (e, stackTrace) {
      // Enhanced error logging
      AppLogger.error(
        'Registration failed: ${{'error': e.toString(), 'username': _usernameController.text, 'gender': _selectedGender, 'age': _ageController.text}}',
        stackTrace,
      );

      if (!mounted) return;

      // Check if error contains the specific API error message
      if (e.toString().toLowerCase().contains('username already exists')) {
        CustomSnackBar.show(
          context: context,
          message: 'Username already exists, please sign in!',
          type: SnackBarType.info,
        );

        AppLogger.logNavigation('RegisterScreen', 'AuthScreen');
        context.go(AppRoutes.login.path);
      } else {
        // Show generic error
        CustomSnackBar.show(
          context: context,
          message: 'Registration failed: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomTheme.theme.scaffoldBackgroundColor,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GradientText(
                        text: "Create Account",
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1f3d91), Color(0xFF4385f3)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        fontSize: 33,
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: CustomTheme.textColor,
                        ),
                        onPressed: () {
                          context.go(AppRoutes.login.path);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to start your journey',
                    style: CustomTheme.theme.textTheme.bodyLarge?.copyWith(
                      color: CustomTheme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Username',
                    style: CustomTheme.theme.textTheme.bodyLarge?.copyWith(
                      color: CustomTheme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameController,
                    style: CustomTheme.theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Enter your username',
                      filled: true,
                      fillColor: const Color(0xFF111827),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Password',
                    style: CustomTheme.theme.textTheme.bodyLarge?.copyWith(
                      color: CustomTheme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    style: CustomTheme.theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      filled: true,
                      fillColor: const Color(0xFF111827),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Age',
                    style: CustomTheme.theme.textTheme.bodyLarge?.copyWith(
                      color: CustomTheme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ageController,
                    style: CustomTheme.theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Enter your age',
                      filled: true,
                      fillColor: const Color(0xFF111827),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 13) {
                        return 'You must be at least 13 years old';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Gender',
                    style: CustomTheme.theme.textTheme.bodyLarge?.copyWith(
                      color: CustomTheme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    style: CustomTheme.theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF111827),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: _selectedGender,
                    dropdownColor: const Color(0xFF111827),
                    items:
                        ['Male', 'Female', 'Other']
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedGender = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _handleRegistration,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: CustomTheme.disabledColor,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go(AppRoutes.login.path);
                          },
                          child: const Text(
                            'Sign in',
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
      ),
    );
  }
}
