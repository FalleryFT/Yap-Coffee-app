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
      return 'http://10.0.2.2:3000/api';
    }

    // iOS Simulator, desktop, dan web.
    return 'http://localhost:3000/api';
  }

  static const Duration timeout = Duration(seconds: 15);
}
