import 'track_interaction_entity.dart';

class TrackPreviewEntity {
  final String trackId;
  final String title;
  final String artistId;
  final String artistName;
  final String? coverUrl;
  final int duration;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final TrackInteractionEntity interaction;

  TrackPreviewEntity({
    required this.trackId,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.coverUrl,
    required this.duration,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.interaction,
  });

  TrackPreviewEntity copyWith({
  String? trackId,
  String? title,
  String? artistId,
  String? artistName,
  String? coverUrl,
  int? duration,
  int? likesCount,
  int? commentsCount,
  DateTime? createdAt,
  TrackInteractionEntity? interaction,
}) {
  return TrackPreviewEntity(
    trackId: trackId ?? this.trackId,
    title: title ?? this.title,
    artistId: artistId ?? this.artistId,
    artistName: artistName ?? this.artistName,
    coverUrl: coverUrl ?? this.coverUrl,
    duration: duration ?? this.duration,
    likesCount: likesCount ?? this.likesCount,
    commentsCount: commentsCount ?? this.commentsCount,
    createdAt: createdAt ?? this.createdAt,
    interaction: interaction ?? this.interaction,
  );
}
}