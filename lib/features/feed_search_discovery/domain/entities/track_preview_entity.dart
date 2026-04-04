import 'track_interaction_entity.dart';

class TrackPreviewEntity {
  final String trackId;
  final String title;
  final String artistId;
  final String artistName;
  final String? artistAvatar;
  final bool artistVerified;
  final bool? isFollowingArtist;
  final String? coverUrl;
  final int duration;
  final int? listensCount;
  final int likesCount;
  final int repostsCount;
  final int commentsCount;
  final String createdAt;
  final TrackInteractionEntity interaction;

  TrackPreviewEntity({
    required this.trackId,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.artistAvatar,
    required this.artistVerified,
    this.isFollowingArtist = true,
    this.coverUrl,
    required this.duration,
    this.listensCount,
    required this.likesCount,
    required this.repostsCount,
    required this.commentsCount,
    required this.createdAt,
    required this.interaction,
  });

  TrackPreviewEntity copyWith({
    String? trackId,
    String? title,
    String? artistId,
    String? artistName,
    String? artistAvatar,
    bool? artistVerified,
    bool? isFollowingArtist,
    String? coverUrl,
    int? duration,
    int? listensCount,
    int? likesCount,
    int? repostsCount,
    int? commentsCount,
    String? createdAt,
    TrackInteractionEntity? interaction,
  }) {
    return TrackPreviewEntity(
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      artistAvatar: artistAvatar ?? this.artistAvatar,
      artistVerified: artistVerified ?? this.artistVerified,
      isFollowingArtist: isFollowingArtist ?? this.isFollowingArtist,
      coverUrl: coverUrl ?? this.coverUrl,
      duration: duration ?? this.duration,
      listensCount: listensCount ?? this.listensCount,
      likesCount: likesCount ?? this.likesCount,
      repostsCount: repostsCount ?? this.repostsCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      interaction: interaction ?? this.interaction,
    );
  }
}
