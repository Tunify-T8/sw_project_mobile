import 'engagement_user_dto.dart';

class ReplyDto {
  const ReplyDto({
    required this.id,
    required this.commentId,
    required this.user,
    this.parentUsername,
    required this.text,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.isLikedByViewer = false, // engagement addition — persists like state in store
    required this.createdAt,
  });

  final String id;
  final String commentId;
  final EngagementUserDto user;
  final String? parentUsername; // null = reply to comment, non-null = reply to reply
  final String text;
  final int likesCount;
  final int repliesCount;
  final bool isLikedByViewer; // engagement addition — true if current viewer has liked this reply
  final DateTime createdAt;

  factory ReplyDto.fromJson(Map<String, dynamic> json) {
    return ReplyDto(
      id: (json['replyId'] as String?) ?? (json['id'] as String?) ?? '',
      commentId: (json['commentId'] as String?) ?? '',
      user: EngagementUserDto.fromJson(
        (json['author'] as Map<String, dynamic>?) ??
            (json['user'] as Map<String, dynamic>?) ??
            <String, dynamic>{},
      ),
      parentUsername: json['parentUsername'] as String?,
      text: (json['text'] as String?) ?? '',
      likesCount: (json['likesCount'] as int?) ?? 0,
      repliesCount: (json['repliesCount'] as int?) ?? 0,
      isLikedByViewer: (json['isLikedByViewer'] as bool?) ?? false, // engagement addition
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'replyId': id,
      'commentId': commentId,
      'author': user.toJson(),
      'parentUsername': parentUsername,
      'text': text,
      'likesCount': likesCount,
      'repliesCount': repliesCount,
      'isLikedByViewer': isLikedByViewer, // engagement addition
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
