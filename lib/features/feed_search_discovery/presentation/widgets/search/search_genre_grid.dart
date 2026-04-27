import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/search_genre_entity.dart';
import '../../screens/genre_detail_screen.dart';

// ─── DATA MODEL ───────────────────────────────────────────────────────────────
// Unchanged from original — same IDs, labels, colors, heights.

class _GenreItem {
  const _GenreItem(this.id, this.label, this.color, this.height, this.icon);

  final String id;
  final String label;
  final int color;
  final double height;
  final IconData icon;
}

const _leftColumn = [
  _GenreItem('hip_hop_rap', 'Hip Hop & Rap', 0xFFA259FF, 140, Icons.mic),
  _GenreItem('pop', 'Pop', 0xFFFFD60A, 210, Icons.star),
  _GenreItem('chill', 'Chill', 0xFF0FA3B1, 100, Icons.spa),
  _GenreItem('workout', 'Workout', 0xFF10A674, 140, Icons.fitness_center),
  _GenreItem('house', 'House', 0xFFFF4FA3, 210, Icons.headphones),
  _GenreItem('at_home', 'At Home', 0xFFA259FF, 100, Icons.home),
  _GenreItem('study', 'Study', 0xFFFF4FA3, 140, Icons.menu_book),
  _GenreItem('indie', 'Indie', 0xFF2D6CDF, 210, Icons.album),
  _GenreItem('country', 'Country', 0xFFFF8C42, 100, Icons.grass),
  _GenreItem('rock', 'Rock', 0xFFFF3D2E, 100, Icons.bolt),
];

const _rightColumn = [
  _GenreItem('electronic', 'Electronic', 0xFFFF4FA3, 210, Icons.electric_bolt),
  _GenreItem('rnb', 'R&B', 0xFF0FA3B1, 100, Icons.audiotrack),
  _GenreItem('party', 'Party', 0xFFFF8C42, 140, Icons.celebration),
  _GenreItem('techno', 'Techno', 0xFFFF4FA3, 210, Icons.graphic_eq),
  _GenreItem('feel_good', 'Feel Good', 0xFFFFD60A, 100, Icons.sentiment_very_satisfied),
  _GenreItem('healing_era', 'Healing Era', 0xFF2D6CDF, 140, Icons.favorite),
  _GenreItem('folk', 'Folk', 0xFFFF8C42, 210, Icons.music_note),
  _GenreItem('soul', 'Soul', 0xFF0FA3B1, 140, Icons.piano),
  _GenreItem('latin', 'Latin', 0xFFD94FFF, 140, Icons.queue_music),
];

// ─── MAIN WIDGET ──────────────────────────────────────────────────────────────

class SearchGenreGrid extends ConsumerWidget {
  const SearchGenreGrid({
    super.key,
    required this.genres,
    required this.isLoading,
    this.onGenreTap,
  });

  final List<SearchGenreEntity> genres;
  final bool isLoading;
  final ValueChanged<SearchGenreEntity>? onGenreTap;

  Map<String, SearchGenreEntity> _buildLookup() {
    return {for (final g in genres) g.id: g};
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final lookup = _buildLookup();

    Widget buildColumn(List<_GenreItem> items) {
      return Column(
        children: items.map((item) {
          final entity =
              lookup[item.id] ??
              SearchGenreEntity(
                id: item.id,
                label: item.label,
                colorValue: item.color,
              );

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _GenreTile(
              genre: entity,
              height: item.height,
              icon: item.icon,
              onTap: () {
                onGenreTap?.call(entity);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GenreDetailScreen(
                      genreId: entity.id,
                      genreLabel: entity.label,
                      genreColor: Color(entity.colorValue),
                      // Pass the local asset path so the detail header can
                      // show the image if it exists.
                      genreImageAsset: entity.imageAsset,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 80),
      children: [
        const Text(
          'Vibes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildColumn(_leftColumn)),
            const SizedBox(width: 8),
            Expanded(child: buildColumn(_rightColumn)),
          ],
        ),
      ],
    );
  }
}

// ─── TILE ─────────────────────────────────────────────────────────────────────

class _GenreTile extends StatelessWidget {
  const _GenreTile({
    required this.genre,
    required this.height,
    required this.icon,
    required this.onTap,
  });

  final SearchGenreEntity genre;
  final double height;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = Color(genre.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: height,
          color: bg,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ── Background image if available ─────────────────────────────
              if (genre.imageAsset != null)
                Positioned.fill(
                  child: Image.asset(genre.imageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                )
              else if (genre.artworkUrl != null)
                Positioned.fill(
                  child: Image.network(genre.artworkUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ),

              // ── Decorative icon (bottom-right, rotated) when no image ─────
              if (genre.imageAsset == null && genre.artworkUrl == null)
                Positioned(
                  right: -10,
                  bottom: -8,
                  child: Transform.rotate(
                    angle: 0.35,
                    child: Icon(icon,
                        size: height * 0.72,
                        color: Colors.black.withValues(alpha: 0.18)),
                  ),
                ),

              // ── Gradient scrim over image ─────────────────────────────────
              if (genre.imageAsset != null || genre.artworkUrl != null)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          bg.withValues(alpha: 0.72),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Label — top-left ──────────────────────────────────────────
              Positioned(
                top: 10,
                left: 12,
                right: height * 0.4,
                child: Text(
                  genre.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black38)],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
