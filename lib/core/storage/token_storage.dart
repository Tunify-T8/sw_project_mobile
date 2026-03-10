/// Handles storing and retrieving authentication tokens
/// used for authenticated API requests.
///
/// Token storage will later be implemented using
/// secure storage to persist login sessions.
/// Flutter Secure Storage to maintain
/// authentication sessions across app restarts.
class TokenStorage {
  /// Stored access token used for authenticated requests.
  String? _accessToken;

  /// Stored refresh token used to obtain new access tokens.
  String? _refreshToken;

  /// Saves authentication tokens.
  ///
  /// Called after successful login or registration.
  void saveTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  /// Returns the currently stored access token.
  String? get accessToken => _accessToken;

  /// Returns the currently stored refresh token.
  String? get refreshToken => _refreshToken;

  /// Clears stored authentication tokens.
  ///
  /// Called during logout.
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }
}
