import '../entities/reposted_track_entity.dart';
import '../repositories/engagement_repository.dart';

/// Fetches the list of tracks reposted by a user.
/// [userId] null  → GET /users/me/reposts  (current user)
/// [userId] non-null → GET /users/{userId}/reposts  (another user)
class GetUserRepostsUsecase {
  final EngagementRepository repository;

  GetUserRepostsUsecase(this.repository);

  Future<List<RepostedTrackEntity>> call({String? userId}) {
    return repository.getUserReposts(userId: userId);
  }
}
