import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swyp_ai/core/models/user.dart';
import 'package:swyp_ai/core/providers/api_providers.dart';
import 'package:swyp_ai/utils/logger.dart';
import '../models/auth_response.dart';
import '../network/auth_api.dart';

class Auth extends StateNotifier<AsyncValue<AuthResponse?>> {
  final AuthApi _authApi;

  Auth(this._authApi) : super(const AsyncValue.data(null));

  Future<AuthResponse> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authApi.login(email, password);
      state = AsyncValue.data(response);
      return response;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      AppLogger.error('Logout failed', e, stack);
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<Auth, AsyncValue<AuthResponse?>>((
  ref,
) {
  final authApi = ref.watch(authApiProvider);
  return Auth(authApi);
});

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthNotifier() : super(const AsyncValue.data(AuthState()));

  Future<AuthResponse?> _getStoredCredentials() async {
    try {
      // TODO: Implement actual storage logic (e.g., using SharedPreferences)
      // For now, return null to indicate no stored credentials
      return null;
    } catch (e) {
      AppLogger.error('Failed to get stored credentials', e);
      return null;
    }
  }

  Future<void> setAuthState({
    required User user,
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      // Update the state with new auth information
      state = AsyncValue.data(
        AuthState(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
        ),
      );

      AppLogger.debug('Auth state updated: User ${user.id} logged in');
    } catch (e, stack) {
      AppLogger.error('Failed to update auth state', e, stack);
      state = AsyncValue.error(e, stack);
    }
  }

  void clearAuthState() {
    state = const AsyncValue.data(AuthState());
  }

  Future<void> initializeAuthState() async {
    try {
      // Get stored credentials (implement this based on your storage solution)
      final storedCredentials = await _getStoredCredentials();

      if (storedCredentials != null) {
        state = AsyncValue.data(
          AuthState(
            user: storedCredentials.user,
            accessToken: storedCredentials.accessToken,
            refreshToken: storedCredentials.refreshToken,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize auth state', e, stackTrace);
      // Clear auth state on error
      state = const AsyncValue.data(AuthState());
    }
  }

  // ... rest of the class
}

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
      return AuthNotifier();
    });

class AuthState {
  final User? user;
  final String? accessToken;
  final String? refreshToken;

  const AuthState({this.user, this.accessToken, this.refreshToken});
}
