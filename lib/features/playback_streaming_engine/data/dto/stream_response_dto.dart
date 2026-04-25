class StreamResponseDto {
  final String trackId;
  final String url;
  final int expiresInSeconds;
  final String format;

  const StreamResponseDto({
    required this.trackId,
    required this.url,
    required this.expiresInSeconds,
    required this.format,
  });


  factory StreamResponseDto.fromJson(Map<String, dynamic> json, String trackId) {
    // Response shape: { trackId, stream: { url, expiresInSeconds, format } }
    final stream = json['stream'] as Map<String, dynamic>? ?? json;
    return StreamResponseDto(
      trackId: (json['trackId'] ?? trackId) as String,
      url: (stream['url'] ?? '') as String,
      expiresInSeconds: (stream['expiresInSeconds'] as int?) ?? 600,
      format: (stream['format'] ?? 'mp3') as String,
    );
  }
}
