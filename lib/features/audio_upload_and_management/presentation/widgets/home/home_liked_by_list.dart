// Upload Feature Guide:
// Purpose: Home surface widget that exposes upload entry points or upload-related discovery sections.
// Used by: home_discovery_sections
// Concerns: Supporting UI and infrastructure for upload and track management.
import 'package:flutter/material.dart';

class HomeLikedByList extends StatelessWidget {
  const HomeLikedByList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        children: const [
          _LikedByCard(label: 'Billie Eilish'),
          SizedBox(width: 12),
          _LikedByCard(label: 'Ice Spice'),
          SizedBox(width: 12),
          _LikedByCard(label: 'MWB Chico'),
          SizedBox(width: 16),
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
      width: 140,
      child: Column(
        children: [
          Container(
            height: 110,
            width: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF1C2A3A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Padding(
                  padding: EdgeInsets.all(6),
                  child: Row(
                    children: [
                      Text(
                        'LIKED BY',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
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
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const Text(
            'Liked by',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
