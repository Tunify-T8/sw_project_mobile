import '../entities/liked_track_entity.dart';
import '../repositories/engagement_repository.dart';

/// Fetches the list of tracks liked by a viewer.
/// On a real backend this calls GET /users/me/likes
class GetLikedTracksUsecase {
  final EngagementRepository repository;

  GetLikedTracksUsecase(this.repository);

  Future<List<LikedTrackEntity>> call({required String viewerId}) {
    return repository.getLikedTracks(viewerId: viewerId);
  }
}
