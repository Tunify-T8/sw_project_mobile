import '../entities/reply_entity.dart';
import '../repositories/engagement_repository.dart';

class AddReplyUsecase {
  final EngagementRepository repository;

  AddReplyUsecase(this.repository);

  Future<ReplyEntity> call({
    required String commentId,
    required String viewerId,
    required String text,
    String? parentUsername,
  }) {
    if (text.trim().isEmpty) throw ArgumentError('Reply text cannot be empty');
    return repository.addReply(
      commentId: commentId,
      viewerId: viewerId,
      text: text,
      parentUsername: parentUsername,
    );
  }
}
