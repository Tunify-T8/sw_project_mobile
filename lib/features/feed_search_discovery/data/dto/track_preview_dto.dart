import 'track_interaction_dto.dart';

class TrackPreviewDto {
  final String trackId;
  final String title;
  final String artistId;
  final String artistName; //tell backend
  final String? artistAvatar; //tell backend
  final String? coverUrl; //tell backend
  final int duration;
  final int likesCount;
  final int repostsCount;
  final int commentsCount; //tell backend
  final String createdAt;
  final TrackInteractionDto interaction;

  TrackPreviewDto({
    required this.trackId,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.artistAvatar,
    this.coverUrl,
    required this.duration,
    required this.likesCount,
    required this.repostsCount,
    required this.commentsCount,
    required this.createdAt,
    required this.interaction,
  });

  factory TrackPreviewDto.fromJson(Map<String, dynamic> json) {
    return TrackPreviewDto(
      trackId: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      artistId: json['artistId']?.toString() ?? '',
      artistName: json['artistName']?.toString() ?? '',
      artistAvatar: json['artistAvatar']?.toString(),
      coverUrl: json['coverUrl']?.toString(),
      duration: json['duration'] as int,
      likesCount: json['likesCount'] as int,
      repostsCount: json['repostsCount'] as int,
      commentsCount: json['commentsCount'] as int,
      createdAt: json['createdAt']?.toString() ?? '',
      interaction: TrackInteractionDto.fromJson(json['interaction'] ?? {}),
    );
  }
}
