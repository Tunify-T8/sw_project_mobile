import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/enagement_providers.dart';
import '../provider/engagement_state.dart';

class LikeButton extends ConsumerStatefulWidget {
  final String trackId;
  final bool showCount;

  const LikeButton({super.key, required this.trackId, this.showCount = true});

  @override
  ConsumerState<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<LikeButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(engagementProvider(widget.trackId));
      if (state.engagementStatus == EngagementStatus.initial) {
        ref.read(engagementProvider(widget.trackId).notifier).loadEngagement();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(engagementProvider(widget.trackId));
    final isLiked = state.engagement?.isLiked ?? false;
    final likeCount = state.engagement?.likeCount ?? 0;

    return Column(
      children: [
        // Key: EngagementKeys.likeButton
        IconButton(
          key: const Key('like_button'),
          onPressed: () => ref
              .read(engagementProvider(widget.trackId).notifier)
              .toggleLike(),
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.orange : Colors.white,
          ),
          padding: EdgeInsets.zero,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        if (widget.showCount)
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
