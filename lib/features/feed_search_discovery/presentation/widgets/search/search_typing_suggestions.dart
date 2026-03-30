// lib/features/feed_search_discovery/presentation/widgets/search/search_typing_suggestions.dart

import 'package:flutter/material.dart';

class SearchTypingSuggestions extends StatelessWidget {
  const SearchTypingSuggestions({
    super.key,
    required this.recentSearches,
    required this.query,
    required this.onRecentTap,
    required this.onRecentRemove,
    required this.onClearAll,
  });

  final List<String> recentSearches;
  final String query;
  final ValueChanged<String> onRecentTap;
  final ValueChanged<String> onRecentRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent searches',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                child: const Text(
                  'Clear all',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            ],
          ),
          ...recentSearches.map(
            (q) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, color: Colors.white38),
              title: Text(
                q,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              trailing: GestureDetector(
                onTap: () => onRecentRemove(q),
                child: const Icon(Icons.close, color: Colors.white38, size: 18),
              ),
              onTap: () => onRecentTap(q),
            ),
          ),
          const Divider(color: Colors.white12, height: 24),
        ],
        if (query.trim().isEmpty) ...[
          const SizedBox(height: 24),
          const Icon(Icons.search, color: Colors.white24, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Search SoundCloud',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Find artists, tracks, albums, and playlists.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ],
    );
  }
}
