import '../entities/comment_entity.dart';
import '../repositories/engagement_repository.dart';

class AddCommentUsecase {
  final EngagementRepository repository;

  AddCommentUsecase(this.repository);

  Future<CommentEntity> call({
    required String trackId,
    required String viewerId,
    int? timestamp,
    required String text,
  }) {
    if (text.trim().isEmpty) throw ArgumentError('Comment cannot be empty');
    return repository.addComment(
      trackId: trackId,
      viewerId: viewerId,
      timestamp: timestamp,
      text: text,
    );
  }
}
