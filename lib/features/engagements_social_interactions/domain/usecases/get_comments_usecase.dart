import '../entities/comments_page_entity.dart';
import '../repositories/engagement_repository.dart';

class GetCommentsUsecase {
  final EngagementRepository repository;

  GetCommentsUsecase(this.repository);

  Future<CommentsPageEntity> call({required String trackId}) {
    return repository.getComments(trackId: trackId);
  }
}
