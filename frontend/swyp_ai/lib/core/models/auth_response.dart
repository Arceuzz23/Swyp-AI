import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:swyp_ai/core/models/user.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed  
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required User user,
    required String accessToken,
    required String refreshToken,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
} 