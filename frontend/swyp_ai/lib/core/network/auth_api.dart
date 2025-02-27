import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/auth_response.dart';
import '../models/api_response.dart';
import 'api_client.dart';

final logger = Logger();

class AuthApi {
  final ApiClient _apiClient;

  AuthApi(this._apiClient);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        endpoint: '/login',
        body: {'username': email, 'password': password},
        fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      );

      if (response.data == null) {
        logger.d('Login response data is null'); // Debug log
        throw DioException(
          requestOptions: RequestOptions(path: '/login'),
          error: 'Login failed: No data received',
        );
      }
      return response.data!;
    } on DioException catch (e) {
      logger.d('DioException caught: ${e.response?.data}');

      if (e.response?.data is Map) {
        final errorData = e.response?.data;
        final errorMessage =
            errorData['errors'] ?? errorData['message'] ?? e.message;
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          error: errorMessage,
          type: e.type,
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse<void>> logout() async {
    return await _apiClient.post<void>(
      endpoint: '/auth/logout',
      fromJson: (_) => null,
    );
  }

  Future<AuthResponse> register({
    required String username,
    required String password,
    required String gender,
    required int age,
  }) async {
    final response = await _apiClient.post(
      endpoint: '/register',
      body: {
        'username': username,
        'password': password,
        'gender': gender,
        'age': age,
      },
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
    if (response.data == null) {
      throw Exception('Registration failed: No data received');
    }
    return response.data!;
  }
}
