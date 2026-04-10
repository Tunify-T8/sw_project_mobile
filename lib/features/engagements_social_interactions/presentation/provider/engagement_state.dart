import '../../domain/entities/track_engagement_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/comments_page_entity.dart';
import '../../domain/entities/engagement_user_entity.dart';

enum EngagementStatus { initial, loading, success, error }

class EngagementState {
  final TrackEngagementEntity? engagement;
  final CommentsPageEntity? commentsPage;
  final List<EngagementUserEntity> likers;
  final List<EngagementUserEntity> reposters;
  final Set<String> likedCommentIds;
  final EngagementStatus engagementStatus;
  final EngagementStatus commentsStatus;
  final EngagementStatus likersStatus;
  final EngagementStatus repostersStatus;
  final String? error;

  const EngagementState({
    this.engagement,
    this.commentsPage,
    this.likers = const [],
    this.reposters = const [],
    this.likedCommentIds = const {},
    this.engagementStatus = EngagementStatus.initial,
    this.commentsStatus = EngagementStatus.initial,
    this.likersStatus = EngagementStatus.initial,
    this.repostersStatus = EngagementStatus.initial,
    this.error,
  });

  List<CommentEntity> get comments => commentsPage?.comments ?? const [];
  bool get hasNextCommentsPage => commentsPage?.meta.hasNextPage ?? false;
  int get totalCommentsCount => commentsPage?.meta.totalCount ?? 0;

  bool isCommentLiked(String commentId) => likedCommentIds.contains(commentId);

  EngagementState copyWith({
    TrackEngagementEntity? engagement,
    CommentsPageEntity? commentsPage,
    List<EngagementUserEntity>? likers,
    List<EngagementUserEntity>? reposters,
    Set<String>? likedCommentIds,
    EngagementStatus? engagementStatus,
    EngagementStatus? commentsStatus,
    EngagementStatus? likersStatus,
    EngagementStatus? repostersStatus,
    String? error,
  }) {
    return EngagementState(
      engagement: engagement ?? this.engagement,
      commentsPage: commentsPage ?? this.commentsPage,
      likers: likers ?? this.likers,
      reposters: reposters ?? this.reposters,
      likedCommentIds: likedCommentIds ?? this.likedCommentIds,
      engagementStatus: engagementStatus ?? this.engagementStatus,
      commentsStatus: commentsStatus ?? this.commentsStatus,
      likersStatus: likersStatus ?? this.likersStatus,
      repostersStatus: repostersStatus ?? this.repostersStatus,
      error: error,
    );
  }

  bool get isLoading => engagementStatus == EngagementStatus.loading;
  bool get isSuccess => engagementStatus == EngagementStatus.success;
  bool get isError => engagementStatus == EngagementStatus.error;
}
