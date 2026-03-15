class UploadItemDto {
  final String id;
  final String title;
  final List<String> artists;
  final int durationSeconds;
  final String? artworkUrl;
  final String privacy;
  final String status;
  final bool contentWarning;
  final String createdAt;

  const UploadItemDto({
    required this.id,
    required this.title,
    required this.artists,
    required this.durationSeconds,
    required this.artworkUrl,
    required this.privacy,
    required this.status,
    required this.contentWarning,
    required this.createdAt,
  });

  factory UploadItemDto.fromJson(Map<String, dynamic> json) {
    return UploadItemDto(
      id: json['trackId'] as String,
      title: (json['title'] as String?) ?? '',
      artists: ((json['artists'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      artworkUrl: json['artworkUrl'] as String?,
      privacy: (json['privacy'] as String?) ?? 'private',
      status: (json['status'] as String?) ?? 'finished',
      contentWarning: (json['contentWarning'] as bool?) ?? false,
      createdAt: (json['createdAt'] as String?) ??
          DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': id,
      'title': title,
      'artists': artists,
      'durationSeconds': durationSeconds,
      'artworkUrl': artworkUrl,
      'privacy': privacy,
      'status': status,
      'contentWarning': contentWarning,
      'createdAt': createdAt,
    };
  }

  UploadItemDto copyWith({
    String? id,
    String? title,
    List<String>? artists,
    int? durationSeconds,
    String? artworkUrl,
    String? privacy,
    String? status,
    bool? contentWarning,
    String? createdAt,
  }) {
    return UploadItemDto(
      id: id ?? this.id,
      title: title ?? this.title,
      artists: artists ?? this.artists,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      privacy: privacy ?? this.privacy,
      status: status ?? this.status,
      contentWarning: contentWarning ?? this.contentWarning,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}