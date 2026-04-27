import 'package:flutter/material.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({super.key, required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.play_arrow, color: Colors.black, size: 28),
        onPressed: onTap,
      ),
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({super.key, required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.shuffle, color: Colors.white, size: 28),
      onPressed: onTap,
    );
  }
}
