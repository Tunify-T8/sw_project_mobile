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
  final ValueChanged<String> onRecentTap;
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
        onTap: (item) => onRecentTap(item.title),
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
    // Find a profile recent result whose name matches the query
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
        // Profile row at top (if match exists)
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
    // Bold the part that matches the query, normal weight for the rest
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
        // Arrow fills in the search bar with this suggestion (doesn't submit)
        onTap: () {
          // This is intentionally the same as onTap for now
          // When backend has suggestions, this would fill bar without submitting
          onTap();
        },
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
        borderRadius: BorderRadius.circular(isProfile ? 24 : 4),
        child: Image.network(
          item.artworkUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _PlaceholderLeading(isProfile: isProfile),
        ),
      );
    } else {
      leading = _PlaceholderLeading(isProfile: isProfile);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: SizedBox(width: 48, height: 48, child: leading),
      title: Row(
        children: [
          Flexible(
            child: Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isProfile && item.isCertified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 14),
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
}

class _PlaceholderLeading extends StatelessWidget {
  const _PlaceholderLeading({required this.isProfile});
  final bool isProfile;

  @override
  Widget build(BuildContext context) {
    if (isProfile) {
      return const CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFF2A2A2A),
        child: Icon(Icons.person, color: Colors.white38, size: 22),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 48,
        height: 48,
        color: const Color(0xFF2A2A2A),
        child: const Icon(Icons.music_note, color: Colors.white24, size: 20),
      ),
    );
  }
}

// ─── Empty hint ───────────────────────────────────────────────────────────────

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: Colors.white24, size: 48),
            SizedBox(height: 12),
            Text(
              'Search SoundCloud',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Find artists, tracks, albums, and playlists.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
