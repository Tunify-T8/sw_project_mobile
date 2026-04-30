import 'package:flutter/material.dart';
import '../../providers/search_provider.dart';

class SearchTypingSuggestions extends StatelessWidget {
  const SearchTypingSuggestions({
    super.key,
    required this.recentSearches,
    required this.recentResults,
    required this.query,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.onRecentTap,
    required this.onRecentRemove,
    required this.onClearAll,
  });

  final List<String> recentSearches;
  final List<RecentResultItem> recentResults;
  final String query;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;
  final ValueChanged<RecentResultItem> onRecentTap;
  final ValueChanged<RecentResultItem> onRecentRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final trimmed = query.trim();

    // Typing with text — show suggestions list
    if (trimmed.isNotEmpty && suggestions.isNotEmpty) {
      return _SuggestionsList(
        query: trimmed,
        suggestions: suggestions,
        recentResults: recentResults,
        onTap: onSuggestionTap,
      );
    }

    // No text — show recent results or hint
    if (recentResults.isNotEmpty) {
      return _RecentResultsList(
        results: recentResults,
        onTap: onRecentTap,
        onRemove: onRecentRemove,
        onClearAll: onClearAll,
      );
    }

    return const _SearchHint();
  }
}

// ─── Suggestions list while typing ───────────────────────────────────────────
// First item: profile match (bold, with avatar) if a profile name matches.
// Rest: plain text rows with ↗ arrow on right (bold typed portion).

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({
    required this.query,
    required this.suggestions,
    required this.recentResults,
    required this.onTap,
  });

  final String query;
  final List<String> suggestions;
  final List<RecentResultItem> recentResults;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    // Find a profile recent result whose name matches the query.
    // The artworkUrl on RecentResultItem already carries the profile picture
    // since recordResultTapped stores it when a profile tile is tapped.
    final profileMatch = recentResults
        .where(
          (r) =>
              r.kind == RecentResultKind.profile &&
              r.title.toLowerCase().contains(query.toLowerCase()),
        )
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        // Profile row at top (if a recent profile matches the typed query)
        if (profileMatch != null)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF2A2A2A),
              backgroundImage: profileMatch.artworkUrl != null
                  ? NetworkImage(profileMatch.artworkUrl!)
                  : null,
              child: profileMatch.artworkUrl == null
                  ? const Icon(Icons.person, color: Colors.white54, size: 20)
                  : null,
            ),
            title: Row(
              children: [
                Text(
                  profileMatch.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (profileMatch.isCertified) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, color: Colors.blue, size: 14),
                ],
              ],
            ),
            onTap: () => onTap(profileMatch.title),
          ),

        // Text suggestions with bold-typed prefix and ↗ arrow
        ...suggestions.map(
          (s) => _SuggestionTile(
            suggestion: s,
            query: query,
            onTap: () => onTap(s),
          ),
        ),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.query,
    required this.onTap,
  });

  final String suggestion;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Bold the part that matches the query, normal weight for the rest.
    final lower = suggestion.toLowerCase();
    final qLower = query.toLowerCase();
    final matchIdx = lower.indexOf(qLower);

    Widget titleWidget;
    if (matchIdx >= 0) {
      titleWidget = RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 15, color: Colors.white),
          children: [
            if (matchIdx > 0) TextSpan(text: suggestion.substring(0, matchIdx)),
            TextSpan(
              text: suggestion.substring(matchIdx, matchIdx + query.length),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: suggestion.substring(matchIdx + query.length)),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      titleWidget = Text(
        suggestion,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: titleWidget,
      trailing: GestureDetector(
        onTap: () => onTap(),
        child: const Icon(Icons.north_west, color: Colors.white38, size: 18),
      ),
      onTap: onTap,
    );
  }
}

// ─── Recent results list (no query) ──────────────────────────────────────────

class _RecentResultsList extends StatelessWidget {
  const _RecentResultsList({
    required this.results,
    required this.onTap,
    required this.onRemove,
    required this.onClearAll,
  });

  final List<RecentResultItem> results;
  final ValueChanged<RecentResultItem> onTap;
  final ValueChanged<RecentResultItem> onRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
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
        ),
        ...results.map(
          (item) => _RecentResultTile(
            item: item,
            onTap: () => onTap(item),
            onRemove: () => onRemove(item),
          ),
        ),
      ],
    );
  }
}

class _RecentResultTile extends StatelessWidget {
  const _RecentResultTile({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  final RecentResultItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isProfile = item.kind == RecentResultKind.profile;

    Widget leading;
    if (item.artworkUrl != null) {
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(isProfile ? 20 : 4),
        child: Image.network(
          item.artworkUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholderIcon(isProfile),
        ),
      );
    } else {
      leading = _placeholderIcon(isProfile);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: SizedBox(width: 40, height: 40, child: leading),
      title: Row(
        children: [
          Flexible(
            child: Text(
              item.title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.isCertified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 13),
          ],
        ],
      ),
      subtitle: Text(
        item.subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: GestureDetector(
        onTap: onRemove,
        child: const Icon(Icons.close, color: Colors.white38, size: 18),
      ),
      onTap: onTap,
    );
  }

  Widget _placeholderIcon(bool isProfile) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(isProfile ? 20 : 4),
      ),
      child: Icon(
        isProfile ? Icons.person : Icons.music_note,
        color: Colors.white38,
        size: 20,
      ),
    );
  }
}

// ─── Empty state hint ─────────────────────────────────────────────────────────

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, color: Colors.white24, size: 48),
          SizedBox(height: 12),
          Text(
            'Search for tracks, artists,\nor playlists',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
