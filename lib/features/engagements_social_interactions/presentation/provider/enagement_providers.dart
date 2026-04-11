import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/engagement_repository_impl.dart';
import '../../data/services/mock_engagement_store.dart';
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
import '../../domain/usecases/toggle_reply_like_usecase.dart'; // engagement addition
import '../../domain/usecases/get_liked_tracks_usecase.dart'; // engagement addition
import 'engagement_state.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final mockEngagementStoreProvider = Provider<MockEngagementStore>((ref) {
  return MockEngagementStore();
});

// set useMock to false and return RealEngagementRepositoryImpl when BE is ready
final engagementRepositoryProvider = Provider<EngagementRepository>((ref) {
  return EngagementRepositoryImpl(
    store: ref.watch(mockEngagementStoreProvider),
  );
});

// ── Use Cases ─────────────────────────────────────────────────────────────────

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

final toggleReplyLikeUsecaseProvider = Provider((ref) => // engagement addition
    ToggleReplyLikeUsecase(ref.watch(engagementRepositoryProvider)));

final getLikedTracksUsecaseProvider = Provider((ref) => // engagement addition
    GetLikedTracksUsecase(ref.watch(engagementRepositoryProvider)));

// ── Notifier ──────────────────────────────────────────────────────────────────

class EngagementNotifier extends Notifier<EngagementState> {
  EngagementNotifier(this._trackId);

  final String _trackId;
  static const String _viewerId = 'user_current_1'; // swap with real auth later

  @override
  EngagementState build() {
    return const EngagementState();
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
    state = state.copyWith(engagementStatus: EngagementStatus.loading);
    try {
      final updated = await ref
          .read(toggleLikeUsecaseProvider)
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
      state = state.copyWith(
        commentsStatus: EngagementStatus.success,
        commentsPage: page,
      );
    } catch (e) {
      state = state.copyWith(
        commentsStatus: EngagementStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> addComment({int? timestamp, required String text}) async {
    state = state.copyWith(commentsStatus: EngagementStatus.loading);
    try {
      await ref.read(addCommentUsecaseProvider).call(
            trackId: _trackId,
            viewerId: _viewerId,
            timestamp: timestamp,
            text: text,
          );
      await loadComments();
      await loadEngagement();
    } catch (e) {
      state = state.copyWith(
        commentsStatus: EngagementStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteComment(String commentId) async {
    await ref.read(deleteCommentUsecaseProvider).call(
          trackId: _trackId,
          commentId: commentId,
        );
    await loadComments();
    await loadEngagement();
  }

  void toggleCommentLike(String commentId) {
    final updated = Set<String>.from(state.likedCommentIds);
    if (updated.contains(commentId)) {
      updated.remove(commentId);
    } else {
      updated.add(commentId);
    }
    state = state.copyWith(likedCommentIds: updated);
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
