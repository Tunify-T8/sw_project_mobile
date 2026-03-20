import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/network_list_type.dart';
import '../../domain/entities/social_user_entity.dart';
import '../providers/mock_social_provider.dart';
import '../providers/network_lists_provider.dart';
import '../providers/social_actions_provider.dart';
import '../widgets/network_lists_empty_state.dart';
import '../widgets/network_lists_error_state.dart';
import '../widgets/user_social_tile.dart';

class BlockedUsersScreen extends ConsumerStatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  ConsumerState<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends ConsumerState<BlockedUsersScreen> {
  final bool useMock = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadBlockedUsers);
  }

  Future<void> _loadBlockedUsers() async {
    final state = useMock
        ? ref.read(mockSocialProvider)
        : ref.read(networkListsProvider);

    if (state.blockedUsers.isEmpty && !state.hasLoadedOnce) {
      if (useMock) {
        await ref.read(mockSocialProvider.notifier).loadBlockedUsers();
      } else {
        await ref.read(networkListsProvider.notifier).loadBlockedUsers();
      }
      return;
    }

    if (useMock) {
      await ref.read(mockSocialProvider.notifier).loadBlockedUsers();
    } else {
      await ref.read(networkListsProvider.notifier).loadBlockedUsers();
    }
  }

  Future<void> _handleBlockAction(SocialUserEntity user) async {
    if (useMock) {
      await ref.read(mockSocialProvider.notifier).toggleBlock(user.id);
    } else {
      await ref
          .read(socialActionsProvider)
          .toggleBlock(user: user, listType: NetworkListType.blocked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = useMock
        ? ref.watch(mockSocialProvider)
        : ref.watch(networkListsProvider);

    final users = state.blockedUsers;

    final showInitialLoading =
        users.isEmpty && (state.isLoading || !state.hasLoadedOnce);
    final showInitialError =
        users.isEmpty && state.error != null && state.hasLoadedOnce;
    final showEmpty =
        users.isEmpty &&
        !state.isLoading &&
        state.error == null &&
        state.hasLoadedOnce;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
        ),
        title: const Text('Blocked Users'),
      ),
      body: SafeArea(
        child: showInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : showInitialError
            ? NetworkListsErrorState(
                error: state.error!,
                onRetry: _loadBlockedUsers,
              )
            : showEmpty
            ? const NetworkListsEmptyState()
            : RefreshIndicator(
                onRefresh: _loadBlockedUsers,
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return UserSocialTile(
                      user: user,
                      listType: NetworkListType.blocked,
                      onFollowToggle: null,
                      onToggleNotifications: null,
                      onBlock: () => _handleBlockAction(user),
                    );
                  },
                ),
              ),
      ),
    );
  }
}