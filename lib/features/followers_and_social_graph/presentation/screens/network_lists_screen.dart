import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/network_list_type.dart';
import '../../domain/entities/social_user_entity.dart';
import '../providers/mock_social_provider.dart';
import '../providers/network_list_view_mapper.dart';
import '../providers/network_lists_provider.dart';
import '../providers/social_actions_provider.dart';
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
    final dynamic notifier;
    if (useMock) {
      notifier = ref.read(mockSocialProvider.notifier);
    } else {
      notifier = ref.read(networkListsProvider.notifier);
    }

    await NetworkListViewMapper.loadInitialData(
      listType: widget.listType,
      userId: widget.userId,
      notifier: notifier,
    );
  }

  Future<void> _onRefresh() async {
    await _loadInitialData();
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
    final dynamic listsState;
    if (useMock) {
      listsState = ref.watch(mockSocialProvider);
    } else {
      listsState = ref.watch(networkListsProvider);
    }

    final users = NetworkListViewMapper.getUsers(widget.listType, listsState);

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
        child: Stack(
          children: [
            if (showInitialLoading)
              const Center(child: CircularProgressIndicator())
            else if (showInitialError)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white70,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error!,
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
              )
            else if (showEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(height: 100),
                    Icon(Icons.people_outline, color: Colors.white70, size: 42),
                    SizedBox(height: 12),
                    Text(
                      'No users found',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              )
            else
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    if (showTrueFriends) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NetworkListsScreen(
                                        userId: 'u1',
                                        listType: NetworkListType.mutual,
                                      ),
                                ),
                              );
                            },
                            leading: CircleAvatar(child: Icon(Icons.people)),
                            title: Text(
                              'People who follow you back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'See your true friends',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                            tileColor: const Color(0xFF18181A),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 28.0,
                            ),
                          ),
                        );
                      } else {
                        final user = users[index - 1];

                        return UserSocialTile(
                          user: user,
                          listType: widget.listType,
                          onFollowToggle:
                              widget.listType == NetworkListType.blocked
                              ? null
                              : () => _handleFollowToggle(user),
                          onToggleNotifications: null,
                          onBlock: () => _handleBlockAction(user),
                        );
                      }
                    } else {
                      final user = users[index];

                      return UserSocialTile(
                        user: user,
                        listType: widget.listType,
                        onFollowToggle:
                            widget.listType == NetworkListType.blocked
                            ? null
                            : () => _handleFollowToggle(user),
                        onToggleNotifications: null,
                        onBlock: () => _handleBlockAction(user),
                      );
                    }
                  },
                ),
              ),

            if (isLoading && users.isNotEmpty)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),

            if (error != null && users.isNotEmpty)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Material(
                  color: Colors.red,
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
                            if (useMock) {
                              ref
                                  .read(mockSocialProvider.notifier)
                                  .clearError();
                            } else {
                              ref
                                  .read(networkListsProvider.notifier)
                                  .clearError();
                            }
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
        ),
      ),
    );
  }
}
