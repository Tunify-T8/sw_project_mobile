import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/profile/presentation/screens/other_user_profile_screen.dart';

import '../../domain/entities/social_user_entity.dart';
import '../providers/network_lists_notifier.dart';
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
      return SizedBox(
        key: Key('${widget.listType.name}_loading'),
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (showInitialError) {
      return SizedBox(
        key: Key('${widget.listType.name}_error'),
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Something went wrong', style: TextStyle(color: Colors.white)),
            TextButton(
              key: Key('${widget.listType.name}_retry_button'),
              onPressed: _loadSuggestedUsers,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (showEmpty) {
      return SizedBox(
        key: Key('${widget.listType.name}_empty'),
        height: 200,
        child: const Center(
          child: Text(
            'No suggestions available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return SizedBox(
      key: Key('${widget.listType.name}_section'),
      height: 200,
      child: ListView.builder(
        key: Key('${widget.listType.name}_list'),
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return SuggestedUserItem(
            key: ValueKey('${widget.listType.name}_suggested_item_${user.id}'),
            user: user,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OtherUserProfileScreen(userId: user.id)),
              );
            },
          );
        },
      ),
    );
  }
}
