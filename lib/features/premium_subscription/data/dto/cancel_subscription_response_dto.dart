class CancelSubscriptionResponseDto {
  final String message;
  final String expiresAt;

  CancelSubscriptionResponseDto({
    required this.message,
    required this.expiresAt,
  });

  factory CancelSubscriptionResponseDto.fromJson(Map<String, dynamic> json) {
    return CancelSubscriptionResponseDto(
      message: json['message'],
      expiresAt: json['expiresAt'],
    );
  }
}