import '../entities/engagement_user_entity.dart';
import '../repositories/engagement_repository.dart';

class GetRepostersUsecase {
  final EngagementRepository repository;

  GetRepostersUsecase(this.repository);

  Future<List<EngagementUserEntity>> call({required String trackId}) {
    return repository.getReposters(trackId: trackId);
  }
}
