import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/relationship_status_notifier.dart';

class RelationshipButton extends ConsumerWidget {
  final String userId;
  final bool? initialIsFollowing;
  final bool? initialIsBlocked;
  final bool isBlockMode;

  const RelationshipButton({
    super.key,
    required this.userId,
    this.initialIsFollowing,
    this.initialIsBlocked,
    this.isBlockMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relationshipState = ref.watch(relationshipStatusProvider(userId));
    final notifier = ref.read(relationshipStatusProvider(userId).notifier);

    final isFollowing = relationshipState.isFollowing ?? initialIsFollowing;
    final isBlocked = relationshipState.isBlocked ?? initialIsBlocked;
    final isSelected = isBlockMode ? isBlocked : isFollowing;

    if (isSelected == null) {
      if (relationshipState.error != null) {
        return SizedBox(
          height: 36,
          child: TextButton(
            key: Key('relationship_retry_$userId'),
            onPressed: notifier.loadStatus,
            child: const Text('Retry', style: TextStyle(fontSize: 15)),
          ),
        );
      }

      return SizedBox(
        key: Key('relationship_loading_$userId'),
        width: 80,
        height: 36,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final buttonText = isBlockMode
        ? (isSelected ? 'Unblock' : 'Block')
        : (isSelected ? 'Following' : 'Follow');

    return TextButton(
      key: Key('${isBlockMode ? 'block' : 'follow'}_button_$userId'),
      onPressed: isBlockMode
          ? notifier.toggleBlock
          : notifier.toggleFollow,
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF303030) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}
