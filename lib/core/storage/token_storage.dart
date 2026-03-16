import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_keys.dart';

/// Handles secure storage of authentication tokens.
///
/// Uses [FlutterSecureStorage] which stores values
/// in encrypted storage:
/// - Android → EncryptedSharedPreferences
/// - iOS → Keychain
/// - Web → Secure local storage
class TokenStorage {
  const TokenStorage();

  /// Secure storage instance
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Saves authentication tokens securely.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);

    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
  }

  /// Returns stored access token.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  /// Returns stored refresh token.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  /// Checks if a user is authenticated.
  Future<bool> hasAccessToken() async {
    final token = await _storage.read(key: StorageKeys.accessToken);

    return token != null;
  }

  /// Clears authentication tokens (logout).
  Future<void> clearTokens() async {
    await _storage.delete(key: StorageKeys.accessToken);

    await _storage.delete(key: StorageKeys.refreshToken);
  }
}
