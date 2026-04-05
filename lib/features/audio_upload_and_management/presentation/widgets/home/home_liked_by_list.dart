import 'package:flutter/material.dart';

class HomeLikedByList extends StatelessWidget {
  const HomeLikedByList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 18),
        children: const [
          _LikedByCard(label: 'Billie Eilish'),
          SizedBox(width: 12),
          _LikedByCard(label: 'Ice Spice'),
          SizedBox(width: 12),
          _LikedByCard(label: 'MWB Chico'),
          SizedBox(width: 18),
        ],
      ),
    );
  }
}

class _LikedByCard extends StatelessWidget {
  const _LikedByCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 154,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 126,
            width: 154,
            decoration: BoxDecoration(
              color: const Color(0xFF1C2A3A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Text(
                        'LIKED BY',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.cloud, color: Colors.white38, size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Liked by',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
