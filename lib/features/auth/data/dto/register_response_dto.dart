/// Response shape for POST /auth/register.
///
/// The register endpoint returns basic user info only — no tokens.
/// Tokens are issued only after email verification (POST /auth/verify-email).
///
/// NOTE: This DTO is defined for completeness but is not currently parsed
/// in [AuthRepositoryImpl.register] because the registration success path
/// only needs to know the call succeeded (no response data is used).
/// If the backend later returns fields you need to display, parse this DTO
/// in the repository.
class RegisterResponseDto {
  /// Unique identifier assigned to the new account.
  final String id;

  /// The username submitted during registration.
  final String username;

  /// The email address submitted during registration.
  final String email;

  /// Optional avatar URL — null for newly registered accounts.
  final String? avatarUrl;

  /// Always false for a newly registered account (email not yet verified).
  final bool isVerified;

  const RegisterResponseDto({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.isVerified,
  });

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) {
    return RegisterResponseDto(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isVerified: json['isVerified'] as bool,
    );
  }
}
