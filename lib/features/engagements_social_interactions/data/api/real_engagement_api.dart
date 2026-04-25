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
    // ignore: avoid_print
    if (list.isNotEmpty) print('[getComments] first comment raw: ${list.first}');
    final comments = list
        .map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
        .where((comment) => !comment.isReply)
        .toList();
    final total = (data['total'] as int?) ?? comments.length;
    // Debug: log backend total count for comments
    // ignore: avoid_print
    print('[getComments] total comments from BE: $total');
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
    // Repost schema may return either a flat record or a nested user object.
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      final user = map['user'] as Map<String, dynamic>? ?? map;
      return EngagementUserDto.fromJson({
        'id': user['id'] ?? user['userId'],
        'displayName': user['displayName'] ?? user['username'] ?? user['name'],
        'avatarUrl': user['avatarUrl'] ?? user['avatar'],
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
      // Track data may be nested under 'track' (like reposts) or flat
      final track = map['track'] is Map<String, dynamic>
          ? map['track'] as Map<String, dynamic>
          : map;
      // Artist may arrive as a nested object or a plain string
      String artistId = '';
      String artistName = '';
      String? artistAvatar;
      final rawArtist = track['artist'];
      if (rawArtist is Map<String, dynamic>) {
        artistId = rawArtist['id'] as String? ?? '';
        artistName = rawArtist['displayName'] as String?
            ?? rawArtist['username'] as String?
            ?? rawArtist['name'] as String?
            ?? '';
        artistAvatar = rawArtist['avatarUrl'] as String?;
      } else if (rawArtist is String) {
        artistName = rawArtist;
      }
      return LikedTrackEntity(
        trackId: (track['id'] ?? track['trackId'] ?? '').toString(),
        title: track['title'] as String? ?? '',
        artistId: artistId,
        artistName: artistName,
        artistAvatar: artistAvatar,
        coverUrl: track['coverUrl'] as String?,
        duration: (track['durationSeconds'] as num?)?.toInt()
            ?? (track['duration'] as num?)?.toInt()
            ?? 0,
        likesCount: track['likesCount'] as int? ?? 0,
        commentsCount: track['commentsCount'] as int? ?? 0,
        likedAt: DateTime.tryParse(map['likedAt'] as String? ?? map['createdAt'] as String? ?? '') ?? DateTime.now(),
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
      final track = map['track'] as Map<String, dynamic>? ?? map;
      String rArtistId = '';
      String rArtistName = '';
      String? rArtistAvatar;
      final rawArtist = track['artist'];
      if (rawArtist is Map<String, dynamic>) {
        rArtistId = rawArtist['id'] as String? ?? '';
        rArtistName = rawArtist['displayName'] as String?
            ?? rawArtist['username'] as String?
            ?? rawArtist['name'] as String?
            ?? '';
        rArtistAvatar = rawArtist['avatarUrl'] as String?;
      } else if (rawArtist is String) {
        rArtistName = rawArtist;
      }
      return RepostedTrackEntity(
        trackId: (track['id'] ?? track['trackId'] ?? '').toString(),
        title: track['title'] as String? ?? '',
        artistId: rArtistId,
        artistName: rArtistName,
        artistAvatar: rArtistAvatar,
        coverUrl: track['coverUrl'] as String?,
        duration: (track['durationSeconds'] as num?)?.toInt()
            ?? (track['duration'] as num?)?.toInt()
            ?? 0,
        repostCount: track['repostsCount'] as int? ?? track['repostCount'] as int? ?? 0,
        repostedAt: DateTime.tryParse(map['repostedAt'] as String? ?? '') ?? DateTime.now(),
      );
    }).toList();
  }
}
