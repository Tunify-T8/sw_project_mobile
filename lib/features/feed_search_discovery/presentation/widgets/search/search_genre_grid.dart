import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/search_genre_entity.dart';
import '../../screens/genre_detail_screen.dart';

// ─── DATA MODEL ───────────────────────────────────────────────────────────────
// Unchanged from original — same IDs, labels, colors, heights.

class _GenreItem {
  const _GenreItem(this.id, this.label, this.color, this.height);

  final String id;
  final String label;
  final int color;
  final double height;
}

const _leftColumn = [
  _GenreItem('hip_hop_rap', 'Hip Hop & Rap', 0xFFA259FF, 140),
  _GenreItem('pop', 'Pop', 0xFFFFD60A, 210),
  _GenreItem('chill', 'Chill', 0xFF0FA3B1, 70),
  _GenreItem('workout', 'Workout', 0xFF10A674, 140),
  _GenreItem('house', 'House', 0xFFFF4FA3, 210),
  _GenreItem('at_home', 'At Home', 0xFFA259FF, 70),
  _GenreItem('study', 'Study', 0xFFFF4FA3, 140),
  _GenreItem('indie', 'Indie', 0xFF2D6CDF, 210),
  _GenreItem('country', 'Country', 0xFFFF8C42, 70),
  _GenreItem('rock', 'Rock', 0xFFFF3D2E, 70),
];

const _rightColumn = [
  _GenreItem('electronic', 'Electronic', 0xFFFF4FA3, 210),
  _GenreItem('rnb', 'R&B', 0xFF0FA3B1, 70),
  _GenreItem('party', 'Party', 0xFFFF8C42, 140),
  _GenreItem('techno', 'Techno', 0xFFFF4FA3, 210),
  _GenreItem('feel_good', 'Feel Good', 0xFFFFD60A, 70),
  _GenreItem('healing_era', 'Healing Era', 0xFF2D6CDF, 140),
  _GenreItem('folk', 'Folk', 0xFFFF8C42, 210),
  _GenreItem('soul', 'Soul', 0xFF0FA3B1, 140),
  _GenreItem('latin', 'Latin', 0xFFD94FFF, 140),
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
    required this.onTap,
  });

  final SearchGenreEntity genre;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: height,
          color: Color(genre.colorValue),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background image ─────────────────────────────────────────
              // Priority: local asset (imageAsset) → remote URL (artworkUrl).
              // Falls back to the solid colorValue if both are null or fail.
              if (genre.imageAsset != null)
                Image.asset(
                  genre.imageAsset!,
                  fit: BoxFit.cover,
                  // Silent fallback to solid color — no error widget shown.
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                )
              else if (genre.artworkUrl != null)
                Image.network(
                  genre.artworkUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),

              // ── Dark gradient so label is always readable ─────────────────
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x99000000)],
                    stops: [0.35, 1.0],
                  ),
                ),
              ),

              // ── Label ─────────────────────────────────────────────────────
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    genre.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
