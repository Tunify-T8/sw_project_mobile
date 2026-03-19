import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/network_list_type.dart';
import '../../domain/entities/social_user_entity.dart';
import '../providers/mock_social_provider.dart';
import '../providers/network_list_view_mapper.dart';
import '../providers/network_lists_provider.dart';
import '../providers/social_actions_provider.dart';
import '../widgets/network_lists_empty_state.dart';
import '../widgets/network_lists_error_state.dart';
import '../widgets/network_lists_true_friends_tile.dart';
import '../widgets/user_social_tile.dart';

class NetworkListsScreen extends ConsumerStatefulWidget {
  final String userId;
  final NetworkListType listType;

  const NetworkListsScreen({
    super.key,
    required this.userId,
    required this.listType,
  });

  @override
  ConsumerState<NetworkListsScreen> createState() => _NetworkListsScreenState();
}

class _NetworkListsScreenState extends ConsumerState<NetworkListsScreen> {
  final bool useMock = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadInitialData);
  }

  Future<void> _loadInitialData() async {
    final notifier = useMock
        ? ref.read(mockSocialProvider.notifier)
        : ref.read(networkListsProvider.notifier);

    await NetworkListViewMapper.loadInitialData(
      listType: widget.listType,
      userId: widget.userId,
      notifier: notifier,
    );
  }

  Future<void> _handleFollowToggle(SocialUserEntity user) async {
    if (useMock) {
      await ref.read(mockSocialProvider.notifier).toggleFollow(user.id);
    } else {
      await ref.read(socialActionsProvider).toggleFollow(user);
    }
  }

  Future<void> _handleBlockAction(SocialUserEntity user) async {
    if (useMock) {
      await ref.read(mockSocialProvider.notifier).toggleBlock(user.id);
    } else {
      await ref
          .read(socialActionsProvider)
          .toggleBlock(user: user, listType: widget.listType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listsState = useMock
        ? ref.watch(mockSocialProvider)
        : ref.watch(networkListsProvider);

    final List<SocialUserEntity> users = NetworkListViewMapper.getUsers(
      widget.listType,
      listsState,
    );

    final isLoading = listsState.isLoading;
    final error = listsState.error;
    final hasLoadedOnce = listsState.hasLoadedOnce;

    final showInitialLoading = users.isEmpty && (isLoading || !hasLoadedOnce);
    final showInitialError = users.isEmpty && error != null && hasLoadedOnce;
    final showEmpty =
        users.isEmpty && !isLoading && error == null && hasLoadedOnce;

    final String currentUserId = 'u2';
    final showTrueFriends = NetworkListViewMapper.shouldShowTrueFriends(
      listType: widget.listType,
      viewedUserId: widget.userId,
      currentUserId: currentUserId,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
        ),
        title: Text(NetworkListViewMapper.getTitle(widget.listType)),
      ),
      body: SafeArea(
        child: showInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : showInitialError
            ? NetworkListsErrorState(error: error, onRetry: _loadInitialData)
            : showEmpty
            ? const NetworkListsEmptyState()
            : RefreshIndicator(
                onRefresh: () async {
                  await _loadInitialData();
                },
                child: ListView.builder(
                  itemCount: showTrueFriends ? users.length + 1 : users.length,
                  itemBuilder: (context, index) {
                    if (showTrueFriends && index == 0) {
                      return NetworkListsTrueFriendsTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NetworkListsScreen(
                                userId: 'u1',
                                listType: NetworkListType.mutual,
                              ),
                            ),
                          );
                        },
                      );
                    }

                    final user = showTrueFriends
                        ? users[index - 1]
                        : users[index];

                    return UserSocialTile(
                      user: user,
                      listType: widget.listType,
                      onFollowToggle: widget.listType == NetworkListType.blocked
                          ? null
                          : () => _handleFollowToggle(user),
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
