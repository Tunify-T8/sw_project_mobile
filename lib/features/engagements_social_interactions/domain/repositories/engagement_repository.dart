import '../entities/track_engagement_entity.dart';
import '../entities/comment_entity.dart';
import '../entities/comments_page_entity.dart';
import '../entities/reply_entity.dart';
import '../entities/engagement_user_entity.dart';
import '../entities/liked_track_entity.dart';

abstract class EngagementRepository {
  Future<TrackEngagementEntity> getTrackEngagement({required String trackId});
  Future<TrackEngagementEntity> toggleLike({required String trackId, required String viewerId});
  Future<TrackEngagementEntity> repostTrack({required String trackId, required String viewerId, String? caption});
  Future<TrackEngagementEntity> removeRepost({required String trackId, required String viewerId});
  Future<CommentsPageEntity> getComments({required String trackId});
  Future<CommentEntity> addComment({required String trackId, required String viewerId, int? timestamp, required String text});
  Future<List<ReplyEntity>> getReplies({required String commentId});
  Future<ReplyEntity> addReply({required String commentId, required String viewerId, required String text, String? parentUsername});
  Future<void> deleteComment({required String trackId, required String commentId});
  Future<void> deleteReply({required String commentId, required String replyId});
  Future<ReplyEntity> toggleReplyLike({required String commentId, required String replyId, required String viewerId}); // engagement addition
  Future<List<EngagementUserEntity>> getLikers({required String trackId});
  Future<List<EngagementUserEntity>> getReposters({required String trackId});
  Future<List<LikedTrackEntity>> getLikedTracks({required String viewerId}); // engagement addition — maps to GET /users/me/likes
}
