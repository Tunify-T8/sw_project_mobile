import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dto/comment_dto.dart';
import '../dto/engagement_user_dto.dart';
import '../dto/reply_dto.dart';
import '../dto/track_engagement_dto.dart';
import '../../domain/entities/liked_track_entity.dart';
import '../../domain/entities/reposted_track_entity.dart';

class RealEngagementApi {
  RealEngagementApi({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<TrackEngagementDto> getTrackEngagement(String trackId) async {
    final res = await _dio.get(ApiEndpoints.trackEngagement(trackId));
    final data = res.data as Map<String, dynamic>;
    return TrackEngagementDto.fromJson({...data, 'trackId': trackId});
  }

  Future<TrackEngagementDto> likeTrack(String trackId) async {
    await _dio.post(ApiEndpoints.likeTrack(trackId));
    return getTrackEngagement(trackId);
  }

  Future<TrackEngagementDto> unlikeTrack(String trackId) async {
    await _dio.delete(ApiEndpoints.likeTrack(trackId));
    return getTrackEngagement(trackId);
  }

  Future<TrackEngagementDto> repostTrack(String trackId) async {
    await _dio.post(ApiEndpoints.repostTrack(trackId));
    return getTrackEngagement(trackId);
  }

  Future<TrackEngagementDto> removeRepost(String trackId) async {
    await _dio.delete(ApiEndpoints.repostTrack(trackId));
    return getTrackEngagement(trackId);
  }

  Future<({List<CommentDto> comments, int total})> getComments(String trackId, {int page = 1, int limit = 20}) async {
    final res = await _dio.get(
      ApiEndpoints.trackComments(trackId),
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = res.data as Map<String, dynamic>;
    final list = data['comments'] as List<dynamic>? ?? [];
    final comments = list
        .map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
        .where((comment) => !comment.isReply)
        .toList();
    final total = (data['total'] as int?) ?? comments.length;
    return (comments: comments, total: total);
  }

  Future<CommentDto> addComment(String trackId, {required String text, required int timestamp}) async {
    final res = await _dio.post(
      ApiEndpoints.trackComments(trackId),
      data: {'text': text, 'timestamp': timestamp},
    );
    final data = res.data as Map<String, dynamic>;
    return CommentDto.fromJson({
      ...data,
      'user': {
        'userId': data['userId'],
        'username': data['username'],
        'avatarUrl': data['avatarUrl'],
      },
    });
  }

  Future<void> deleteComment(String commentId) async {
    await _dio.delete(ApiEndpoints.deleteComment(commentId));
  }

  Future<List<ReplyDto>> getReplies(String commentId, {int page = 1, int limit = 20}) async {
    final res = await _dio.get(
      ApiEndpoints.commentReplies(commentId),
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = res.data as Map<String, dynamic>;
    final list = data['replies'] as List<dynamic>? ?? [];
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      // API returns parentId; DTO expects commentId
      return ReplyDto.fromJson({...map, 'commentId': map['parentId'] ?? commentId});
    }).toList();
  }

  Future<ReplyDto> addReply(String commentId, {required String text}) async {
    final res = await _dio.post(
      ApiEndpoints.commentReplies(commentId),
      data: {'text': text},
    );
    return ReplyDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<EngagementUserDto>> getLikers(String trackId, {int page = 1, int limit = 20}) async {
    final res = await _dio.get(
      ApiEndpoints.trackLikers(trackId),
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = res.data as Map<String, dynamic>;
    final list = data['likes'] as List<dynamic>? ?? [];
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      // Response wraps user: { "user": {...}, "likedAt": "..." }
      final user = map['user'] as Map<String, dynamic>? ?? map;
      return EngagementUserDto.fromJson(user);
    }).toList();
  }

  Future<List<EngagementUserDto>> getReposters(String trackId, {int page = 1, int limit = 20}) async {
    final res = await _dio.get(
      ApiEndpoints.trackReposters(trackId),
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = res.data as Map<String, dynamic>;
    final list = data['reposts'] as List<dynamic>? ?? [];
    // Repost schema is flat — reshape to match EngagementUserDto
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      return EngagementUserDto.fromJson({
        'userId': map['userId'],
        'username': map['username'],
        'avatarUrl': map['avatarUrl'],
      });
    }).toList();
  }

  Future<void> toggleCommentLike(String commentId, {required bool isCurrentlyLiked}) async {
    if (isCurrentlyLiked) {
      await _dio.delete(ApiEndpoints.likeComment(commentId));
    } else {
      await _dio.post(ApiEndpoints.likeComment(commentId));
    }
  }

  Future<List<LikedTrackEntity>> getLikedTracks({int page = 1, int limit = 10}) async {
    final res = await _dio.get(
      ApiEndpoints.myLikedTracks,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = res.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>? ?? [];
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      return LikedTrackEntity(
        trackId: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        artistId: '',
        artistName: '',
        coverUrl: map['coverUrl'] as String?,
        duration: map['duration'] as int? ?? 0,
        likesCount: map['likesCount'] as int? ?? 0,
        commentsCount: map['commentsCount'] as int? ?? 0,
        likedAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
    }).toList();
  }

  Future<List<RepostedTrackEntity>> getUserReposts({String? userId, int page = 1, int limit = 10}) async {
    final endpoint = userId != null
        ? ApiEndpoints.userReposts(userId)
        : ApiEndpoints.myReposts;
    final res = await _dio.get(endpoint, queryParameters: {'page': page, 'limit': limit});
    final data = res.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>? ?? [];
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      final track = map['track'] as Map<String, dynamic>? ?? {};
      return RepostedTrackEntity(
        trackId: track['id'] as String? ?? '',
        title: track['title'] as String? ?? '',
        artistId: '',
        artistName: '',
        coverUrl: track['coverUrl'] as String?,
        duration: track['duration'] as int? ?? 0,
        repostCount: track['repostsCount'] as int? ?? 0,
        repostedAt: DateTime.tryParse(map['repostedAt'] as String? ?? '') ?? DateTime.now(),
      );
    }).toList();
  }
}
