import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/network_list_type.dart';
import '../../domain/entities/social_user_entity.dart';
import 'network_lists_notifier.dart';
import 'social_graph_repository_provider.dart';

final socialActionsProvider = Provider<SocialActionsNotifier>((ref) {
  return SocialActionsNotifier(ref);
});

class SocialActionsNotifier {
  final Ref ref;

  SocialActionsNotifier(this.ref);

  Future<void> toggleFollow({
    required SocialUserEntity user,
    required NetworkListType listType,
  }) async {
    final repository = ref.read(socialGraphRepositoryProvider);
    final listsNotifier = ref.read(networkListsProvider.notifier);
    final nextIsFollowing = !user.isFollowing;

    try {
      if (user.isFollowing) {
        await repository.unfollowUser(user.id);
      } else {
        await repository.followUser(user.id);
      }

      listsNotifier.updateFollowStatus(
        userId: user.id,
        isFollowing: nextIsFollowing,
      );
    } catch (e) {
      listsNotifier.setListError(
        type: listType,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> toggleBlock({
    required SocialUserEntity user,
    required NetworkListType listType,
  }) async {
    final repository = ref.read(socialGraphRepositoryProvider);
    final listsNotifier = ref.read(networkListsProvider.notifier);
    final nextIsBlocked = !user.isBlocked;

    try {
      if (user.isBlocked) {
        await repository.unblockUser(user.id);
      } else {
        await repository.blockUser(user.id);
      }

      listsNotifier.updateBlockStatus(
        userId: user.id,
        isBlocked: nextIsBlocked,
      );
    } catch (e) {
      listsNotifier.setListError(
        type: listType,
        errorMessage: e.toString(),
      );
    }
  }
}
