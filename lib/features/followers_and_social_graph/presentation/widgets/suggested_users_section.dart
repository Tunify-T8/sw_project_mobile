import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/profile/presentation/screens/other_user_profile_screen.dart';

import '../../domain/entities/social_user_entity.dart';
import '../providers/network_lists_notifier.dart';
import '../providers/social_actions_notifier.dart';
import 'suggested_user_item.dart';
import '../../domain/entities/network_list_type.dart';

class SuggestedUsersSection extends ConsumerStatefulWidget {
  final NetworkListType listType;
  const SuggestedUsersSection({super.key, required this.listType});

  @override
  ConsumerState<SuggestedUsersSection> createState() =>
      _SuggestedUsersSectionState();
}

class _SuggestedUsersSectionState extends ConsumerState<SuggestedUsersSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSuggestedUsers);
  }

  Future<void> _loadSuggestedUsers() async {
    final state = ref.read(networkListsProvider);

    if ((state.userLists[widget.listType] ?? []).isEmpty &&
        !state.hasLoadedOnce[widget.listType]!) {
      {
        (widget.listType == NetworkListType.suggestedUsers)
            ? await ref.read(networkListsProvider.notifier).loadSuggestedUsers()
            : await ref
                  .read(networkListsProvider.notifier)
                  .loadSuggestedArtists();
      }
    }
  }

  Future<void> _handleFollowToggle(SocialUserEntity user) async {
    await ref
        .read(socialActionsProvider)
        .toggleFollow(user: user, listType: widget.listType);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(networkListsProvider);

    final users = state.userLists[widget.listType] ?? [];

    final isLoading = state.isLoading[widget.listType]!;
    final error = state.error[widget.listType];
    final hasLoadedOnce = state.hasLoadedOnce[widget.listType]!;

    final showInitialLoading = users.isEmpty && (isLoading || !hasLoadedOnce);
    final showInitialError = users.isEmpty && error != null && hasLoadedOnce;
    final showEmpty =
        users.isEmpty && !isLoading && error == null && hasLoadedOnce;

    if (showInitialLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (showInitialError) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(error, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (showEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No suggestions available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return SuggestedUserItem(
            user: user,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OtherUserProfileScreen(userId: user.id)),
              );
            },
            onFollowToggle: () => _handleFollowToggle(user),
          );
        },
      ),
    );
  }
}
