import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda o JWT no armazenamento seguro do aparelho.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'auth_token';

  final FlutterSecureStorage _storage;

  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(String token) => _storage.write(key: _key, value: token);

  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {
      // Sem token guardado não há o que apagar.
    }
  }
}
