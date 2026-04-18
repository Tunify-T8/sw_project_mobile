import '../entities/track_engagement_entity.dart';
import '../repositories/engagement_repository.dart';

class RepostTrackUsecase {
  final EngagementRepository repository;

  RepostTrackUsecase(this.repository);

  Future<TrackEngagementEntity> call({required String trackId, required String viewerId, String? caption}) {
    return repository.repostTrack(trackId: trackId, viewerId: viewerId, caption: caption);
  }
}
