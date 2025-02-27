import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swyp_ai/core/network/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../network/auth_api.dart';

part 'api_providers.g.dart';

@riverpod
ApiClient apiClient(ApiClientRef ref) => ApiClient();

@riverpod
AuthApi authApi(AuthApiRef ref) => AuthApi(ref.watch(apiClientProvider));
