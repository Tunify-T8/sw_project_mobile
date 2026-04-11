import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/trending_notifier.dart';
import '../widgets/trending_genre_bar.dart';
import '../widgets/trending_track_tile.dart';
import '../../domain/entities/trending_track_entity.dart';

class TrendingGenreSection extends ConsumerStatefulWidget {
  final List<String> genres;

  const TrendingGenreSection({
    super.key,
    required this.genres,
  });

  @override
  ConsumerState<TrendingGenreSection> createState() =>
      _TrendingGenreSectionState();
}

class _TrendingGenreSectionState extends ConsumerState<TrendingGenreSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: widget.genres.length,
      vsync: this,
    );

    _tabController.addListener(_handleTabChange);

    Future.microtask(() {
      ref.read(trendingNotifierProvider.notifier).loadTrending(
            genre: widget.genres[0],
          );
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    final selectedGenre = widget.genres[_tabController.index];

    ref.read(trendingNotifierProvider.notifier).loadTrending(
          genre: selectedGenre,
        );
  }

  Widget _buildTrendingContent({
    required bool isLoading,
    required String? error,
    required List<TrendingTrackEntity> tracks,
  }) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (error != null) {
      return Center(
        child: Text(
          error,
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else if (tracks.isEmpty) {
      return const Center(
        child: Text(
          'No trending tracks found',
          style: TextStyle(color: Colors.white54),
        ),
      );
    } else {
      final pageCount = (tracks.length / 3).ceil();

      return SizedBox(
        height: 220,
        child: PageView.builder(
          itemCount: pageCount,
          itemBuilder: (context, pageIndex) {
            final start = pageIndex * 3;
            final end = (start + 3 > tracks.length)
                ? tracks.length
                : start + 3;
            final pageTracks = tracks.sublist(start, end);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: pageTracks.map((track) {
                return TrendingTrackTile(
                  track: track,
                  onTap: () {},
                );
              }).toList(),
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trendingNotifierProvider);

    final content = _buildTrendingContent(
      isLoading: state.isLoading,
      error: state.error,
      tracks: state.trending?.tracks ?? [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrendingGenreBar(
          controller: _tabController,
          genres: widget.genres,
        ),
        content,
      ],
    );
  }
}