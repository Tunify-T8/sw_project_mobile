import 'package:mockito/mockito.dart';
import 'package:software_project/features/engagements_social_interactions/domain/entities/comment_entity.dart';
import 'package:software_project/features/engagements_social_interactions/domain/entities/comments_page_entity.dart';
import 'package:software_project/features/engagements_social_interactions/domain/entities/engagement_user_entity.dart';
import 'package:software_project/features/engagements_social_interactions/domain/entities/liked_track_entity.dart';
import 'package:software_project/features/engagements_social_interactions/domain/entities/reply_entity.dart';
import 'package:software_project/features/engagements_social_interactions/domain/entities/reposted_track_entity.dart';
import 'package:software_project/features/engagements_social_interactions/domain/entities/track_engagement_entity.dart';
import 'package:software_project/features/engagements_social_interactions/domain/repositories/engagement_repository.dart';

const kTrackId = 'track-1';
const kViewerId = 'user-1';
const kCommentId = 'comment-1';
const kReplyId = 'reply-1';

TrackEngagementEntity dummyEngagement({
  String trackId = kTrackId,
  int likeCount = 5,
  int repostCount = 2,
  int commentCount = 3,
  bool isLiked = false,
  bool isReposted = false,
}) =>
    TrackEngagementEntity(
      trackId: trackId,
      likeCount: likeCount,
      repostCount: repostCount,
      commentCount: commentCount,
      isLiked: isLiked,
      isReposted: isReposted,
    );

const dummyUser = EngagementUserEntity(
  id: kViewerId,
  displayName: 'Test User',
);

CommentEntity dummyComment({
  String id = kCommentId,
  int likesCount = 0,
  bool isLiked = false,
  int repliesCount = 0,
}) =>
    CommentEntity(
      id: id,
      trackId: kTrackId,
      user: dummyUser,
      text: 'Great track!',
      likesCount: likesCount,
      isLiked: isLiked,
      repliesCount: repliesCount,
      createdAt: DateTime(2026, 1, 1),
    );

ReplyEntity dummyReply({
  String id = kReplyId,
  bool isLikedByViewer = false,
}) =>
    ReplyEntity(
      id: id,
      commentId: kCommentId,
      user: dummyUser,
      text: 'Nice!',
      isLikedByViewer: isLikedByViewer,
      createdAt: DateTime(2026, 1, 1),
    );

CommentsPageEntity dummyCommentsPage({List<CommentEntity>? comments}) =>
    CommentsPageEntity(
      comments: comments ?? [dummyComment()],
      meta: const CommentsPageMetaEntity(
        totalCount: 1,
        page: 1,
        totalPages: 1,
        hasNextPage: false,
      ),
    );

class MockEngagementRepository extends Mock implements EngagementRepository {
  @override
  Future<TrackEngagementEntity> getTrackEngagement({required String trackId}) {
    return super.noSuchMethod(
      Invocation.method(#getTrackEngagement, [], {#trackId: trackId}),
      returnValue: Future.value(dummyEngagement()),
      returnValueForMissingStub: Future.value(dummyEngagement()),
    ) as Future<TrackEngagementEntity>;
  }

  @override
  Future<TrackEngagementEntity> toggleLike({
    required String trackId,
    required String viewerId,
  }) {
    return super.noSuchMethod(
      Invocation.method(#toggleLike, [], {#trackId: trackId, #viewerId: viewerId}),
      returnValue: Future.value(dummyEngagement(isLiked: true, likeCount: 6)),
      returnValueForMissingStub: Future.value(dummyEngagement(isLiked: true, likeCount: 6)),
    ) as Future<TrackEngagementEntity>;
  }

  @override
  Future<TrackEngagementEntity> repostTrack({
    required String trackId,
    required String viewerId,
    String? caption,
  }) {
    return super.noSuchMethod(
      Invocation.method(#repostTrack, [], {
        #trackId: trackId,
        #viewerId: viewerId,
        #caption: caption,
      }),
      returnValue: Future.value(dummyEngagement(isReposted: true, repostCount: 3)),
      returnValueForMissingStub:
          Future.value(dummyEngagement(isReposted: true, repostCount: 3)),
    ) as Future<TrackEngagementEntity>;
  }

  @override
  Future<TrackEngagementEntity> removeRepost({
    required String trackId,
    required String viewerId,
  }) {
    return super.noSuchMethod(
      Invocation.method(#removeRepost, [], {#trackId: trackId, #viewerId: viewerId}),
      returnValue: Future.value(dummyEngagement()),
      returnValueForMissingStub: Future.value(dummyEngagement()),
    ) as Future<TrackEngagementEntity>;
  }

  @override
  Future<CommentsPageEntity> getComments({required String trackId}) {
    return super.noSuchMethod(
      Invocation.method(#getComments, [], {#trackId: trackId}),
      returnValue: Future.value(dummyCommentsPage()),
      returnValueForMissingStub: Future.value(dummyCommentsPage()),
    ) as Future<CommentsPageEntity>;
  }

  @override
  Future<CommentEntity> addComment({
    required String trackId,
    required String viewerId,
    int? timestamp,
    required String text,
  }) {
    return super.noSuchMethod(
      Invocation.method(#addComment, [], {
        #trackId: trackId,
        #viewerId: viewerId,
        #timestamp: timestamp,
        #text: text,
      }),
      returnValue: Future.value(dummyComment()),
      returnValueForMissingStub: Future.value(dummyComment()),
    ) as Future<CommentEntity>;
  }

  @override
  Future<List<ReplyEntity>> getReplies({required String commentId}) {
    return super.noSuchMethod(
      Invocation.method(#getReplies, [], {#commentId: commentId}),
      returnValue: Future.value([dummyReply()]),
      returnValueForMissingStub: Future.value([dummyReply()]),
    ) as Future<List<ReplyEntity>>;
  }

  @override
  Future<ReplyEntity> addReply({
    required String commentId,
    required String viewerId,
    required String text,
    String? parentUsername,
  }) {
    return super.noSuchMethod(
      Invocation.method(#addReply, [], {
        #commentId: commentId,
        #viewerId: viewerId,
        #text: text,
        #parentUsername: parentUsername,
      }),
      returnValue: Future.value(dummyReply()),
      returnValueForMissingStub: Future.value(dummyReply()),
    ) as Future<ReplyEntity>;
  }

  @override
  Future<void> deleteComment({
    required String trackId,
    required String commentId,
  }) {
    return super.noSuchMethod(
      Invocation.method(#deleteComment, [], {
        #trackId: trackId,
        #commentId: commentId,
      }),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<void> deleteReply({
    required String commentId,
    required String replyId,
  }) {
    return super.noSuchMethod(
      Invocation.method(#deleteReply, [], {
        #commentId: commentId,
        #replyId: replyId,
      }),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<void> toggleCommentLike({
    required String commentId,
    required bool isCurrentlyLiked,
  }) {
    return super.noSuchMethod(
      Invocation.method(#toggleCommentLike, [], {
        #commentId: commentId,
        #isCurrentlyLiked: isCurrentlyLiked,
      }),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<ReplyEntity> toggleReplyLike({
    required String commentId,
    required String replyId,
    required String viewerId,
  }) {
    return super.noSuchMethod(
      Invocation.method(#toggleReplyLike, [], {
        #commentId: commentId,
        #replyId: replyId,
        #viewerId: viewerId,
      }),
      returnValue: Future.value(dummyReply(isLikedByViewer: true)),
      returnValueForMissingStub: Future.value(dummyReply(isLikedByViewer: true)),
    ) as Future<ReplyEntity>;
  }

  @override
  Future<List<EngagementUserEntity>> getLikers({required String trackId}) {
    return super.noSuchMethod(
      Invocation.method(#getLikers, [], {#trackId: trackId}),
      returnValue: Future.value([dummyUser]),
      returnValueForMissingStub: Future.value([dummyUser]),
    ) as Future<List<EngagementUserEntity>>;
  }

  @override
  Future<List<EngagementUserEntity>> getReposters({required String trackId}) {
    return super.noSuchMethod(
      Invocation.method(#getReposters, [], {#trackId: trackId}),
      returnValue: Future.value([dummyUser]),
      returnValueForMissingStub: Future.value([dummyUser]),
    ) as Future<List<EngagementUserEntity>>;
  }

  @override
  Future<List<LikedTrackEntity>> getLikedTracks({required String viewerId}) {
    return super.noSuchMethod(
      Invocation.method(#getLikedTracks, [], {#viewerId: viewerId}),
      returnValue: Future.value(<LikedTrackEntity>[]),
      returnValueForMissingStub: Future.value(<LikedTrackEntity>[]),
    ) as Future<List<LikedTrackEntity>>;
  }

  @override
  Future<List<RepostedTrackEntity>> getUserReposts({String? userId}) {
    return super.noSuchMethod(
      Invocation.method(#getUserReposts, [], {#userId: userId}),
      returnValue: Future.value(<RepostedTrackEntity>[]),
      returnValueForMissingStub: Future.value(<RepostedTrackEntity>[]),
    ) as Future<List<RepostedTrackEntity>>;
  }
}
