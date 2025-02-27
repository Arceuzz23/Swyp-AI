import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:swyp_ai/core/models/api_response.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['URI'] ?? '', // Get URL from .env
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: false,
      ),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add common headers here
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Transform error response into ApiResponse format
          final errorResponse = ApiResponse(
            success: false,
            error: ErrorDetails(
              code: e.response?.statusCode?.toString() ?? 'unknown',
              message: e.message ?? 'Unknown error occurred',
            ),
          );
          // Return error response instead of propagating the exception
          return handler.resolve(
            Response(requestOptions: e.requestOptions, data: errorResponse),
          );
        },
      ),
    ]);
  }

  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    required T Function(dynamic) fromJson,
    Object? body,
  }) async {
    try {
      final response = await dio.post(endpoint, data: body);

      if (response.data is ApiResponse) {
        return response.data as ApiResponse<T>;
      }

      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'],
        data:
            response.data['data'] != null
                ? fromJson(response.data['data'])
                : null,
        meta: response.data['meta'] as Map<String, dynamic>? ?? {},
      );
    } catch (e) {
      // Handle any non-Dio exceptions
      return ApiResponse(
        success: false,
        error: ErrorDetails(code: 'unknown', message: e.toString()),
      );
    }
  }

  void dispose() {
    dio.close();
  }
}
