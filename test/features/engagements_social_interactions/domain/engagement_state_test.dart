import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/engagements_social_interactions/domain/entities/comments_page_entity.dart';
import 'package:software_project/features/engagements_social_interactions/presentation/provider/engagement_state.dart';

import '../helpers/engagement_test_mocks.dart';

void main() {
  group('EngagementState', () {
    test('initial state has correct defaults', () {
      const state = EngagementState();

      expect(state.engagement, isNull);
      expect(state.commentsPage, isNull);
      expect(state.likers, isEmpty);
      expect(state.reposters, isEmpty);
      expect(state.likedCommentIds, isEmpty);
      expect(state.likedReplyIds, isEmpty);
      expect(state.engagementStatus, EngagementStatus.initial);
      expect(state.commentsStatus, EngagementStatus.initial);
      expect(state.error, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.isError, isFalse);
    });

    test('isLoading returns true only when engagementStatus is loading', () {
      final state = EngagementState(
        engagementStatus: EngagementStatus.loading,
      );
      expect(state.isLoading, isTrue);
      expect(state.isSuccess, isFalse);
      expect(state.isError, isFalse);
    });

    test('isSuccess returns true only when engagementStatus is success', () {
      final state = EngagementState(
        engagementStatus: EngagementStatus.success,
      );
      expect(state.isSuccess, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.isError, isFalse);
    });

    test('isError returns true only when engagementStatus is error', () {
      final state = EngagementState(
        engagementStatus: EngagementStatus.error,
        error: 'Something went wrong',
      );
      expect(state.isError, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
    });

    group('isCommentLiked', () {
      test('returns true when commentId is in likedCommentIds', () {
        final state = EngagementState(
          likedCommentIds: {kCommentId, 'comment-2'},
        );
        expect(state.isCommentLiked(kCommentId), isTrue);
      });

      test('returns false when commentId is not in likedCommentIds', () {
        const state = EngagementState(likedCommentIds: {'comment-2'});
        expect(state.isCommentLiked(kCommentId), isFalse);
      });

      test('returns false on empty likedCommentIds', () {
        const state = EngagementState();
        expect(state.isCommentLiked(kCommentId), isFalse);
      });
    });

    group('isReplyLiked', () {
      test('returns true when replyId is in likedReplyIds', () {
        final state = EngagementState(likedReplyIds: {kReplyId});
        expect(state.isReplyLiked(kReplyId), isTrue);
      });

      test('returns false when replyId is absent', () {
        const state = EngagementState();
        expect(state.isReplyLiked(kReplyId), isFalse);
      });
    });

    group('comments computed property', () {
      test('returns empty list when commentsPage is null', () {
        const state = EngagementState();
        expect(state.comments, isEmpty);
      });

      test('returns comments from commentsPage', () {
        final page = dummyCommentsPage();
        final state = EngagementState(commentsPage: page);
        expect(state.comments, page.comments);
      });
    });

    group('totalCommentsCount', () {
      test('returns 0 when commentsPage is null', () {
        const state = EngagementState();
        expect(state.totalCommentsCount, 0);
      });

      test('returns meta.totalCount when commentsPage is set', () {
        final page = CommentsPageEntity(
          comments: const [],
          meta: const CommentsPageMetaEntity(
            totalCount: 42,
            page: 1,
            totalPages: 5,
            hasNextPage: true,
          ),
        );
        final state = EngagementState(commentsPage: page);
        expect(state.totalCommentsCount, 42);
      });
    });

    group('copyWith', () {
      test('preserves existing values when no overrides given', () {
        final engagement = dummyEngagement();
        final state = EngagementState(
          engagement: engagement,
          engagementStatus: EngagementStatus.success,
          likedCommentIds: {kCommentId},
        );
        final copied = state.copyWith();

        expect(copied.engagement, state.engagement);
        expect(copied.engagementStatus, EngagementStatus.success);
        expect(copied.likedCommentIds, {kCommentId});
      });

      test('overrides only specified fields', () {
        final state = EngagementState(
          engagementStatus: EngagementStatus.loading,
          likedCommentIds: {kCommentId},
        );
        final updated = state.copyWith(
          engagementStatus: EngagementStatus.success,
        );

        expect(updated.engagementStatus, EngagementStatus.success);
        expect(updated.likedCommentIds, {kCommentId});
      });

      test('replaces likedCommentIds when provided', () {
        final state = EngagementState(likedCommentIds: {kCommentId});
        final updated = state.copyWith(likedCommentIds: {'comment-2'});

        expect(updated.likedCommentIds, {'comment-2'});
        expect(updated.likedCommentIds.contains(kCommentId), isFalse);
      });

      test('replaces likedReplyIds when provided', () {
        final state = EngagementState(likedReplyIds: {kReplyId});
        final updated = state.copyWith(likedReplyIds: {'reply-2'});

        expect(updated.likedReplyIds, {'reply-2'});
      });

      test('sets error to null when not provided in copyWith', () {
        final state = EngagementState(
          engagementStatus: EngagementStatus.error,
          error: 'oops',
        );
        final updated = state.copyWith(engagementStatus: EngagementStatus.loading);
        expect(updated.error, isNull);
      });
    });
  });
}
