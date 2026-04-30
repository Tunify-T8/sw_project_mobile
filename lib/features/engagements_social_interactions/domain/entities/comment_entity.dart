import 'engagement_user_entity.dart';

class CommentEntity {
  final String id;
  final String trackId;
  final EngagementUserEntity user;
  final int? timestamp;
  final String text;
  final int likesCount;
  final int repliesCount;
  final bool isLiked;
  final DateTime createdAt;
  const CommentEntity({
    required this.id,
    required this.trackId,
    required this.user,
    this.timestamp,
    required this.text,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });
}
