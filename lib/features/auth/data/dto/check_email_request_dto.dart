/// Request body for POST /auth/check-email.
class CheckEmailRequestDto {
  final String email;
  const CheckEmailRequestDto({required this.email});
  Map<String, dynamic> toJson() => {'email': email};
}
