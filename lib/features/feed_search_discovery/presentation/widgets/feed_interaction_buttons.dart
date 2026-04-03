import 'package:flutter/material.dart';
import '../../domain/entities/feed_tab_type.dart';

class FeedInteractionButtons extends StatelessWidget {
  final bool isLiked;
  final bool? isReposted;
  final int likesCount;
  final int? repostsCount;
  final int commentsCount;
  final FeedType feedType;

  const FeedInteractionButtons({
    super.key,
    required this.isLiked,
    this.isReposted,
    required this.likesCount,
    this.repostsCount,
    required this.commentsCount,
    required this.feedType,
  });

  IconButton _buildInteractionButton({
    required Icon icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      padding: EdgeInsets.zero,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        (feedType != FeedType.classic)
            ? Column(
                children: [
                  _buildInteractionButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                    ),
                    onPressed: () {},
                  ),
                  Text(
                    likesCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),

                  _buildInteractionButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () {},
                  ),
                  Text(
                    commentsCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),

                  _buildInteractionButton(
                    icon: const Icon(Icons.more),
                    onPressed: () {},
                  ),
                ],
              )
            : Row(
                children: [
                  _buildInteractionButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                    ),
                    onPressed: () {},
                  ),
                  Text(
                    likesCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),

                  _buildInteractionButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () {},
                  ),
                  Text(
                    commentsCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  _buildInteractionButton(
                    icon: Icon(
                      Icons.repeat,
                      color: (isReposted ?? false) ? Colors.orange : null,
                    ),
                    onPressed: () {},
                  ),
                  Text(
                    (repostsCount ?? 0).toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
      ],
    );
  }
}
