/// Handles storing and retrieving authentication tokens
/// used for authenticated API requests.
///
/// Token storage will later be implemented using
/// secure storage to persist login sessions.
class TokenStorage {
  /// Access Token
  String? _accessToken;

  /// Refresh Token
  String? _refreshToken;

  /// Saves authentication tokens.
  void saveTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  /// Returns stored access token.
  String? get accessToken => _accessToken;

  /// Returns stored refresh token.
  String? get refreshToken => _refreshToken;

  /// Clears stored authentication tokens.
  void clearToekns() {
    _accessToken = null;
    _refreshToken = null;
  }
}
