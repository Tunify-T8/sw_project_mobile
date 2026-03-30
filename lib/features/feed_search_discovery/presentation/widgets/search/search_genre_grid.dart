// lib/features/feed_search_discovery/presentation/widgets/search/search_genre_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/search_genre_entity.dart';

class SearchGenreGrid extends ConsumerWidget {
  const SearchGenreGrid({
    super.key,
    required this.genres,
    required this.isLoading,
    required this.onGenreTap,
  });

  final List<SearchGenreEntity> genres;
  final bool isLoading;
  final ValueChanged<SearchGenreEntity> onGenreTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Browse by genre',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _GenreTile(
                genre: genres[index],
                onTap: () => onGenreTap(genres[index]),
              ),
              childCount: genres.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _GenreTile extends StatelessWidget {
  const _GenreTile({required this.genre, required this.onTap});
  final SearchGenreEntity genre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Color(genre.colorValue)),
            if (genre.artworkUrl != null)
              Positioned(
                right: -10,
                bottom: -10,
                child: Transform.rotate(
                  angle: 0.3,
                  child: Image.network(
                    genre.artworkUrl!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
            Positioned(
              left: 12,
              bottom: 10,
              child: Text(
                genre.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
