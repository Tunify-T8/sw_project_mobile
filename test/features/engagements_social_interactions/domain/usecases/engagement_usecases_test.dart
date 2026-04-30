import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/engagements_social_interactions/domain/usecases/add_comment_usecase.dart';
import 'package:software_project/features/engagements_social_interactions/domain/usecases/delete_comment_usecase.dart';
import 'package:software_project/features/engagements_social_interactions/domain/usecases/delete_reply_usecase.dart';
import 'package:software_project/features/engagements_social_interactions/domain/usecases/get_comments_usecase.dart';
import 'package:software_project/features/engagements_social_interactions/domain/usecases/get_likers_usecase.dart';
import 'package:software_project/features/engagements_social_interactions/domain/usecases/get_replies_usecase.dart';
import 'package:software_project/features/engagements_social_interactions/domain/usecases/get_track_engagement_usecase.dart';
import 'package:software_project/features/engagements_social_interactions/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:software_project/features/engagements_social_interactions/domain/usecases/toggle_like_usecase.dart';

import '../../helpers/engagement_test_mocks.dart';

void main() {
  late MockEngagementRepository repo;

  setUp(() {
    repo = MockEngagementRepository();
  });

  group('GetTrackEngagementUsecase', () {
    test('delegates to repository with trackId', () async {
      final expected = dummyEngagement();
      when(repo.getTrackEngagement(trackId: kTrackId))
          .thenAnswer((_) async => expected);

      final result = await GetTrackEngagementUsecase(repo)
          .call(trackId: kTrackId);

      expect(result, expected);
      verify(repo.getTrackEngagement(trackId: kTrackId)).called(1);
      verifyNoMoreInteractions(repo);
    });
  });

  group('ToggleLikeUsecase', () {
    test('delegates to repository and returns updated engagement', () async {
      final expected = dummyEngagement(isLiked: true, likeCount: 6);
      when(repo.toggleLike(trackId: kTrackId, viewerId: kViewerId))
          .thenAnswer((_) async => expected);

      final result = await ToggleLikeUsecase(repo)
          .call(trackId: kTrackId, viewerId: kViewerId);

      expect(result.isLiked, isTrue);
      expect(result.likeCount, 6);
      verify(repo.toggleLike(trackId: kTrackId, viewerId: kViewerId)).called(1);
    });
  });

  group('AddCommentUsecase', () {
    test('delegates to repository when text is non-empty', () async {
      final expected = dummyComment();
      when(repo.addComment(
        trackId: kTrackId,
        viewerId: kViewerId,
        text: 'Hello',
        timestamp: null,
      )).thenAnswer((_) async => expected);

      final result = await AddCommentUsecase(repo).call(
        trackId: kTrackId,
        viewerId: kViewerId,
        text: 'Hello',
      );

      expect(result.id, kCommentId);
      verify(repo.addComment(
        trackId: kTrackId,
        viewerId: kViewerId,
        text: 'Hello',
        timestamp: null,
      )).called(1);
    });

    test('throws ArgumentError for empty text', () {
      expect(
        () => AddCommentUsecase(repo).call(
          trackId: kTrackId,
          viewerId: kViewerId,
          text: '',
        ),
        throwsA(isA<ArgumentError>()),
      );
      verifyZeroInteractions(repo);
    });

    test('throws ArgumentError for whitespace-only text', () {
      expect(
        () => AddCommentUsecase(repo).call(
          trackId: kTrackId,
          viewerId: kViewerId,
          text: '   ',
        ),
        throwsA(isA<ArgumentError>()),
      );
      verifyZeroInteractions(repo);
    });

    test('passes timestamp to repository when provided', () async {
      when(repo.addComment(
        trackId: kTrackId,
        viewerId: kViewerId,
        text: 'At 30s',
        timestamp: 30,
      )).thenAnswer((_) async => dummyComment());

      await AddCommentUsecase(repo).call(
        trackId: kTrackId,
        viewerId: kViewerId,
        text: 'At 30s',
        timestamp: 30,
      );

      verify(repo.addComment(
        trackId: kTrackId,
        viewerId: kViewerId,
        text: 'At 30s',
        timestamp: 30,
      )).called(1);
    });
  });

  group('GetCommentsUsecase', () {
    test('delegates to repository with trackId', () async {
      final page = dummyCommentsPage();
      when(repo.getComments(trackId: kTrackId)).thenAnswer((_) async => page);

      final result = await GetCommentsUsecase(repo).call(trackId: kTrackId);

      expect(result.comments, page.comments);
      verify(repo.getComments(trackId: kTrackId)).called(1);
      verifyNoMoreInteractions(repo);
    });
  });

  group('DeleteCommentUsecase', () {
    test('delegates to repository with trackId and commentId', () async {
      when(repo.deleteComment(trackId: kTrackId, commentId: kCommentId))
          .thenAnswer((_) async {});

      await DeleteCommentUsecase(repo)
          .call(trackId: kTrackId, commentId: kCommentId);

      verify(repo.deleteComment(trackId: kTrackId, commentId: kCommentId))
          .called(1);
      verifyNoMoreInteractions(repo);
    });
  });

  group('ToggleCommentLikeUsecase', () {
    test('calls toggleCommentLike with isCurrentlyLiked=false (liking)', () async {
      when(repo.toggleCommentLike(
        commentId: kCommentId,
        isCurrentlyLiked: false,
      )).thenAnswer((_) async {});

      await ToggleCommentLikeUsecase(repo).call(
        commentId: kCommentId,
        isCurrentlyLiked: false,
      );

      verify(repo.toggleCommentLike(
        commentId: kCommentId,
        isCurrentlyLiked: false,
      )).called(1);
    });

    test('calls toggleCommentLike with isCurrentlyLiked=true (unliking)', () async {
      when(repo.toggleCommentLike(
        commentId: kCommentId,
        isCurrentlyLiked: true,
      )).thenAnswer((_) async {});

      await ToggleCommentLikeUsecase(repo).call(
        commentId: kCommentId,
        isCurrentlyLiked: true,
      );

      verify(repo.toggleCommentLike(
        commentId: kCommentId,
        isCurrentlyLiked: true,
      )).called(1);
    });
  });

  group('GetLikersUsecase', () {
    test('returns list of users from repository', () async {
      when(repo.getLikers(trackId: kTrackId))
          .thenAnswer((_) async => [dummyUser]);

      final result = await GetLikersUsecase(repo).call(trackId: kTrackId);

      expect(result, [dummyUser]);
      verify(repo.getLikers(trackId: kTrackId)).called(1);
    });
  });

  group('GetRepliesUsecase', () {
    test('returns list of replies from repository', () async {
      final reply = dummyReply();
      when(repo.getReplies(commentId: kCommentId))
          .thenAnswer((_) async => [reply]);

      final result =
          await GetRepliesUsecase(repo).call(commentId: kCommentId);

      expect(result.length, 1);
      expect(result.first.id, kReplyId);
      verify(repo.getReplies(commentId: kCommentId)).called(1);
    });
  });

  group('DeleteReplyUsecase', () {
    test('delegates to repository with commentId and replyId', () async {
      when(repo.deleteReply(commentId: kCommentId, replyId: kReplyId))
          .thenAnswer((_) async {});

      await DeleteReplyUsecase(repo)
          .call(commentId: kCommentId, replyId: kReplyId);

      verify(repo.deleteReply(commentId: kCommentId, replyId: kReplyId))
          .called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}
