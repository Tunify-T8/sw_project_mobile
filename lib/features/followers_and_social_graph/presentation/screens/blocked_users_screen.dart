import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/network_list_type.dart';
import '../providers/network_lists_notifier.dart';
import '../widgets/network_lists_empty_state.dart';
import '../widgets/network_lists_error_state.dart';
import '../widgets/user_social_tile.dart';
import '../../../../../core/utils/navigation_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class BlockedUsersScreen extends ConsumerStatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  ConsumerState<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends ConsumerState<BlockedUsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadBlockedUsers);
  }

  Future<void> _loadBlockedUsers() async {
    final state = ref.read(networkListsProvider);
    final blockedUsers = state.userLists[NetworkListType.blocked] ?? const [];
    final hasLoadedOnce = state.hasLoadedOnce[NetworkListType.blocked] ?? false;

    if (blockedUsers.isEmpty && !hasLoadedOnce) {
      await ref.read(networkListsProvider.notifier).loadBlockedUsers();
      return;
    }

    await ref.read(networkListsProvider.notifier).loadBlockedUsers();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(networkListsProvider);

    final users = state.userLists[NetworkListType.blocked] ?? [];
    final isLoading = state.isLoading[NetworkListType.blocked] ?? false;
    final error = state.error[NetworkListType.blocked];
    final hasLoaded = state.hasLoadedOnce[NetworkListType.blocked] ?? false;

    final showInitialLoading = users.isEmpty && (isLoading || !hasLoaded);
    final showInitialError = users.isEmpty && error != null && hasLoaded;
    final showEmpty = users.isEmpty && !isLoading && error == null && hasLoaded;

    return Scaffold(
      key: const Key('blocked_users_screen'),
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        leading: IconButton(
          key: const Key('followers_social_graph_back_button'),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
        ),
        title: const Text('Blocked Users'),
      ),
      body: SafeArea(
        child: showInitialLoading
            ? const Center(key: Key('followers_social_graph_loading_indicator'), child: CircularProgressIndicator())
            : showInitialError
            ? NetworkListsErrorState(key: const Key('followers_social_graph_error_state'), onRetry: _loadBlockedUsers)
            : showEmpty
            ? const NetworkListsEmptyState(key: Key('followers_social_graph_empty_state'))
            : RefreshIndicator(
                key: const Key('blocked_users_refresh'),
                onRefresh: _loadBlockedUsers,
                child: ListView.builder(
                  key: const Key('blocked_users_list'),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    final currentUserId = ref.read(authControllerProvider).value?.id;
                    return UserSocialTile(
                      key: ValueKey('blocked_user_tile_${user.id}'),
                      onTap: () => navigateToProfile(
                        context,
                        user.id,
                        currentUserId: currentUserId,
                      ),
                      user: user,
                      listType: NetworkListType.blocked,
                      onToggleNotifications: null,
                    );
                  },
                ),
              ),
      ),
    );
  }
}
