import '../repositories/engagement_repository.dart';

class DeleteCommentUsecase {
  final EngagementRepository repository;
  DeleteCommentUsecase(this.repository);

  Future<void> call({required String trackId, required String commentId}) {
    return repository.deleteComment(trackId: trackId, commentId: commentId);
  }
}
