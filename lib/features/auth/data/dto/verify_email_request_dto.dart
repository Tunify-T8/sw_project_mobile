/// Request body for POST /auth/verify-email.
class VerifyEmailRequestDto {
  final String email;

  /// 6-character uppercase token from the verification email.
  final String token;

  const VerifyEmailRequestDto({required this.email, required this.token});

  Map<String, dynamic> toJson() => {'email': email, 'token': token};
}
