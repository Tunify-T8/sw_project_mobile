import '../entities/track_engagement_entity.dart';
import '../repositories/engagement_repository.dart';

class GetTrackEngagementUsecase {
  final EngagementRepository repository;

  GetTrackEngagementUsecase(this.repository);

  Future<TrackEngagementEntity> call({required String trackId}) {
    return repository.getTrackEngagement(trackId: trackId);
  }
}
