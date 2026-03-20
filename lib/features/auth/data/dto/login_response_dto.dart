/// Response from POST /auth/login.
///
/// Two possible outcomes:
/// - Verified user → [AuthResponseDto] with tokens.
/// - Unverified user → no tokens; [isVerified] is false.
class LoginResponseDto {
  final bool isVerified;

  /// Null when [isVerified] is false.
  final String? accessToken;
  final String? refreshToken;

  final String userId;
  final String username;
  final String email;
  final String? role;
  final String? avatarUrl;

  const LoginResponseDto({
    required this.isVerified,
    required this.userId,
    required this.username,
    required this.email,
    this.accessToken,
    this.refreshToken,
    this.role,
    this.avatarUrl,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return LoginResponseDto(
      isVerified: user['isVerified'] as bool,
      userId: user['id'] as String,
      username: user['username'] as String,
      email: user['email'] as String,
      role: user['role'] as String?,
      avatarUrl: user['avatar_url'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }
}
