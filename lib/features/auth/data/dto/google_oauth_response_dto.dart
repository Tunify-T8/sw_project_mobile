/// Response from POST /auth/google.
///
/// Two possible shapes based on the scenario:
///
/// Scenario 1 & 2 — New or returning Google user:
///   { accessToken, refreshToken, user: {...} }
///
/// Scenario 3 — Email already registered locally:
///   { requiresLinking: true, linkingToken: "..." }
///
/// Always check [requiresLinking] first before accessing token fields.
class GoogleOAuthResponseDto {
  /// True when the Google email is already registered with a local password.
  /// When true, [linkingToken] is populated and tokens are null.
  final bool requiresLinking;

  /// Short-lived JWT (10 minutes) used to complete account linking.
  /// Only populated when [requiresLinking] is true.
  final String? linkingToken;

  /// JWT access token. Only populated when [requiresLinking] is false.
  final String? accessToken;

  /// JWT refresh token. Only populated when [requiresLinking] is false.
  final String? refreshToken;

  /// User data. Only populated when [requiresLinking] is false.
  final GoogleOAuthUserDto? user;

  const GoogleOAuthResponseDto({
    required this.requiresLinking,
    this.linkingToken,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory GoogleOAuthResponseDto.fromJson(Map<String, dynamic> json) {
    final requiresLinking = json['requiresLinking'] as bool? ?? false;

    if (requiresLinking) {
      return GoogleOAuthResponseDto(
        requiresLinking: true,
        linkingToken: json['linkingToken'] as String?,
      );
    }

    final userJson = json['user'] as Map<String, dynamic>?;

    return GoogleOAuthResponseDto(
      requiresLinking: false,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      user: userJson != null ? GoogleOAuthUserDto.fromJson(userJson) : null,
    );
  }
}

/// User data returned inside the Google OAuth success response.
class GoogleOAuthUserDto {
  final String id;
  final String username;
  final String email;
  final String role;
  final bool isVerified;
  final String? avatarUrl;

  const GoogleOAuthUserDto({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isVerified,
    this.avatarUrl,
  });

  factory GoogleOAuthUserDto.fromJson(Map<String, dynamic> json) {
    return GoogleOAuthUserDto(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'LISTENER',
      isVerified: json['isVerified'] as bool? ?? true,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

/// Response from POST /auth/google/link (account linking).
///
/// Returns the same shape as a normal login on success.
/// Same as [AuthResponseDto] — user is now fully logged in.
class GoogleLinkResponseDto {
  final String accessToken;
  final String refreshToken;
  final GoogleOAuthUserDto user;

  const GoogleLinkResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory GoogleLinkResponseDto.fromJson(Map<String, dynamic> json) {
    return GoogleLinkResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: GoogleOAuthUserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
