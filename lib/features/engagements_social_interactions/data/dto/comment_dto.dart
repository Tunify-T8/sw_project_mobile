
import 'engagement_user_dto.dart';

class CommentDto {
  const CommentDto({
    required this.id,
    required this.trackId,
    required this.user,
    this.timestamp,
    required this.text,
    this.likesCount = 0,
    this.repliesCount = 0,
    required this.createdAt,
    this.parentId,
  });

  final String id;
  final String trackId;
  final EngagementUserDto user;
  final int? timestamp;
  final String text;
  final int likesCount;
  final int repliesCount;
  final DateTime createdAt;
  final String? parentId; // non-null means this is a reply, not a top-level comment

  bool get isReply => parentId != null && parentId!.isNotEmpty;

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    return CommentDto(
      id: (json['commentId'] as String?) ?? (json['id'] as String?) ?? '',
      trackId: (json['trackId'] as String?) ?? '',
      user: EngagementUserDto.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      timestamp: (json['timestamp'] as int?) ?? (json['second'] as int?),
      text: (json['text'] as String?) ?? '',
      likesCount: (json['likesCount'] as int?) ?? 0,
      repliesCount: (json['repliesCount'] as int?) ?? 0,
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      parentId: json['parentId'] as String? ?? json['parentCommentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': id,
      'trackId': trackId,
      'user': user.toJson(),
      'timestamp': timestamp,
      'text': text,
      'likesCount': likesCount,
      'repliesCount': repliesCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
