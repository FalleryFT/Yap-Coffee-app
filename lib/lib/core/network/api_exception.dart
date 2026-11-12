import 'package:dio/dio.dart';

/// Galat yang sudah "dimanusiakan": pesan berbahasa Indonesia dan galat per kolom.
/// UI cukup menangkap ApiException dan tidak perlu mengenal DioException.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
  });

  final String message;
  final int? statusCode;

  /// Galat validasi per kolom, contoh: {'email': ['Email sudah terdaftar.']}
  final Map<String, List<String>> fieldErrors;

  /// Pesan galat pertama untuk sebuah kolom, atau null bila tidak ada.
  String? errorFor(String field) {
    final list = fieldErrors[field];
    return (list == null || list.isEmpty) ? null : list.first;
  }

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          'Server terlalu lama merespons. Coba lagi sebentar lagi.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet kamu.',
        );
      case DioExceptionType.badResponse:
        return _fromResponse(e.response);
      case DioExceptionType.cancel:
        return const ApiException('Permintaan dibatalkan.');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const ApiException('Terjadi kesalahan yang tidak terduga.');
    }
  }

  static ApiException _fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode;
    final data = response?.data;

    String? message;
    final errors = <String, List<String>>{};

    if (data is Map<String, dynamic>) {
      final rawMessage = data['message'];
      if (rawMessage is String && rawMessage.isNotEmpty) message = rawMessage;

      final rawErrors = data['errors'];
      if (rawErrors is Map) {
        rawErrors.forEach((key, value) {
          if (value is List) {
            errors[key.toString()] = value.map((e) => e.toString()).toList();
          } else if (value is String) {
            errors[key.toString()] = [value];
          }
        });
      }
    }

    return ApiException(
      message ?? _defaultMessage(status),
      statusCode: status,
      fieldErrors: errors,
    );
  }

  static String _defaultMessage(int? status) {
    if (status == 401) {
      return 'Autentikasi gagal. Periksa data kamu lalu coba lagi.';
    }
    if (status == 403) return 'Kamu tidak punya izin untuk tindakan ini.';
    if (status == 422) return 'Data yang dikirim belum valid.';
    if (status == 429) {
      return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
    }
    if (status != null && status >= 500) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }

  @override
  String toString() => message;
}
