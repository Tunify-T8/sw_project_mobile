import '../repositories/engagement_repository.dart';

class ToggleCommentLikeUsecase {
  final EngagementRepository repository;

  ToggleCommentLikeUsecase(this.repository);

  Future<void> call({required String commentId, required bool isCurrentlyLiked}) {
    return repository.toggleCommentLike(
      commentId: commentId,
      isCurrentlyLiked: isCurrentlyLiked,
    );
  }
}
