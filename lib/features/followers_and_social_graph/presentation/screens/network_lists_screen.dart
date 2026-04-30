import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/navigation_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/network_list_type.dart';
import '../../domain/entities/social_user_entity.dart';
import '../providers/utils/network_list_view_mapper.dart';
import '../providers/network_lists_notifier.dart';
import '../widgets/network_lists_empty_state.dart';
import '../widgets/network_lists_error_state.dart';
import '../widgets/network_lists_true_friends_tile.dart';
import '../widgets/user_social_tile.dart';

class NetworkListsScreen extends ConsumerStatefulWidget {
  final String? userId;
  final NetworkListType listType;

  const NetworkListsScreen({
    super.key,
    this.userId,
    required this.listType,
  });

  @override
  ConsumerState<NetworkListsScreen> createState() => _NetworkListsScreenState();
}

class _NetworkListsScreenState extends ConsumerState<NetworkListsScreen> {
  late final String? myId;
  late final bool isMyProfile;

  @override
  void initState() {
    super.initState();
    myId = ref.read(authControllerProvider).value?.id;
    isMyProfile = widget.userId == null || widget.userId == myId;
    Future.microtask(() {
      ref.read(networkListsProvider.notifier).clearList(widget.listType);
      return _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final notifier = ref.read(networkListsProvider.notifier);

    await NetworkListViewMapper.loadInitialData(
      listType: widget.listType,
      userId: widget.userId,
      notifier: notifier,
      isMyProfile: isMyProfile,
    );
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
      isMyProfile: isMyProfile,
    );

    return Scaffold(
      key: Key('network_lists_screen_${widget.listType.name}'),
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        leading: IconButton(
          key: const Key('followers_social_graph_back_button'),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
        ),
        title: Text(NetworkListViewMapper.getTitle(widget.listType)),
      ),
      body: SafeArea(
        child: showInitialLoading
            ? const Center(key: Key('followers_social_graph_loading_indicator'), child: CircularProgressIndicator())
            : showInitialError
            ? NetworkListsErrorState(key: const Key('followers_social_graph_error_state'), onRetry: _loadInitialData)
            : showEmpty
            ? const NetworkListsEmptyState(key: Key('followers_social_graph_empty_state'))
            : RefreshIndicator(
                key: Key('${widget.listType.name}_refresh'),
                onRefresh: () async {
                  await _loadInitialData();
                },
                child: ListView.builder(
                  key: Key('${widget.listType.name}_list'),
                  itemCount: showTrueFriends ? users.length + 1 : users.length,
                  itemBuilder: (context, index) {
                    if (showTrueFriends && index == 0) {
                      return NetworkListsTrueFriendsTile(
                        key: const Key('true_friends_tile'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NetworkListsScreen(
                                listType: NetworkListType.trueFriends,
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
                      key: ValueKey('${widget.listType.name}_user_tile_${user.id}'),
                      user: user,
                      listType: widget.listType,
                      onTap: () => navigateToProfile(
                        context,
                        user.id,
                        currentUserId: myId,
                      ),
                      onToggleNotifications: null,
                    );
                  },
                ),
              ),
      ),
    );
  }
}
