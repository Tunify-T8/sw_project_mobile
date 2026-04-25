import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/enagement_providers.dart';
import '../screens/comments_screen.dart';

class CommentButton extends ConsumerWidget {
  final String trackId;

  const CommentButton({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(engagementProvider(trackId));

    return Column(
      children: [
        // Key: EngagementKeys.commentButton
        IconButton(
          key: const Key('comment_button'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommentsScreen(trackId: trackId),
            ),
          ),
          icon: const Icon(Icons.comment, color: Colors.white),
        ),
        Text(
          (state.engagement?.commentCount ?? 0).toString(),
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ],
    );
  }
}
