import '../repositories/engagement_repository.dart';

class DeleteReplyUsecase {
  final EngagementRepository repository;
  DeleteReplyUsecase(this.repository);

  Future<void> call({required String commentId, required String replyId}) {
    return repository.deleteReply(commentId: commentId, replyId: replyId);
  }
}
