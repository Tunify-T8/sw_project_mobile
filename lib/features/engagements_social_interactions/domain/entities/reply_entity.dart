import 'engagement_user_entity.dart';

class ReplyEntity {
  final String id;
  final String commentId;
  final EngagementUserEntity user;
  final String? parentUsername;
  final String text;
  final int likesCount;
  final bool isLikedByViewer; // engagement addition — viewer's like state, persisted in store
  final DateTime createdAt;
  const ReplyEntity({
    required this.id,
    required this.commentId,
    required this.user,
    this.parentUsername,
    required this.text,
    this.likesCount = 0,
    this.isLikedByViewer = false, // engagement addition
    required this.createdAt,
  });
}
