import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/network_list_type.dart';
import '../../domain/entities/social_user_entity.dart';
import 'network_lists_provider.dart';
import 'social_graph_repository_provider.dart';

final socialActionsProvider = Provider<SocialActionsNotifier>((ref) {
  return SocialActionsNotifier(ref);
});

class SocialActionsNotifier {
  final Ref ref;

  SocialActionsNotifier(this.ref);

  Future<void> toggleFollow(SocialUserEntity user) async {
    final repository = ref.read(socialGraphRepositoryProvider);
    final listsNotifier = ref.read(networkListsProvider.notifier);

    try {
      if (user.isFollowing) {
        await repository.unfollowUser(user.id);
        listsNotifier.updateFollowStatus(userId: user.id, isFollowing: false);
      } else {
        await repository.followUser(user.id);
        listsNotifier.updateFollowStatus(userId: user.id, isFollowing: true);
      }
    } catch (e) {
      listsNotifier.setError(e.toString());
    }
  }

  Future<void> toggleBlock({
    required SocialUserEntity user,
    required NetworkListType listType,
  }) async {
    final repository = ref.read(socialGraphRepositoryProvider);
    final listsNotifier = ref.read(networkListsProvider.notifier);

    try {
      if (user.isBlocked) {
        await repository.unblockUser(user.id);
        listsNotifier.updateBlockStatus(userId: user.id, isBlocked: false);
      } else {
        await repository.blockUser(user.id);
        listsNotifier.updateBlockStatus(userId: user.id, isBlocked: true);
      }
    } catch (e) {
      listsNotifier.setError(e.toString());
    }
  }
}
