class SubscribeResponseDto {
  final String message;

  SubscribeResponseDto({
    required this.message,
  });

  factory SubscribeResponseDto.fromJson(Map<String, dynamic> json) {
    return SubscribeResponseDto(
      message: json['message'] ?? '',
    );
  }
}