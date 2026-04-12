import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/enagement_providers.dart';

class CommentLikeButton extends ConsumerWidget {
  const CommentLikeButton({
    super.key,
    required this.trackId,
    required this.commentId,
    required this.baseLikesCount,
  });

  final String trackId;
  final String commentId;
  final int baseLikesCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref
        .watch(engagementProvider(trackId))
        .isCommentLiked(commentId);
    final likeCount = baseLikesCount + (isLiked ? 1 : 0);

    return GestureDetector(
      onTap: () => ref
          .read(engagementProvider(trackId).notifier)
          .toggleCommentLike(commentId),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.orangeAccent : Colors.white54,
            size: 18,
          ),
          if (likeCount > 0) ...[
            const SizedBox(height: 2),
            Text(
              likeCount.toString(),
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
