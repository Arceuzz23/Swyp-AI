import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swyp_ai/core/providers/api_providers.dart';
import 'package:swyp_ai/utils/logger.dart';
import '../models/auth_response.dart';
import '../network/auth_api.dart';

class Auth extends StateNotifier<AsyncValue<AuthResponse?>> {
  final AuthApi _authApi;

  Auth(this._authApi) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authApi.login(email, password);
      state = AsyncValue.data(response);
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
