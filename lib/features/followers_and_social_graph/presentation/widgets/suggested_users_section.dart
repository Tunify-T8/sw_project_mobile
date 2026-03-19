import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/social_user_entity.dart';
import '../providers/mock_social_provider.dart';
import '../providers/network_lists_provider.dart';
import '../providers/social_actions_provider.dart';
import 'suggested_user_item.dart';

class SuggestedUsersSection extends ConsumerStatefulWidget {
  const SuggestedUsersSection({super.key});

  @override
  ConsumerState<SuggestedUsersSection> createState() =>
      _SuggestedUsersSectionState();
}

class _SuggestedUsersSectionState
    extends ConsumerState<SuggestedUsersSection> {
  final bool useMock = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSuggestedUsers);
  }

  Future<void> _loadSuggestedUsers() async {
    final state = useMock
        ? ref.read(mockSocialProvider)
        : ref.read(networkListsProvider);

    if (state.suggestedUsers.isEmpty && !state.hasLoadedOnce) {
      if (useMock) {
        await ref.read(mockSocialProvider.notifier).loadSuggestedUsers();
      } else {
        await ref.read(networkListsProvider.notifier).loadSuggestedUsers();
      }
    }
  }

  Future<void> _handleFollowToggle(SocialUserEntity user) async {
    if (useMock) {
      await ref.read(mockSocialProvider.notifier).toggleFollow(user.id);
    } else {
      await ref.read(socialActionsProvider).toggleFollow(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = useMock
        ? ref.watch(mockSocialProvider)
        : ref.watch(networkListsProvider);

    final users = state.suggestedUsers;

    final showInitialLoading = users.isEmpty && (state.isLoading || !state.hasLoadedOnce);
    final showInitialError =
        users.isEmpty && state.error != null && state.hasLoadedOnce;
    final showEmpty =
        users.isEmpty && !state.isLoading && state.error == null && state.hasLoadedOnce;

    if (showInitialLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (showInitialError) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            state.error!,
            style: const TextStyle(color: Colors.red),
          ),
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
            onFollowToggle: () => _handleFollowToggle(user),
          );
        },
      ),
    );
  }
}