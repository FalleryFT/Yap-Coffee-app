import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import 'auth_models.dart';

/// Satu-satunya tempat yang tahu alamat endpoint autentikasi.
/// Halaman (UI) hanya memanggil method di sini dan menangkap ApiException.
class AuthRepository {
  AuthRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return _saveSession(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) {
    return _guard(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return _saveSession(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<void> sendOtp({required String email}) {
    return _guard(() async {
      await _dio.post<dynamic>(
        '/auth/forgot-password/send-otp',
        data: {'email': email},
      );
    });
  }

  /// Mengembalikan reset_token yang dipakai pada langkah ganti sandi.
  Future<String> verifyOtp({required String email, required String otp}) {
    return _guard(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/forgot-password/verify-otp',
        data: {'email': email, 'otp': otp},
      );
      final data = res.data!['data'] as Map<String, dynamic>;
      return data['reset_token'] as String;
    });
  }

  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) {
    return _guard(() async {
      await _dio.post<dynamic>(
        '/auth/reset-password',
        data: {
          'reset_token': resetToken,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    });
  }

  /// Contoh endpoint terlindungi: token dipasang otomatis oleh interceptor.
  Future<UserProfile> me() {
    return _guard(() async {
      final res = await _dio.get<Map<String, dynamic>>('/me');
      return UserProfile.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  /// Menghapus sesi di perangkat. Bila backend punya endpoint logout,
  /// panggil di sini sebelum menghapus token.
  Future<void> logout() => TokenStorage.instance.clear();

  Future<AuthResult> _saveSession(Map<String, dynamic> json) async {
    final result = AuthResult.fromJson(json);
    await TokenStorage.instance.save(result.token);
    return result;
  }

  /// Mengubah DioException menjadi ApiException di satu tempat.
  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on TypeError {
      // Bentuk JSON dari server tidak sesuai model.
      throw const ApiException('Format respons server tidak sesuai.');
    }
  }
}
