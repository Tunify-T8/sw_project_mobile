import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'relationship_status_state.dart';
import 'social_graph_repository_provider.dart';

final relationshipStatusProvider = NotifierProvider.family<
    RelationshipStatusNotifier, RelationshipStatusState, String>(
  RelationshipStatusNotifier.new,
);

class RelationshipStatusNotifier extends Notifier<RelationshipStatusState> {
  final String userId;

  RelationshipStatusNotifier(this.userId);

  @override
  RelationshipStatusState build() {
    Future.microtask(() => loadStatus());
    return const RelationshipStatusState(isLoading: true);
  }

  Future<void> loadStatus() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final followStatus = await repository.getFollowStatus(userId);

      state = state.copyWith(
        isFollowing: followStatus.isFollowing,
        isBlocked: followStatus.isBlocked,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleFollow() async {
    final currentIsFollowing = state.isFollowing;
    if (currentIsFollowing == null) return;

    state = state.copyWith(
      isFollowing: !currentIsFollowing,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);

      if (currentIsFollowing) {
        await repository.unfollowUser(userId);
      } else {
        await repository.followUser(userId);
      }
    } catch (e) {
      state = state.copyWith(
        isFollowing: currentIsFollowing,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleBlock() async {
    final currentIsBlocked = state.isBlocked;
    if (currentIsBlocked == null) return;

    state = state.copyWith(
      isBlocked: !currentIsBlocked,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);

      if (currentIsBlocked) {
        await repository.unblockUser(userId);
      } else {
        await repository.blockUser(userId);
      }
    } catch (e) {
      state = state.copyWith(
        isBlocked: currentIsBlocked,
        error: e.toString(),
      );
    }
  }
}
