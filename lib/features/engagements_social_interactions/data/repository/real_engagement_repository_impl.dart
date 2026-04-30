import 'package:dio/dio.dart';

import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/comments_page_entity.dart';
import '../../domain/entities/engagement_user_entity.dart';
import '../../domain/entities/liked_track_entity.dart';
import '../../domain/entities/reply_entity.dart';
import '../../domain/entities/reposted_track_entity.dart';
import '../../domain/entities/track_engagement_entity.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../api/real_engagement_api.dart';
import '../mappers/engagement_mapper.dart';

class RealEngagementRepositoryImpl implements EngagementRepository {
  RealEngagementRepositoryImpl({required RealEngagementApi api}) : _api = api;

  final RealEngagementApi _api;

  @override
  Future<TrackEngagementEntity> getTrackEngagement({required String trackId}) async {
    final dto = await _api.getTrackEngagement(trackId);
    return EngagementMapper.toTrackEngagementEntity(dto);
  }

  @override
  Future<TrackEngagementEntity> toggleLike({required String trackId, required String viewerId}) async {
    try {
      final dto = await _api.likeTrack(trackId);
      return EngagementMapper.toTrackEngagementEntity(dto);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        // Already liked → unlike
        final dto = await _api.unlikeTrack(trackId);
        return EngagementMapper.toTrackEngagementEntity(dto);
      }
      rethrow;
    }
  }

  @override
  Future<TrackEngagementEntity> repostTrack({
    required String trackId,
    required String viewerId,
    String? caption,
  }) async {
    final dto = await _api.repostTrack(trackId);
    return EngagementMapper.toTrackEngagementEntity(dto);
  }

  @override
  Future<TrackEngagementEntity> removeRepost({
    required String trackId,
    required String viewerId,
  }) async {
    final dto = await _api.removeRepost(trackId);
    return EngagementMapper.toTrackEngagementEntity(dto);
  }

  @override
  Future<CommentsPageEntity> getComments({required String trackId}) async {
    final result = await _api.getComments(trackId);
    return EngagementMapper.toCommentsPageEntity(result.comments, total: result.total);
  }

  @override
  Future<CommentEntity> addComment({
    required String trackId,
    required String viewerId,
    int? timestamp,
    required String text,
  }) async {
    final dto = await _api.addComment(trackId, text: text, timestamp: timestamp ?? 0);
    return EngagementMapper.toCommentEntity(dto);
  }

  @override
  Future<void> deleteComment({required String trackId, required String commentId}) async {
    await _api.deleteComment(commentId);
  }

  @override
  Future<void> deleteReply({required String commentId, required String replyId}) async {
    await _api.deleteComment(replyId);
  }

  @override
  Future<void> toggleCommentLike({required String commentId, required bool isCurrentlyLiked}) async {
    await _api.toggleCommentLike(commentId, isCurrentlyLiked: isCurrentlyLiked);
  }

  @override
  Future<List<ReplyEntity>> getReplies({required String commentId}) async {
    final dtos = await _api.getReplies(commentId);
    return EngagementMapper.toReplyEntityList(dtos);
  }

  @override
  Future<ReplyEntity> addReply({
    required String commentId,
    required String viewerId,
    required String text,
    String? parentUsername,
  }) async {
    final dto = await _api.addReply(commentId, text: text);
    return EngagementMapper.toReplyEntity(dto);
  }

  @override
  Future<ReplyEntity> toggleReplyLike({
    required String commentId,
    required String replyId,
    required String viewerId,
  }) async {
    // Try like; if already liked (403) → unlike
    try {
      await _api.toggleCommentLike(replyId, isCurrentlyLiked: false);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        await _api.toggleCommentLike(replyId, isCurrentlyLiked: true);
      } else {
        rethrow;
      }
    }
    // Refresh replies to return accurate updated state
    final replies = await _api.getReplies(commentId);
    final updated = replies.firstWhere(
      (r) => r.id == replyId,
      orElse: () => replies.first,
    );
    return EngagementMapper.toReplyEntity(updated);
  }

  @override
  Future<List<EngagementUserEntity>> getLikers({required String trackId}) async {
    final dtos = await _api.getLikers(trackId);
    return EngagementMapper.toUserEntityList(dtos);
  }

  @override
  Future<List<EngagementUserEntity>> getReposters({required String trackId}) async {
    final dtos = await _api.getReposters(trackId);
    return EngagementMapper.toUserEntityList(dtos);
  }

  @override
  Future<List<LikedTrackEntity>> getLikedTracks({required String viewerId}) async {
    final userId = viewerId.trim().isEmpty ? null : viewerId;
    return _api.getLikedTracks(userId: userId);
  }

  @override
  Future<List<RepostedTrackEntity>> getUserReposts({String? userId}) async {
    return _api.getUserReposts(userId: userId);
  }
}
