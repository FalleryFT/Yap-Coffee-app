import 'package:flutter/foundation.dart';

/// Pengaturan alamat API.
///
/// Mengganti alamat tanpa menyunting kode:
///   flutter run --dart-define=API_BASE_URL=https://api.contoh.com/api
class ApiConfig {
  ApiConfig._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;

    // Emulator Android memakai 10.0.2.2 untuk menjangkau localhost komputer.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000/api';
    }

    // iOS Simulator, desktop, dan web.
    return 'http://localhost:4000/api';
  }

  /// Alamat server tanpa akhiran /api, dipakai untuk berkas statis seperti foto menu.
  static String get origin {
    final base = baseUrl;
    return base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
  }

  /// URL foto menu yang diunggah admin, contoh: http://10.0.2.2:4000/uploads/menu/<berkas>
  static String menuImageUrl(String filename) => '$origin/uploads/menu/$filename';

  /// URL foto profil pelanggan, contoh: http://10.0.2.2:4000/uploads/avatars/<berkas>
  static String avatarUrl(String filename) => '$origin/uploads/avatars/$filename';

  static const Duration timeout = Duration(seconds: 15);
}
