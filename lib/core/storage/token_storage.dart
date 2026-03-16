import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';

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

  /// Saves the authenticated user so features can restore identity on restart.
  Future<void> saveUser(AuthUserEntity user) async {
    final payload = jsonEncode({
      'id': user.id,
      'email': user.email,
      'username': user.username,
      'role': user.role,
      'isVerified': user.isVerified,
      'avatarUrl': user.avatarUrl,
    });

    await _storage.write(key: StorageKeys.user, value: payload);
  }

  /// Saves the complete authenticated session in one call.
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required AuthUserEntity user,
  }) async {
    await saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await saveUser(user);
  }

  /// Returns stored access token.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  /// Returns stored refresh token.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  /// Returns the last authenticated user, if one was stored locally.
  Future<AuthUserEntity?> getUser() async {
    final raw = await _storage.read(key: StorageKeys.user);
    if (raw == null || raw.isEmpty) return null;

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return AuthUserEntity(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      role: json['role'] as String? ?? 'LISTENER',
      isVerified: json['isVerified'] as bool? ?? true,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Checks if a user is authenticated.
  Future<bool> hasAccessToken() async {
    final token = await _storage.read(key: StorageKeys.accessToken);

    return token != null && token.isNotEmpty;
  }

  /// Clears authentication tokens (logout).
  Future<void> clearTokens() async {
    await _storage.delete(key: StorageKeys.accessToken);

    await _storage.delete(key: StorageKeys.refreshToken);
  }

  /// Clears the stored user profile.
  Future<void> clearUser() async {
    await _storage.delete(key: StorageKeys.user);
  }

  /// Clears both tokens and user identity.
  Future<void> clearSession() async {
    await clearTokens();
    await clearUser();
  }
}
