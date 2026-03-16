import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/network_list_type.dart';
import '../../domain/entities/social_user_entity.dart';
import '../providers/network_lists_provider.dart';
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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final notifier = ref.read(networkListsProvider.notifier);

    switch (widget.listType) {
      case NetworkListType.following:
        await notifier.loadFollowingList(userId: widget.userId);
        break;
      case NetworkListType.followers:
        await notifier.loadFollowersList(userId: widget.userId);
        break;
      case NetworkListType.suggested:
        await notifier.loadSuggestedUsers();
        break;
      case NetworkListType.blocked:
        await notifier.loadBlockedUsers();
        break;
      case NetworkListType.mutual:
        await notifier.loadMutualUsers(userId: widget.userId);
        break;
    }
  }

  String _getTitle() {
    switch (widget.listType) {
      case NetworkListType.following:
        return 'Following';
      case NetworkListType.followers:
        return 'Followers';
      case NetworkListType.suggested:
        return 'Suggested Users';
      case NetworkListType.blocked:
        return 'Blocked Users';
      case NetworkListType.mutual:
        return 'Mutual Friends';
    }
  }

  List<SocialUserEntity> _getUsers(state) {
    switch (widget.listType) {
      case NetworkListType.following:
        return state.followingUsers;
      case NetworkListType.followers:
        return state.followersUsers;
      case NetworkListType.suggested:
        return state.suggestedUsers;
      case NetworkListType.blocked:
        return state.blockedUsers;
      case NetworkListType.mutual:
        return state.mutualUsers;
    }
  }

  bool _isLoading(state) {
    switch (widget.listType) {
      case NetworkListType.following:
        return state.isLoadingFollowing;
      case NetworkListType.followers:
        return state.isLoadingFollowers;
      case NetworkListType.suggested:
        return state.isLoadingSuggested;
      case NetworkListType.blocked:
        return state.isLoadingBlocked;
      case NetworkListType.mutual:
        return state.isLoadingMutual;
    }
  }

  Future<void> _onRefresh() async {
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final listsState = ref.watch(networkListsProvider);
    final users = _getUsers(listsState);
    final isLoading = _isLoading(listsState);
    final error = listsState.error;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        title: Text(_getTitle()),
      ),
      body: Builder(
        builder: (context) {
          if (isLoading && users.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (error != null && users.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white70,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Something went wrong',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadInitialData,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (users.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                children: const [
                  SizedBox(height: 160),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: Colors.white70,
                          size: 42,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No users found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: Color(0xFF2A2A2A),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return UserSocialTile(
                      user: user,
                      listType: widget.listType,
                      onFollowToggle: widget.listType == NetworkListType.blocked
                          ? null
                          : () {
                              final notifier =
                                  ref.read(networkListsProvider.notifier);

                              if (user.isFollowing) {
                                notifier.unfollowUser(user.id);
                              } else {
                                notifier.followUser(user.id);
                              }
                            },
                      onToggleNotifications:
                          widget.listType == NetworkListType.following
                              ? () {
                                  ref
                                      .read(networkListsProvider.notifier)
                                      .toggleNotifications(user.id);
                                }
                              : null,
                      onBlock: widget.listType == NetworkListType.blocked
                          ? null
                          : () {
                              ref
                                  .read(networkListsProvider.notifier)
                                  .blockUser(user.id);
                            },
                    );
                  },
                ),
              ),

              if (isLoading && users.isNotEmpty)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    minHeight: 2,
                  ),
                ),

              if (error != null && users.isNotEmpty)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Material(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(networkListsProvider.notifier)
                                  .clearError();
                            },
                            child: const Text(
                              'Dismiss',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}