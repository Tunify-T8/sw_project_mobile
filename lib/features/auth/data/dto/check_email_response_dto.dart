/// Response body from POST /auth/check-email.
class CheckEmailResponseDto {
  /// Whether the email belongs to an existing account.
  final bool exists;

  /// Human-readable message for the UI.
  final String message;

  const CheckEmailResponseDto({required this.exists, required this.message});

  factory CheckEmailResponseDto.fromJson(Map<String, dynamic> json) {
    return CheckEmailResponseDto(
      exists: json['exists'] as bool,
      message: json['message'] as String,
    );
  }
}
