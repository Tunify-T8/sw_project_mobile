import '../../domain/entities/track_interaction_entity.dart';
import '../dto/track_interaction_dto.dart';

extension TrackInteractionMapper on TrackInteractionDto {
  TrackInteractionEntity toEntity() {
    return TrackInteractionEntity(
      isLiked: isLiked,
      isReposted: isReposted,
    );
  }
}