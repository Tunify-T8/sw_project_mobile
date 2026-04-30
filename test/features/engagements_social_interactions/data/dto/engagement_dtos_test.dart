import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/engagements_social_interactions/data/dto/comment_dto.dart';
import 'package:software_project/features/engagements_social_interactions/data/dto/reply_dto.dart';
import 'package:software_project/features/engagements_social_interactions/data/dto/track_engagement_dto.dart';

void main() {
  group('TrackEngagementDto.fromJson', () {
    test('parses standard fields', () {
      final dto = TrackEngagementDto.fromJson({
        'trackId': 'track-1',
        'likesCount': 10,
        'repostsCount': 3,
        'commentsCount': 5,
        'isLiked': true,
        'isReposted': false,
      });

      expect(dto.trackId, 'track-1');
      expect(dto.likeCount, 10);
      expect(dto.repostCount, 3);
      expect(dto.commentCount, 5);
      expect(dto.isLiked, isTrue);
      expect(dto.isReposted, isFalse);
    });

    test('falls back to likeCount when likesCount is absent', () {
      final dto = TrackEngagementDto.fromJson({
        'trackId': 'track-2',
        'likeCount': 7,
        'repostCount': 1,
        'commentCount': 2,
        'isLiked': false,
        'isReposted': false,
      });

      expect(dto.likeCount, 7);
      expect(dto.repostCount, 1);
      expect(dto.commentCount, 2);
    });

    test('defaults to 0 counts and false booleans when fields are absent', () {
      final dto = TrackEngagementDto.fromJson({'trackId': 'track-3'});

      expect(dto.likeCount, 0);
      expect(dto.repostCount, 0);
      expect(dto.commentCount, 0);
      expect(dto.isLiked, isFalse);
      expect(dto.isReposted, isFalse);
    });

    test('trackId defaults to empty string when absent', () {
      final dto = TrackEngagementDto.fromJson({});
      expect(dto.trackId, '');
    });
  });

  group('CommentDto.fromJson', () {
    final baseUser = {
      'userId': 'u-1',
      'displayName': 'Alice',
    };

    test('parses commentId key', () {
      final dto = CommentDto.fromJson({
        'commentId': 'c-1',
        'trackId': 'track-1',
        'user': baseUser,
        'text': 'Hello',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.id, 'c-1');
    });

    test('falls back to id key when commentId is absent', () {
      final dto = CommentDto.fromJson({
        'id': 'c-2',
        'trackId': 'track-1',
        'user': baseUser,
        'text': 'Hi',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.id, 'c-2');
    });

    test('parses timestamp from second key when timestamp absent', () {
      final dto = CommentDto.fromJson({
        'commentId': 'c-3',
        'trackId': 'track-1',
        'user': baseUser,
        'text': 'At 30s',
        'second': 30,
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.timestamp, 30);
    });

    test('parses isLiked correctly', () {
      final liked = CommentDto.fromJson({
        'commentId': 'c-4',
        'trackId': 'track-1',
        'user': baseUser,
        'text': 'Liked',
        'isLiked': true,
        'createdAt': '2026-01-01T00:00:00.000Z',
      });
      final notLiked = CommentDto.fromJson({
        'commentId': 'c-5',
        'trackId': 'track-1',
        'user': baseUser,
        'text': 'Not liked',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(liked.isLiked, isTrue);
      expect(notLiked.isLiked, isFalse);
    });

    test('isReply is true when parentId is present', () {
      final dto = CommentDto.fromJson({
        'commentId': 'c-6',
        'trackId': 'track-1',
        'user': baseUser,
        'text': 'reply',
        'parentId': 'c-1',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.isReply, isTrue);
    });

    test('isReply is false when parentId is absent', () {
      final dto = CommentDto.fromJson({
        'commentId': 'c-7',
        'trackId': 'track-1',
        'user': baseUser,
        'text': 'top level',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.isReply, isFalse);
    });

    test('createdAt falls back to epoch when invalid', () {
      final dto = CommentDto.fromJson({
        'commentId': 'c-8',
        'trackId': 'track-1',
        'user': baseUser,
        'text': 'bad date',
        'createdAt': 'not-a-date',
      });

      expect(dto.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('defaults to 0 counts when absent', () {
      final dto = CommentDto.fromJson({
        'commentId': 'c-9',
        'trackId': 'track-1',
        'user': baseUser,
        'text': 'counts',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.likesCount, 0);
      expect(dto.repliesCount, 0);
    });
  });

  group('ReplyDto.fromJson', () {
    final authorUser = {
      'userId': 'u-2',
      'displayName': 'Bob',
    };

    test('parses replyId key', () {
      final dto = ReplyDto.fromJson({
        'replyId': 'r-1',
        'commentId': 'c-1',
        'author': authorUser,
        'text': 'Nice!',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.id, 'r-1');
    });

    test('falls back to id key when replyId absent', () {
      final dto = ReplyDto.fromJson({
        'id': 'r-2',
        'commentId': 'c-1',
        'author': authorUser,
        'text': 'Also nice',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.id, 'r-2');
    });

    test('falls back to user key when author absent', () {
      final dto = ReplyDto.fromJson({
        'replyId': 'r-3',
        'commentId': 'c-1',
        'user': {'userId': 'u-3', 'displayName': 'Carol'},
        'text': 'Hey',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.user.displayName, 'Carol');
    });

    test('parses isLikedByViewer from isLiked key', () {
      final dto = ReplyDto.fromJson({
        'replyId': 'r-4',
        'commentId': 'c-1',
        'author': authorUser,
        'text': 'liked',
        'isLiked': true,
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.isLikedByViewer, isTrue);
    });

    test('parses isLikedByViewer from isLikedByViewer key', () {
      final dto = ReplyDto.fromJson({
        'replyId': 'r-5',
        'commentId': 'c-1',
        'author': authorUser,
        'text': 'liked2',
        'isLikedByViewer': true,
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.isLikedByViewer, isTrue);
    });

    test('defaults isLikedByViewer to false when both keys absent', () {
      final dto = ReplyDto.fromJson({
        'replyId': 'r-6',
        'commentId': 'c-1',
        'author': authorUser,
        'text': 'not liked',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.isLikedByViewer, isFalse);
    });

    test('parses parentUsername', () {
      final dto = ReplyDto.fromJson({
        'replyId': 'r-7',
        'commentId': 'c-1',
        'author': authorUser,
        'text': '@Alice nice',
        'parentUsername': 'Alice',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.parentUsername, 'Alice');
    });

    test('createdAt falls back to epoch when invalid', () {
      final dto = ReplyDto.fromJson({
        'replyId': 'r-8',
        'commentId': 'c-1',
        'author': authorUser,
        'text': 'bad',
        'createdAt': 'bad-date',
      });

      expect(dto.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });
}
