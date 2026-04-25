import '../entities/reply_entity.dart';
import '../repositories/engagement_repository.dart';

class ToggleReplyLikeUsecase {
  final EngagementRepository repository;

  ToggleReplyLikeUsecase(this.repository);

  Future<ReplyEntity> call({
    required String commentId,
    required String replyId,
    required String viewerId,
  }) {
    return repository.toggleReplyLike(
      commentId: commentId,
      replyId: replyId,
      viewerId: viewerId,
    );
  }
}
