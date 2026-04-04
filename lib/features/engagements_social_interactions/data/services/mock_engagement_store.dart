import '../dto/comment_dto.dart';
import '../dto/engagement_mock_data_dto.dart';
import '../dto/engagement_user_dto.dart';
import '../dto/reply_dto.dart';
import '../dto/track_engagement_dto.dart';

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
    if (existing != null) return existing;

    final created = TrackEngagementDto(
      trackId: trackId,
      likeCount: 0,
      repostCount: 0,
      commentCount: 0,
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
    final likers = _likersByTrackId.putIfAbsent(trackId, () => <String>[]);
    final hasLiked = likers.contains(viewerId);

    if (hasLiked) {
      likers.remove(viewerId);
    } else {
      likers.add(viewerId);
    }

    // likeCount increments/decrements independently from the likers list
    // so that when the likers list is removed on BE integration, count still works
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
    final comments = _commentsByTrackId[trackId] ?? <CommentDto>[];
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
          username: 'user_$viewerId',
          avatarUrl: null,
        );

    _usersById.putIfAbsent(viewerId, () => user);

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
    final userIds = _likersByTrackId[trackId] ?? <String>[];
    return userIds
        .map((id) => _usersById[id])
        .whereType<EngagementUserDto>()
        .toList();
  }

  List<EngagementUserDto> getTrackReposters(String trackId) {
    final userIds = _repostersByTrackId[trackId] ?? <String>[];
    return userIds
        .map((id) => _usersById[id])
        .whereType<EngagementUserDto>()
        .toList();
  }

  List<ReplyDto> getReplies(String commentId) {
    return List<ReplyDto>.from(_repliesByCommentId[commentId] ?? <ReplyDto>[]);
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
          username: 'user_$viewerId',
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

    return newReply;
  }
}
