
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
  });

  final String id;
  final String trackId;
  final EngagementUserDto user;
  final int? timestamp; // nullable — BE field is coming later
  final String text;
  final int likesCount;
  final int repliesCount;
  final DateTime createdAt;

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
