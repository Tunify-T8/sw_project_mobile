import 'package:flutter/material.dart';

class SearchArtworkPlaceholder extends StatelessWidget {
  const SearchArtworkPlaceholder({
    super.key,
    required this.size,
    this.isCircle = false,
  });

  final double size;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: size,
      height: size,
      color: const Color(0xFF2A2A2A),
      child: Icon(Icons.music_note, color: Colors.white24, size: size * 0.4),
    );
    if (isCircle) return ClipOval(child: child);
    return ClipRRect(borderRadius: BorderRadius.circular(4), child: child);
  }
}
