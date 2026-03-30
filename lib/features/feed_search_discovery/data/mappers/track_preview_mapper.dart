import '../../domain/entities/track_preview_entity.dart';
import '../dto/track_preview_dto.dart';
import 'track_interaction_mapper.dart';

extension TrackPreviewMapper on TrackPreviewDto {
  TrackPreviewEntity toEntity() {
    return TrackPreviewEntity(
      trackId: trackId,
      title: title,
      artistId: artistId,
      artistName: artistName,
      artistAvatar: artistAvatar,
      coverUrl: coverUrl, 
      duration: duration,
      likesCount: likesCount,
      commentsCount: commentsCount,
      createdAt: createdAt,
      interaction: interaction.toEntity(),
    );
  }
}