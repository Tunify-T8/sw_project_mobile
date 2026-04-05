import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/profile/presentation/screens/profile_screen.dart';

import '../../domain/entities/network_list_type.dart';
import '../../domain/entities/social_user_entity.dart';
import '../providers/utils/network_list_view_mapper.dart';
import '../providers/network_lists_notifier.dart';
import '../providers/social_actions_notifier.dart';
import '../widgets/network_lists_empty_state.dart';
import '../widgets/network_lists_error_state.dart';
import '../widgets/network_lists_true_friends_tile.dart';
import '../widgets/user_social_tile.dart';

class NetworkListsScreen extends ConsumerStatefulWidget {
  final String? userId;
  final NetworkListType listType;
  final bool isMyProfile;

  const NetworkListsScreen({
    super.key,
    this.userId,
    required this.listType,
    required this.isMyProfile,
  });

  @override
  ConsumerState<NetworkListsScreen> createState() => _NetworkListsScreenState();
}

class _NetworkListsScreenState extends ConsumerState<NetworkListsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadInitialData);
  }

  Future<void> _loadInitialData() async {
    final notifier = ref.read(networkListsProvider.notifier);

    await NetworkListViewMapper.loadInitialData(
      listType: widget.listType,
      userId: widget.userId,
      notifier: notifier,
      isMyProfile: widget.isMyProfile,
    );
  }

  Future<void> _handleFollowToggle(SocialUserEntity user) async {
    await ref
        .read(socialActionsProvider)
        .toggleFollow(user: user, listType: widget.listType);
  }

  @override
  Widget build(BuildContext context) {
    final listsState = ref.watch(networkListsProvider);

    final List<SocialUserEntity> users = NetworkListViewMapper.getUsers(
      widget.listType,
      listsState,
    );

    final isLoading = listsState.isLoading[widget.listType]!;
    final error = listsState.error[widget.listType];
    final hasLoadedOnce = listsState.hasLoadedOnce[widget.listType]!;

    final showInitialLoading = users.isEmpty && (isLoading || !hasLoadedOnce);
    final showInitialError = users.isEmpty && error != null && hasLoadedOnce;
    final showEmpty =
        users.isEmpty && !isLoading && error == null && hasLoadedOnce;

    final showTrueFriends = NetworkListViewMapper.shouldShowTrueFriends(
      listType: widget.listType,
      isMyProfile: widget.isMyProfile,
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
                                listType: NetworkListType.trueFriends,
                                isMyProfile: true,
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      onFollowToggle: () => _handleFollowToggle(user),
                      onToggleNotifications: null,
                    );
                  },
                ),
              ),
      ),
    );
  }
}
