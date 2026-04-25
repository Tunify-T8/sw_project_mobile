import '../entities/track_engagement_entity.dart';
import '../repositories/engagement_repository.dart';

class RemoveRepostUsecase {
  final EngagementRepository repository;

  RemoveRepostUsecase(this.repository);

  Future<TrackEngagementEntity> call({required String trackId, required String viewerId}) {
    return repository.removeRepost(trackId: trackId, viewerId: viewerId);
  }
}
