/// Shared response shape for endpoints that return tokens + user.
///
/// Used by: POST /auth/verify-email, POST /auth/login (verified user).
class AuthResponseDto {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String username;
  final String email;
  final String role;
  final bool isVerified;
  final String? avatarUrl;

  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.isVerified,
    this.avatarUrl,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return AuthResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: user['id'] as String,
      username: user['username'] as String,
      email: user['email'] as String,
      role: user['role'] as String,
      isVerified: user['isVerified'] as bool,
      avatarUrl: user['avatar_url'] as String?,
    );
  }
}
