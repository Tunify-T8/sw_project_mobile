import 'package:flutter/material.dart';

class FeedInteractionButtons extends StatelessWidget {
  final bool isLiked;
  final int likesCount;
  final int commentsCount;

  const FeedInteractionButtons({
    super.key,
    required this.isLiked,
    required this.likesCount,
    required this.commentsCount,
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
        Column(
          children: [
            _buildInteractionButton(
              icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
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
        ),
      ],
    );
  }
}
