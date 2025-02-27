import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/auth_response.dart';
import '../models/api_response.dart';
import 'api_client.dart';

final logger = Logger();

class AuthApi {
  final ApiClient _apiClient;

  AuthApi(this._apiClient);

  Future<ApiResponse<AuthResponse>> signIn({
    required String email,
    required String password,
  }) async {
    logger.d('🔐 Login attempt with username: $email');

    final response = await _apiClient.post(
      endpoint: '/login',
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      body: {"username": email, "password": password},
    );

    logger.d('''
📡 API Response:
  Success: ${response.success}
  Message: ${response.message}
  Data: ${response.data}
  Error: ${response.error}
''');

    return response;
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiClient.post(
      endpoint: '/login',
      body: {'username': email, 'password': password},
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
    if (response.data == null) {
      throw Exception('Login failed: No data received');
    }
    return response.data!;
  }

  Future<void> logout() async {
    await _apiClient.post(endpoint: '/logout', fromJson: (json) => null);
  }
}
