import 'dart:convert';

import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';

import 'safe_secure_storage.dart';
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

  /// Saves authentication tokens securely.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await SafeSecureStorage.write(
      key: StorageKeys.accessToken,
      value: accessToken,
    );

    await SafeSecureStorage.write(
      key: StorageKeys.refreshToken,
      value: refreshToken,
    );
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

    await SafeSecureStorage.write(key: StorageKeys.user, value: payload);
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
    return await SafeSecureStorage.read(StorageKeys.accessToken);
  }

  /// Returns stored refresh token.
  Future<String?> getRefreshToken() async {
    return await SafeSecureStorage.read(StorageKeys.refreshToken);
  }

  /// Returns the last authenticated user, if one was stored locally.
  Future<AuthUserEntity?> getUser() async {
    final raw = await SafeSecureStorage.read(StorageKeys.user);
    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUserEntity(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        username: json['username'] as String? ?? '',
        role: json['role'] as String? ?? 'LISTENER',
        isVerified: json['isVerified'] as bool? ?? true,
        avatarUrl: json['avatarUrl'] as String?,
      );
    } catch (_) {
      await SafeSecureStorage.delete(StorageKeys.user);
      return null;
    }
  }

  /// Checks if a user is authenticated.
  Future<bool> hasAccessToken() async {
    final token = await SafeSecureStorage.read(StorageKeys.accessToken);

    return token != null && token.isNotEmpty;
  }

  /// Clears authentication tokens (logout).
  Future<void> clearTokens() async {
    await SafeSecureStorage.delete(StorageKeys.accessToken);

    await SafeSecureStorage.delete(StorageKeys.refreshToken);
  }

  /// Clears the stored user profile.
  Future<void> clearUser() async {
    await SafeSecureStorage.delete(StorageKeys.user);
  }

  /// Clears both tokens and user identity.
  Future<void> clearSession() async {
    await clearTokens();
    await clearUser();
    // NOTE: cachedListeningHistory is now stored under per-user keys
    // (e.g. "cached_listening_history_<userId>") so the bare key below is a
    // no-op for any user who signed in after the per-user scoping change. It
    // is kept only to clean up the old unscoped entry that may exist from
    // earlier app versions.
    await SafeSecureStorage.delete(StorageKeys.cachedListeningHistory);
    await SafeSecureStorage.delete(StorageKeys.historyClearedLocally);
    await SafeSecureStorage.delete(StorageKeys.historyClearedAt);
    await SafeSecureStorage.delete(StorageKeys.cachedPlayerSession);
    // cachedLibraryUploads is intentionally NOT deleted here. Each user's
    // uploads list is now stored under a per-user key
    // ("cached_library_uploads_<userId>"), so no cross-account leak occurs.
    // The bare key below is kept as a no-op cleanup for old app versions.
    await SafeSecureStorage.delete(StorageKeys.cachedLibraryUploads);

    // Offline play queues are tied to the signing-out user. Flushing them
    // under a different user's token would attribute plays incorrectly.
    // Clear both queues on logout so the next user starts with a clean slate.
    await SafeSecureStorage.delete(StorageKeys.pendingOfflinePlays);
    await SafeSecureStorage.delete(StorageKeys.pendingPlaybackEvents);
  }
}
