import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Menyimpan token di Keychain (iOS) atau Keystore (Android),
/// bukan di SharedPreferences yang tidak terenkripsi.
class TokenStorage {
  TokenStorage._();

  static final TokenStorage instance = TokenStorage._();

  static const String _key = 'access_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    webOptions: WebOptions(dbName: 'yap_coffee_storage', publicKey: 'yap_coffee'),
  );

  Future<String?> read() => _storage.read(key: _key);

  Future<void> save(String token) => _storage.write(key: _key, value: token);

  Future<void> clear() => _storage.delete(key: _key);
}
