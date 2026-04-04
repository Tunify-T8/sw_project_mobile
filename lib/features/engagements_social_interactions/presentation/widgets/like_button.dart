import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/enagement_providers.dart';

class LikeButton extends ConsumerWidget {
  final String trackId;

  const LikeButton({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(engagementProvider(trackId));
    final isLiked = state.engagement?.isLiked ?? false;
    final likeCount = state.engagement?.likeCount ?? 0;

    return Column(
      children: [
        IconButton(
          onPressed: () => ref
              .read(engagementProvider(trackId).notifier)
              .toggleLike(),
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.orange : Colors.white,
          ),
          padding: EdgeInsets.zero,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        Text(
          likeCount.toString(),
          style: TextStyle(
            color: isLiked ? Colors.orange : Colors.white,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
