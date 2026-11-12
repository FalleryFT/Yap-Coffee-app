import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/validators.dart';
import '../../auth/data/auth_models.dart';

class ProfileRepository {
  ProfileRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  /// Nama dan nomor ponsel. Email tidak bisa diubah dari aplikasi.
  Future<UserProfile> update({required String name, required String phone}) {
    return _guard(() async {
      final res = await _dio.put<Map<String, dynamic>>(
        '/me',
        data: {'name': name, 'phone': Validators.toInternationalPhone(phone)},
      );
      return UserProfile.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  /// Mengunggah foto profil. Server menentukan format (JPG, PNG, WebP) dari isi berkas.
  Future<UserProfile> uploadAvatar(Uint8List bytes) {
    return _guard(() async {
      final form = FormData.fromMap({
        'image': MultipartFile.fromBytes(bytes, filename: 'avatar'),
      });
      final res = await _dio.put<Map<String, dynamic>>(
        '/me/avatar',
        data: form,
        options: Options(sendTimeout: const Duration(seconds: 60)),
      );
      return UserProfile.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  /// Menghapus foto profil (kembali ke foto bawaan).
  Future<UserProfile> removeAvatar() {
    return _guard(() async {
      final res = await _dio.delete<Map<String, dynamic>>('/me/avatar');
      return UserProfile.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return _guard(() async {
      await _dio.post<dynamic>(
        '/me/change-password',
        data: {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    });
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on TypeError {
      throw const ApiException('Format respons server tidak sesuai.');
    }
  }
}
