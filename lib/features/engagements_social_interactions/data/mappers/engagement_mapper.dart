import '../dto/comment_dto.dart';
import '../dto/engagement_user_dto.dart';
import '../dto/reply_dto.dart';
import '../dto/track_engagement_dto.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/comments_page_entity.dart';
import '../../domain/entities/engagement_user_entity.dart';
import '../../domain/entities/reply_entity.dart';
import '../../domain/entities/track_engagement_entity.dart';

class EngagementMapper {
  //JSON and DTO

  static List<Map<String, dynamic>> commentsToJson(List<CommentDto> comments) {
    return comments.map((e) => e.toJson()).toList();
  }

  static List<CommentDto> commentsFromJson(List<Map<String, dynamic>> data) {
    return data.map(CommentDto.fromJson).toList();
  }

  static List<Map<String, dynamic>> usersToJson(List<EngagementUserDto> users) {
    return users.map((e) => e.toJson()).toList();
  }

  static List<EngagementUserDto> usersFromJson(List<Map<String, dynamic>> data) {
    return data.map(EngagementUserDto.fromJson).toList();
  }

  static TrackEngagementDto engagementFromJson(Map<String, dynamic> data) {
    return TrackEngagementDto.fromJson(data);
  }

  static Map<String, dynamic> engagementToJson(TrackEngagementDto dto) {
    return dto.toJson();
  }

  // ── DTO → Entity ─────────────────────────────────────────────────────────────

  static EngagementUserEntity toUserEntity(EngagementUserDto dto) {
    return EngagementUserEntity(
      id: dto.id,
      displayName: dto.displayName,
      avatarUrl: dto.avatarUrl,
    );
  }

  static TrackEngagementEntity toTrackEngagementEntity(TrackEngagementDto dto) {
    return TrackEngagementEntity(
      trackId: dto.trackId,
      likeCount: dto.likeCount,
      repostCount: dto.repostCount,
      commentCount: dto.commentCount,
      isLiked: dto.isLiked,
      isReposted: dto.isReposted,
    );
  }

  static CommentEntity toCommentEntity(CommentDto dto) {
    return CommentEntity(
      id: dto.id,
      trackId: dto.trackId,
      user: toUserEntity(dto.user),
      timestamp: dto.timestamp,
      text: dto.text,
      likesCount: dto.likesCount,
      repliesCount: dto.repliesCount,
      createdAt: dto.createdAt,
    );
  }

  static List<EngagementUserEntity> toUserEntityList(List<EngagementUserDto> dtos) {
    return dtos.map(toUserEntity).toList();
  }

  static List<CommentEntity> toCommentEntityList(List<CommentDto> dtos) {
    return dtos.map(toCommentEntity).toList();
  }

  static CommentsPageEntity toCommentsPageEntity(List<CommentDto> dtos, {int? total}) {
    final comments = toCommentEntityList(dtos);
    return CommentsPageEntity(
      comments: comments,
      meta: CommentsPageMetaEntity(
        totalCount: total ?? comments.length,
        page: 1,
        totalPages: 1,
        hasNextPage: false,
      ),
    );
  }

  static ReplyEntity toReplyEntity(ReplyDto dto) {
    return ReplyEntity(
      id: dto.id,
      commentId: dto.commentId,
      user: toUserEntity(dto.user),
      parentUsername: dto.parentUsername,
      text: dto.text,
      likesCount: dto.likesCount,
      isLikedByViewer: dto.isLikedByViewer, // engagement addition — carry like state through to entity
      createdAt: dto.createdAt,
    );
  }

  static List<ReplyEntity> toReplyEntityList(List<ReplyDto> dtos) {
    return dtos.map(toReplyEntity).toList();
  }
}
