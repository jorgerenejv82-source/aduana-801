import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveFielData({
    required String cerBase64,
    required String keyBase64,
    required String password,
  }) async {
    await _storage.write(key: 'fiel_cer', value: cerBase64);
    await _storage.write(key: 'fiel_key', value: keyBase64);
    await _storage.write(key: 'fiel_pwd', value: password);
  }

  static Future<Map<String, String?>> getFielData() async {
    return {
      'cer': await _storage.read(key: 'fiel_cer'),
      'key': await _storage.read(key: 'fiel_key'),
      'pwd': await _storage.read(key: 'fiel_pwd'),
    };
  }

  static Future<void> clearFielData() async {
    await _storage.delete(key: 'fiel_cer');
    await _storage.delete(key: 'fiel_key');
    await _storage.delete(key: 'fiel_pwd');
  }
}
