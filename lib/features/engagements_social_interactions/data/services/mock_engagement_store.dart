import '../dto/comment_dto.dart';
import '../dto/engagement_mock_data_dto.dart';
import '../dto/engagement_user_dto.dart';
import '../dto/reply_dto.dart';
import '../dto/track_engagement_dto.dart';
import '../../domain/entities/liked_track_entity.dart';
import '../../domain/entities/reposted_track_entity.dart';

class MockEngagementStore {
  MockEngagementStore() {
    _usersById = {
      for (final user in EngagementMockDataDto.users) user.id: user,
    };

    _engagementByTrackId = {
      for (final item in EngagementMockDataDto.trackEngagements)
        item.trackId: item,
    };

    _commentsByTrackId = <String, List<CommentDto>>{};
    for (final comment in EngagementMockDataDto.comments) {
      _commentsByTrackId.putIfAbsent(comment.trackId, () => <CommentDto>[]);
      _commentsByTrackId[comment.trackId]!.add(comment);
    }

    _repliesByCommentId = {};

    _likersByTrackId = {
      for (final entry in EngagementMockDataDto.trackLikers.entries)
        entry.key: List<String>.from(entry.value),
    };

    _repostersByTrackId = {
      for (final entry in EngagementMockDataDto.trackReposters.entries)
        entry.key: List<String>.from(entry.value),
    };

  }

  late final Map<String, EngagementUserDto> _usersById;
  late final Map<String, TrackEngagementDto> _engagementByTrackId;
  late final Map<String, List<CommentDto>> _commentsByTrackId;
  late final Map<String, List<ReplyDto>> _repliesByCommentId;
  late final Map<String, List<String>> _likersByTrackId;
  late final Map<String, List<String>> _repostersByTrackId;

  TrackEngagementDto getTrackEngagement(String trackId) {
    final existing = _engagementByTrackId[trackId];
    final actualCommentCount = (_commentsByTrackId[trackId] ?? []).length;

    if (existing != null) {
      // keep all fields but override commentCount with real list length
      final synced = TrackEngagementDto(
        trackId: existing.trackId,
        likeCount: existing.likeCount,
        repostCount: existing.repostCount,
        commentCount: actualCommentCount,
        isLiked: existing.isLiked,
        isReposted: existing.isReposted,
      );
      _engagementByTrackId[trackId] = synced;
      return synced;
    }

    final created = TrackEngagementDto(
      trackId: trackId,
      likeCount: 0,
      repostCount: 0,
      commentCount: actualCommentCount,
      isLiked: false,
      isReposted: false,
    );
    _engagementByTrackId[trackId] = created;
    return created;
  }

  TrackEngagementDto toggleLike({
    required String trackId,
    required String viewerId,
  }) {
    final current = getTrackEngagement(trackId);
    // seed from t1's likers so default likers stay when a real track is liked
    if (!_likersByTrackId.containsKey(trackId)) {
      _likersByTrackId[trackId] = List<String>.from(_likersByTrackId['t1'] ?? []);
    }
    final likers = _likersByTrackId[trackId]!;
    final hasLiked = likers.contains(viewerId);

    if (hasLiked) {
      likers.remove(viewerId);
    } else {
      likers.add(viewerId);
    }

    final updated = TrackEngagementDto(
      trackId: current.trackId,
      likeCount: hasLiked ? current.likeCount - 1 : current.likeCount + 1,
      repostCount: current.repostCount,
      commentCount: current.commentCount,
      isLiked: !hasLiked,
      isReposted: current.isReposted,
    );

    _engagementByTrackId[trackId] = updated;
    return updated;
  }

  TrackEngagementDto toggleRepost({
    required String trackId,
    required String viewerId,
  }) {
    final current = getTrackEngagement(trackId);
    final reposters = _repostersByTrackId.putIfAbsent(trackId, () => <String>[]);
    final hasReposted = reposters.contains(viewerId);

    if (hasReposted) {
      reposters.remove(viewerId);
    } else {
      reposters.add(viewerId);
    }

    final updated = TrackEngagementDto(
      trackId: current.trackId,
      likeCount: current.likeCount,
      repostCount: reposters.length,
      commentCount: current.commentCount,
      isLiked: current.isLiked,
      isReposted: !hasReposted,
    );

    _engagementByTrackId[trackId] = updated;
    return updated;
  }

  TrackEngagementDto removeRepost({
    required String trackId,
    required String viewerId,
  }) {
    final current = getTrackEngagement(trackId);
    final reposters = _repostersByTrackId.putIfAbsent(trackId, () => <String>[]);

    if (!reposters.contains(viewerId)) return current;

    reposters.remove(viewerId);

    final updated = TrackEngagementDto(
      trackId: current.trackId,
      likeCount: current.likeCount,
      repostCount: reposters.length,
      commentCount: current.commentCount,
      isLiked: current.isLiked,
      isReposted: false,
    );

    _engagementByTrackId[trackId] = updated;
    return updated;
  }

  List<CommentDto> getTrackComments(String trackId) {
    // Fall back to t1's comments for any track not in the mock store
    // (real API track IDs won't match t1/t2/t3, so this keeps comments visible)
    final comments = _commentsByTrackId[trackId] ??
        _commentsByTrackId['t1'] ??
        <CommentDto>[];
    final sorted = List<CommentDto>.from(comments)
      ..sort((a, b) => (a.timestamp ?? 0).compareTo(b.timestamp ?? 0));
    return sorted;
  }

  CommentDto addTimestampedComment({
    required String trackId,
    required String viewerId,
    required int timestamp,
    required String text,
  }) {
    final safeTimestamp = timestamp < 0 ? 0 : timestamp;
    final user = _usersById[viewerId] ??
        EngagementUserDto(
          id: viewerId,
          displayName: 'user_$viewerId',
          avatarUrl: null,
        );

    _usersById.putIfAbsent(viewerId, () => user);

    // If this track has no comments yet, seed it with t1's mock comments first
    // so new comments appear alongside the existing mock ones
    if (!_commentsByTrackId.containsKey(trackId)) {
      _commentsByTrackId[trackId] = List<CommentDto>.from(
        _commentsByTrackId['t1'] ?? <CommentDto>[],
      );
    }

    final newComment = CommentDto(
      id: 'comment_${DateTime.now().microsecondsSinceEpoch}',
      trackId: trackId,
      user: user,
      timestamp: safeTimestamp,
      text: text.trim(),
      likesCount: 0,
      repliesCount: 0,
      createdAt: DateTime.now().toUtc(),
    );

    _commentsByTrackId.putIfAbsent(trackId, () => <CommentDto>[]);
    _commentsByTrackId[trackId]!.add(newComment);

    final current = getTrackEngagement(trackId);
    _engagementByTrackId[trackId] = TrackEngagementDto(
      trackId: current.trackId,
      likeCount: current.likeCount,
      repostCount: current.repostCount,
      commentCount: (_commentsByTrackId[trackId] ?? <CommentDto>[]).length,
      isLiked: current.isLiked,
      isReposted: current.isReposted,
    );

    return newComment;
  }

  List<EngagementUserDto> getTrackLikers(String trackId) {
    final userIds = _likersByTrackId[trackId] ?? _likersByTrackId['t1'] ?? <String>[];
    return userIds
        .map((id) => _usersById[id])
        .whereType<EngagementUserDto>()
        .toList();
  }

  List<EngagementUserDto> getTrackReposters(String trackId) {
    final userIds = _repostersByTrackId[trackId] ?? _repostersByTrackId['t1'] ?? <String>[];
    return userIds
        .map((id) => _usersById[id])
        .whereType<EngagementUserDto>()
        .toList();
  }

  // engagement addition — returns mock liked tracks for the viewer
  // replaces GET /users/me/likes; swap with real API call when BE is ready
  List<LikedTrackEntity> getLikedTracks(String viewerId) {
    return EngagementMockDataDto.likedTracks;
  }

  // returns mock reposted tracks for the given user
  // null userId → GET /users/me/reposts; non-null → GET /users/{id}/reposts
  // swap with real API call when BE is ready
  List<RepostedTrackEntity> getRepostedTracks(String? userId) {
    return EngagementMockDataDto.repostedTracks;
  }

  void seedUser({
    required String id,
    required String username,
    String? avatarUrl,
  }) {
    _usersById.putIfAbsent(
      id,
      () => EngagementUserDto(id: id, displayName: username, avatarUrl: avatarUrl),
    );
  }

  void seedEngagement({
    required String trackId,
    required int likeCount,
    required int repostCount,
    required int commentCount,
    required bool isLiked,
    required bool isReposted,
  }) {
    _engagementByTrackId.putIfAbsent(
      trackId,
      () => TrackEngagementDto(
        trackId: trackId,
        likeCount: likeCount,
        repostCount: repostCount,
        commentCount: commentCount,
        isLiked: isLiked,
        isReposted: isReposted,
      ),
    );
    _likersByTrackId.putIfAbsent(
      trackId,
      () => isLiked ? [EngagementMockDataDto.viewerId] : [],
    );
    _repostersByTrackId.putIfAbsent(
      trackId,
      () => isReposted ? [EngagementMockDataDto.viewerId] : [],
    );
  }

  void deleteComment(String trackId, String commentId) {
    _commentsByTrackId[trackId]?.removeWhere((c) => c.id == commentId);
    final current = getTrackEngagement(trackId);
    _engagementByTrackId[trackId] = TrackEngagementDto(
      trackId: current.trackId,
      likeCount: current.likeCount,
      repostCount: current.repostCount,
      commentCount: (_commentsByTrackId[trackId] ?? []).length,
      isLiked: current.isLiked,
      isReposted: current.isReposted,
    );
  }

  void deleteReply(String commentId, String replyId) {
    _repliesByCommentId[commentId]?.removeWhere((r) => r.id == replyId);

    // keep repliesCount on parent comment in sync
    for (final trackId in _commentsByTrackId.keys) {
      final comments = _commentsByTrackId[trackId]!;
      final idx = comments.indexWhere((c) => c.id == commentId);
      if (idx != -1) {
        final old = comments[idx];
        comments[idx] = CommentDto(
          id: old.id,
          trackId: old.trackId,
          user: old.user,
          timestamp: old.timestamp,
          text: old.text,
          likesCount: old.likesCount,
          repliesCount: (_repliesByCommentId[commentId] ?? []).length,
          createdAt: old.createdAt,
        );
        break;
      }
    }
  }

  List<ReplyDto> getReplies(String commentId) {
    return List<ReplyDto>.from(_repliesByCommentId[commentId] ?? <ReplyDto>[]);
  }

  // engagement addition — toggles like on a reply, persisting count + viewer state in the store
  ReplyDto toggleReplyLike({
    required String commentId,
    required String replyId,
    required String viewerId,
  }) {
    final replies = _repliesByCommentId[commentId] ?? <ReplyDto>[];
    final idx = replies.indexWhere((r) => r.id == replyId);
    if (idx == -1) throw StateError('Reply $replyId not found');

    final old = replies[idx];
    final nowLiked = !old.isLikedByViewer;
    final updated = ReplyDto(
      id: old.id,
      commentId: old.commentId,
      user: old.user,
      parentUsername: old.parentUsername,
      text: old.text,
      likesCount: nowLiked ? old.likesCount + 1 : (old.likesCount - 1).clamp(0, 999999),
      repliesCount: old.repliesCount,
      isLikedByViewer: nowLiked,
      createdAt: old.createdAt,
    );
    replies[idx] = updated;
    _repliesByCommentId[commentId] = replies;
    return updated;
  }

  ReplyDto addReply({
    required String commentId,
    required String viewerId,
    required String text,
    String? parentUsername,
  }) {
    final user = _usersById[viewerId] ??
        EngagementUserDto(
          id: viewerId,
          displayName: 'user_$viewerId',
          avatarUrl: null,
        );

    _usersById.putIfAbsent(viewerId, () => user);

    final newReply = ReplyDto(
      id: 'reply_${DateTime.now().microsecondsSinceEpoch}',
      commentId: commentId,
      user: user,
      parentUsername: parentUsername,
      text: text.trim(),
      likesCount: 0,
      repliesCount: 0,
      createdAt: DateTime.now().toUtc(),
    );

    _repliesByCommentId.putIfAbsent(commentId, () => <ReplyDto>[]);
    _repliesByCommentId[commentId]!.add(newReply);

    // update repliesCount in every copy of the comment list (t1 + any seeded copies)
    for (final comments in _commentsByTrackId.values) {
      final idx = comments.indexWhere((c) => c.id == commentId);
      if (idx != -1) {
        final old = comments[idx];
        comments[idx] = CommentDto(
          id: old.id,
          trackId: old.trackId,
          user: old.user,
          timestamp: old.timestamp,
          text: old.text,
          likesCount: old.likesCount,
          repliesCount: _repliesByCommentId[commentId]!.length,
          createdAt: old.createdAt,
        );
      }
    }

    return newReply;
  }
}
