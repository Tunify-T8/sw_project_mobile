import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/profile/presentation/providers/profile_provider.dart';
import '../../data/api/real_engagement_api.dart';
import '../../data/repository/real_engagement_repository_impl.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../../domain/usecases/get_track_engagement_usecase.dart';
import '../../domain/usecases/toggle_like_usecase.dart';
import '../../domain/usecases/repost_track_usecase.dart';
import '../../domain/usecases/remove_repost_usecase.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/get_likers_usecase.dart';
import '../../domain/usecases/get_reposters_usecase.dart';
import '../../domain/usecases/get_replies_usecase.dart';
import '../../domain/usecases/add_reply_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/delete_reply_usecase.dart';
import '../../domain/usecases/toggle_comment_like_usecase.dart';
import '../../domain/usecases/toggle_reply_like_usecase.dart';
import '../../domain/usecases/get_liked_tracks_usecase.dart'; // engagement addition
import '../../domain/usecases/get_user_reposts_usecase.dart';
import '../../domain/entities/track_engagement_entity.dart';
import '../../domain/entities/comments_page_entity.dart';
import '../../domain/entities/reply_entity.dart';
import 'engagement_state.dart';

//Infrastructure

final _realEngagementApiProvider = Provider<RealEngagementApi>((ref) {
  return RealEngagementApi(dio: ref.watch(dioProvider));
});

final trackTotalPlaysProvider = FutureProvider.family<int, String>((
  ref,
  trackId,
) async {
  return ref.watch(_realEngagementApiProvider).getTrackTotalPlays(trackId);
});

final engagementRepositoryProvider = Provider<EngagementRepository>((ref) {
  return RealEngagementRepositoryImpl(api: ref.watch(_realEngagementApiProvider));
});

//Use Cases

final getTrackEngagementUsecaseProvider = Provider((ref) =>
    GetTrackEngagementUsecase(ref.watch(engagementRepositoryProvider)));

final toggleLikeUsecaseProvider = Provider((ref) =>
    ToggleLikeUsecase(ref.watch(engagementRepositoryProvider)));

final repostTrackUsecaseProvider = Provider((ref) =>
    RepostTrackUsecase(ref.watch(engagementRepositoryProvider)));

final removeRepostUsecaseProvider = Provider((ref) =>
    RemoveRepostUsecase(ref.watch(engagementRepositoryProvider)));

final getCommentsUsecaseProvider = Provider((ref) =>
    GetCommentsUsecase(ref.watch(engagementRepositoryProvider)));

final addCommentUsecaseProvider = Provider((ref) =>
    AddCommentUsecase(ref.watch(engagementRepositoryProvider)));

final getLikersUsecaseProvider = Provider((ref) =>
    GetLikersUsecase(ref.watch(engagementRepositoryProvider)));

final getRepostersUsecaseProvider = Provider((ref) =>
    GetRepostersUsecase(ref.watch(engagementRepositoryProvider)));

final getRepliesUsecaseProvider = Provider((ref) =>
    GetRepliesUsecase(ref.watch(engagementRepositoryProvider)));

final addReplyUsecaseProvider = Provider((ref) =>
    AddReplyUsecase(ref.watch(engagementRepositoryProvider)));

final deleteCommentUsecaseProvider = Provider((ref) =>
    DeleteCommentUsecase(ref.watch(engagementRepositoryProvider)));

final deleteReplyUsecaseProvider = Provider((ref) =>
    DeleteReplyUsecase(ref.watch(engagementRepositoryProvider)));

final toggleCommentLikeUsecaseProvider = Provider((ref) =>
    ToggleCommentLikeUsecase(ref.watch(engagementRepositoryProvider)));

final toggleReplyLikeUsecaseProvider = Provider((ref) =>
    ToggleReplyLikeUsecase(ref.watch(engagementRepositoryProvider)));

final getLikedTracksUsecaseProvider = Provider((ref) => // engagement addition
    GetLikedTracksUsecase(ref.watch(engagementRepositoryProvider)));

final getUserRepostsUsecaseProvider = Provider((ref) =>
    GetUserRepostsUsecase(ref.watch(engagementRepositoryProvider)));

// ── Notifier ──────────────────────────────────────────────────────────────────

class EngagementNotifier extends Notifier<EngagementState> {
  EngagementNotifier(this._trackId);

  final String _trackId;

  String get _viewerId =>
      ref.read(authControllerProvider).value?.id ?? 'user_current_1';

  @override
  EngagementState build() {
    return const EngagementState();
  }

  void seedFromFeed({
    required int likeCount,
    required int repostCount,
    required int commentCount,
    required bool isLiked,
    required bool isReposted,
  }) {
    if (state.engagementStatus != EngagementStatus.initial) return;
    state = state.copyWith(
      engagementStatus: EngagementStatus.success,
      engagement: TrackEngagementEntity(
        trackId: _trackId,
        likeCount: likeCount,
        repostCount: repostCount,
        commentCount: commentCount,
        isLiked: isLiked,
        isReposted: isReposted,
      ),
    );
  }

  Future<void> loadEngagement() async {
    state = state.copyWith(engagementStatus: EngagementStatus.loading);
    try {
      final engagement = await ref
          .read(getTrackEngagementUsecaseProvider)
          .call(trackId: _trackId);
      state = state.copyWith(
        engagementStatus: EngagementStatus.success,
        engagement: engagement,
      );
    } catch (e) {
      state = state.copyWith(
        engagementStatus: EngagementStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleLike() async {
    final previous = state.engagement;
    if (previous != null) {
      // Optimistic update — flip before the first await so callers read the new
      // state synchronously (e.g. the liked-tracks screen checks isLiked after
      // the options sheet closes, which happens before the API returns).
      state = state.copyWith(
        engagement: previous.copyWith(
          isLiked: !previous.isLiked,
          likeCount: previous.isLiked
              ? (previous.likeCount - 1).clamp(0, 999999)
              : previous.likeCount + 1,
        ),
      );
    }
    try {
      final updated = await ref
          .read(toggleLikeUsecaseProvider)
          .call(trackId: _trackId, viewerId: _viewerId);
      state = state.copyWith(
        engagementStatus: EngagementStatus.success,
        engagement: updated,
      );
    } catch (e) {
      if (previous != null) state = state.copyWith(engagement: previous);
      state = state.copyWith(
        engagementStatus: EngagementStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> repostTrack({String? caption}) async {
    state = state.copyWith(engagementStatus: EngagementStatus.loading);
    try {
      final updated = await ref
          .read(repostTrackUsecaseProvider)
          .call(trackId: _trackId, viewerId: _viewerId, caption: caption);
      state = state.copyWith(
        engagementStatus: EngagementStatus.success,
        engagement: updated,
      );
    } catch (e) {
      state = state.copyWith(
        engagementStatus: EngagementStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> removeRepost() async {
    state = state.copyWith(engagementStatus: EngagementStatus.loading);
    try {
      final updated = await ref
          .read(removeRepostUsecaseProvider)
          .call(trackId: _trackId, viewerId: _viewerId);
      state = state.copyWith(
        engagementStatus: EngagementStatus.success,
        engagement: updated,
      );
    } catch (e) {
      state = state.copyWith(
        engagementStatus: EngagementStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> loadComments() async {
    state = state.copyWith(commentsStatus: EngagementStatus.loading);
    try {
      final page = await ref
          .read(getCommentsUsecaseProvider)
          .call(trackId: _trackId);
      final syncedEngagement = state.engagement?.copyWith(
        commentCount: page.meta.totalCount,
      );
      final serverLikedIds = page.comments
          .where((c) => c.isLiked)
          .map((c) => c.id)
          .toSet();
      // Merge with existing session state so optimistic likes survive a reload
      // when the server doesn't return per-user isLiked for comments.
      final mergedLikedIds = state.likedCommentIds.union(serverLikedIds);
      state = state.copyWith(
        commentsStatus: EngagementStatus.success,
        commentsPage: page,
        engagement: syncedEngagement ?? state.engagement,
        likedCommentIds: mergedLikedIds,
      );
    } catch (e) {
      state = state.copyWith(
        commentsStatus: EngagementStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> addComment({int? timestamp, required String text}) async {
    final previousEngagement = state.engagement;
    if (previousEngagement != null) {
      state = state.copyWith(
        engagement: previousEngagement.copyWith(
          commentCount: previousEngagement.commentCount + 1,
        ),
      );
    }
    state = state.copyWith(commentsStatus: EngagementStatus.loading);
    try {
      await ref.read(addCommentUsecaseProvider).call(
            trackId: _trackId,
            viewerId: _viewerId,
            timestamp: timestamp,
            text: text,
          );
      await loadComments();
    } catch (e) {
      state = state.copyWith(
        engagement: previousEngagement,
        commentsStatus: EngagementStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await ref.read(deleteCommentUsecaseProvider).call(
            trackId: _trackId,
            commentId: commentId,
          );
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
      // 404 = already gone, proceed to reload
    }
    // GET fires only after DELETE response is fully received
    await loadComments();
  }

  Future<void> toggleCommentLike(String commentId) async {
    final wasLiked = state.likedCommentIds.contains(commentId);
    final updated = Set<String>.from(state.likedCommentIds);
    if (wasLiked) {
      updated.remove(commentId);
    } else {
      updated.add(commentId);
    }
    state = state.copyWith(likedCommentIds: updated);
    try {
      await ref.read(toggleCommentLikeUsecaseProvider).call(
            commentId: commentId,
            isCurrentlyLiked: wasLiked,
          );
    } catch (_) {
      // Revert on failure
      final reverted = Set<String>.from(state.likedCommentIds);
      if (wasLiked) {
        reverted.add(commentId);
      } else {
        reverted.remove(commentId);
      }
      state = state.copyWith(likedCommentIds: reverted);
    }
  }

  Future<void> toggleReplyLike({required String commentId, required String replyId}) async {
    final wasLiked = state.likedReplyIds.contains(replyId);
    final updated = Set<String>.from(state.likedReplyIds);
    if (wasLiked) {
      updated.remove(replyId);
    } else {
      updated.add(replyId);
    }
    state = state.copyWith(likedReplyIds: updated);
    try {
      await ref.read(toggleReplyLikeUsecaseProvider).call(
            commentId: commentId,
            replyId: replyId,
            viewerId: _viewerId,
          );
    } catch (_) {
      final reverted = Set<String>.from(state.likedReplyIds);
      if (wasLiked) {
        reverted.add(replyId);
      } else {
        reverted.remove(replyId);
      }
      state = state.copyWith(likedReplyIds: reverted);
    }
  }

  void seedReplyLikes(List<ReplyEntity> replies) {
    final likedIds = replies
        .where((r) => r.isLikedByViewer)
        .map((r) => r.id)
        .toSet();
    state = state.copyWith(likedReplyIds: likedIds);
  }

  Future<void> loadLikers() async {
    state = state.copyWith(likersStatus: EngagementStatus.loading);
    try {
      final likers = await ref
          .read(getLikersUsecaseProvider)
          .call(trackId: _trackId);
      state = state.copyWith(
        likersStatus: EngagementStatus.success,
        likers: likers,
      );
    } catch (e) {
      state = state.copyWith(
        likersStatus: EngagementStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> loadReposters() async {
    state = state.copyWith(repostersStatus: EngagementStatus.loading);
    try {
      final reposters = await ref
          .read(getRepostersUsecaseProvider)
          .call(trackId: _trackId);
      state = state.copyWith(
        repostersStatus: EngagementStatus.success,
        reposters: reposters,
      );
    } catch (e) {
      state = state.copyWith(
        repostersStatus: EngagementStatus.error,
        error: e.toString(),
      );
    }
  }
}

final engagementProvider =
    NotifierProvider.family<EngagementNotifier, EngagementState, String>(
  (trackId) => EngagementNotifier(trackId),
);
