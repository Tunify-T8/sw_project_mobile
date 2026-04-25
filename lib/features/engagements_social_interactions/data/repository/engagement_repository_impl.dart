// Mock-backed repository disabled — RealEngagementRepositoryImpl is used exclusively.
/*
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/comments_page_entity.dart';
import '../../domain/entities/engagement_user_entity.dart';
import '../../domain/entities/liked_track_entity.dart';
import '../../domain/entities/reposted_track_entity.dart';
import '../../domain/entities/reply_entity.dart';
import '../../domain/entities/track_engagement_entity.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../mappers/engagement_mapper.dart';
import '../services/mock_engagement_store.dart';

class EngagementRepositoryImpl implements EngagementRepository {
  EngagementRepositoryImpl({required MockEngagementStore store}) : _store = store;

  final MockEngagementStore _store;
  static const Duration _delay = Duration(milliseconds: 250);

  @override
  Future<TrackEngagementEntity> getTrackEngagement({required String trackId}) async {
    await Future<void>.delayed(_delay);
    return EngagementMapper.toTrackEngagementEntity(_store.getTrackEngagement(trackId));
  }

  @override
  Future<TrackEngagementEntity> toggleLike({required String trackId, required String viewerId}) async {
    await Future<void>.delayed(_delay);
    return EngagementMapper.toTrackEngagementEntity(
      _store.toggleLike(trackId: trackId, viewerId: viewerId),
    );
  }

  @override
  Future<TrackEngagementEntity> repostTrack({required String trackId, required String viewerId, String? caption}) async {
    await Future<void>.delayed(_delay);
    return EngagementMapper.toTrackEngagementEntity(
      _store.toggleRepost(trackId: trackId, viewerId: viewerId),
    );
  }

  @override
  Future<TrackEngagementEntity> removeRepost({required String trackId, required String viewerId}) async {
    await Future<void>.delayed(_delay);
    return EngagementMapper.toTrackEngagementEntity(
      _store.removeRepost(trackId: trackId, viewerId: viewerId),
    );
  }

  @override
  Future<CommentsPageEntity> getComments({required String trackId}) async {
    await Future<void>.delayed(_delay);
    return EngagementMapper.toCommentsPageEntity(_store.getTrackComments(trackId));
  }

  @override
  Future<CommentEntity> addComment({required String trackId, required String viewerId, int? timestamp, required String text}) async {
    await Future<void>.delayed(_delay);
    return EngagementMapper.toCommentEntity(
      _store.addTimestampedComment(
        trackId: trackId,
        viewerId: viewerId,
        timestamp: timestamp ?? 0,
        text: text,
      ),
    );
  }

  @override
  Future<List<ReplyEntity>> getReplies({required String commentId}) async {
    await Future<void>.delayed(_delay);
    return EngagementMapper.toReplyEntityList(_store.getReplies(commentId));
  }

  @override
  Future<ReplyEntity> addReply({required String commentId, required String viewerId, required String text, String? parentUsername}) async {
    await Future<void>.delayed(_delay);
    return EngagementMapper.toReplyEntity(
      _store.addReply(
        commentId: commentId,
        viewerId: viewerId,
        text: text,
        parentUsername: parentUsername,
      ),
    );
  }

  @override
  Future<void> deleteComment({required String trackId, required String commentId}) async {
    await Future<void>.delayed(_delay);
    _store.deleteComment(trackId, commentId);
  }

  @override
  Future<void> deleteReply({required String commentId, required String replyId}) async {
    await Future<void>.delayed(_delay);
    _store.deleteReply(commentId, replyId);
  }

  @override
  Future<void> toggleCommentLike({required String commentId, required bool isCurrentlyLiked}) async {
    await Future<void>.delayed(_delay);
  }

  @override
  Future<ReplyEntity> toggleReplyLike({
    required String commentId,
    required String replyId,
    required String viewerId,
  }) async {
    await Future<void>.delayed(_delay);
    return EngagementMapper.toReplyEntity(
      _store.toggleReplyLike(commentId: commentId, replyId: replyId, viewerId: viewerId),
    );
  }

  @override
  Future<List<LikedTrackEntity>> getLikedTracks({required String viewerId}) async {
    await Future<void>.delayed(_delay);
    return _store.getLikedTracks(viewerId);
  }

  @override
  Future<List<RepostedTrackEntity>> getUserReposts({String? userId}) async {
    await Future<void>.delayed(_delay);
    return _store.getRepostedTracks(userId);
  }

  @override
  Future<List<EngagementUserEntity>> getLikers({required String trackId}) async {
    await Future<void>.delayed(_delay);
    return EngagementMapper.toUserEntityList(_store.getTrackLikers(trackId));
  }

  @override
  Future<List<EngagementUserEntity>> getReposters({required String trackId}) async {
    await Future<void>.delayed(_delay);
    return EngagementMapper.toUserEntityList(_store.getTrackReposters(trackId));
  }
}
*/
