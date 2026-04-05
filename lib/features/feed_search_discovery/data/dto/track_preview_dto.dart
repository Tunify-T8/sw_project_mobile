import 'track_interaction_dto.dart';

class TrackPreviewDto {
  final String trackId;
  final String title;
  final String artistId;
  final String artistName; // tell backend
  final String? artistAvatar; // tell backend
  final bool artistVerified; // tell backend
  final bool isFollowingArtist; // tell backend
  final String? coverUrl; // tell backend
  final int duration;
  final int likesCount;
  final int repostsCount;
  final int commentsCount; // tell backend
  final String createdAt;
  final TrackInteractionDto interaction;

  TrackPreviewDto({
    required this.trackId,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.artistAvatar,
    required this.artistVerified,
    required this.isFollowingArtist,
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
      artistName:
          json['artist']?.toString() ?? json['artistName']?.toString() ?? '',
      artistAvatar: json['artistAvatar']?.toString(),
      artistVerified: json['artistVerified'] as bool? ?? false,
      isFollowingArtist: json['isFollowingArtist'] as bool? ?? true,
      coverUrl: json['coverUrl']?.toString(),
      duration:
          json['durationSeconds'] as int? ?? json['duration'] as int? ?? 0,
      likesCount: json['likesCount'] as int? ?? 0,
      repostsCount: json['repostsCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      interaction: TrackInteractionDto.fromJson(
        json['interaction'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
