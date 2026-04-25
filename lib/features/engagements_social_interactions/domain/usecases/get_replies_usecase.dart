import '../entities/reply_entity.dart';
import '../repositories/engagement_repository.dart';

class GetRepliesUsecase {
  final EngagementRepository repository;

  GetRepliesUsecase(this.repository);

  Future<List<ReplyEntity>> call({required String commentId}) {
    return repository.getReplies(commentId: commentId);
  }
}
