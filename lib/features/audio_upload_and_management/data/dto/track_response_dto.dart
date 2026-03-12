class TrackResponseDto {
  final String trackId;
  final String status;
  final String? audioUrl;
  final String? waveformUrl;
  final String? title;
  final String? description;
  final String? privacy;
  final String? artworkUrl;
  final int? durationSeconds;
  final String? errorCode;
  final String? errorMessage;

  TrackResponseDto({
    required this.trackId,
    required this.status,
    this.audioUrl,
    this.waveformUrl,
    this.title,
    this.description,
    this.privacy,
    this.artworkUrl,
    this.durationSeconds,
    this.errorCode,
    this.errorMessage,
  });

  factory TrackResponseDto.fromJson(Map<String, dynamic> json) {
    final error = json['error'];

    return TrackResponseDto(
      trackId: json['trackId'] as String,
      status: json['status'] as String,
      audioUrl: json['audioUrl'] as String?,
      waveformUrl: json['waveformUrl'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      privacy: json['privacy'] as String?,
      artworkUrl: json['artworkUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      errorCode: error is Map<String, dynamic> ? error['code'] as String? : null,
      errorMessage:
          error is Map<String, dynamic> ? error['message'] as String? : null,
    );
  }
}