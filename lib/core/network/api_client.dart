import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../navigation/app_navigation.dart';
import '../storage/token_storage.dart';

/// Satu instance Dio untuk seluruh aplikasi (padanan axios.create di web).
class ApiClient {
  ApiClient._()
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.timeout,
            receiveTimeout: ApiConfig.timeout,
            headers: {'Accept': 'application/json'},
            contentType: Headers.jsonContentType,
          ),
        ) {
    dio.interceptors.add(_AuthInterceptor());

    // Body sengaja tidak dicatat: isinya memuat kata sandi dan token.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: false, responseBody: false),
      );
    }
  }

  static final ApiClient instance = ApiClient._();

  final Dio dio;
}

class _AuthInterceptor extends Interceptor {
  /// Semua endpoint di bawah /auth/ bersifat publik (login, daftar, OTP, reset).
  bool _isPublic(String path) => path.startsWith('/auth/');

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options.path)) {
      final token = await TokenStorage.instance.read();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final sessionExpired =
        err.response?.statusCode == 401 && !_isPublic(err.requestOptions.path);

    if (sessionExpired) {
      await TokenStorage.instance.clear();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
    handler.next(err);
  }
}
