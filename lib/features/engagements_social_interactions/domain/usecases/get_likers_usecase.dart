import '../entities/engagement_user_entity.dart';
import '../repositories/engagement_repository.dart';

class GetLikersUsecase {
  final EngagementRepository repository;

  GetLikersUsecase(this.repository);

  Future<List<EngagementUserEntity>> call({required String trackId}) {
    return repository.getLikers(trackId: trackId);
  }
}
