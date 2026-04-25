import '../entities/track_engagement_entity.dart';
import '../repositories/engagement_repository.dart';

class ToggleLikeUsecase {
  final EngagementRepository repository;

  ToggleLikeUsecase(this.repository);

  Future<TrackEngagementEntity> call({required String trackId, required String viewerId}) {
    return repository.toggleLike(trackId: trackId, viewerId: viewerId);
  }
}
