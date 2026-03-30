// lib/features/feed_search_discovery/presentation/widgets/search/search_results_tabs.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/album_result_entity.dart';
import '../../../domain/entities/search_genre_entity.dart';
import '../../../domain/entities/playlist_result_entity.dart';
import '../../../domain/entities/profile_result_entity.dart';
import '../../../domain/entities/track_result_entity.dart';
import '../../../domain/entities/top_result_entity.dart';
import '../../../domain/entities/search_filters_entity.dart';
import '../../providers/search_provider.dart';
import 'search_artwork_placeholder.dart';
import 'search_section_header.dart';
import 'search_result_tile_track.dart';
import 'search_result_tile_profile.dart';
import 'search_result_tile_playlist.dart';
import 'search_result_tile_album.dart';
import 'search_filter_sheet.dart';
import '../../screens/search_see_all_screen.dart';

class SearchResultsTabs extends ConsumerStatefulWidget {
  const SearchResultsTabs({
    super.key,
    required this.state,
    required this.onTabChanged,
    required this.onLoadMore,
    required this.onToggleLike,
    required this.onApplyTrackFilters,
    required this.onApplyCollectionFilters,
    required this.onApplyPeopleFilters,
    required this.onClearFilters,
  });

  final SearchState state;
  final ValueChanged<SearchTab> onTabChanged;
  final VoidCallback onLoadMore;
  final ValueChanged<String> onToggleLike;
  final ValueChanged<TrackSearchFilters> onApplyTrackFilters;
  final ValueChanged<CollectionSearchFilters> onApplyCollectionFilters;
  final ValueChanged<PeopleSearchFilters> onApplyPeopleFilters;
  final VoidCallback onClearFilters;

  @override
  ConsumerState<SearchResultsTabs> createState() => _SearchResultsTabsState();
}

class _SearchResultsTabsState extends ConsumerState<SearchResultsTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    SearchTab.all,
    SearchTab.tracks,
    SearchTab.profiles,
    SearchTab.playlists,
    SearchTab.albums,
  ];

  static const _tabLabels = [
    'All',
    'Tracks',
    'Profiles',
    'Playlists',
    'Albums',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onTabChanged(_tabs[_tabController.index]);
      }
    });
  }

  @override
  void didUpdateWidget(SearchResultsTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = _tabs.indexOf(widget.state.activeTab);
    if (newIndex != -1 && newIndex != _tabController.index) {
      _tabController.animateTo(newIndex);
    }
  }

  void _openFilterSheet(BuildContext context) async {
    switch (widget.state.activeTab) {
      case SearchTab.tracks:
        final result = await TrackFilterSheet.show(
          context,
          widget.state.trackFilters,
        );
        if (result != null) widget.onApplyTrackFilters(result);
        break;
      case SearchTab.profiles:
        final result = await PeopleFilterSheet.show(
          context,
          widget.state.peopleFilters,
        );
        if (result != null) widget.onApplyPeopleFilters(result);
        break;
      case SearchTab.playlists:
      case SearchTab.albums:
        final result = await CollectionFilterSheet.show(
          context,
          widget.state.collectionFilters,
        );
        if (result != null) widget.onApplyCollectionFilters(result);
        break;
      case SearchTab.all:
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabAlignment: TabAlignment.start,
          tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
        ),

        // Filter row — only shown on filterable tabs
        if (widget.state.activeTab != SearchTab.all)
          _FilterRow(
            state: widget.state,
            onOpenFilter: () => _openFilterSheet(context),
            onClearFilters: widget.onClearFilters,
          ),

        Expanded(
          child: widget.state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : widget.state.error != null
              ? _SearchErrorState(error: widget.state.error!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _AllTab(state: widget.state, onLoadMore: widget.onLoadMore),
                    _TrackTab(
                      tracks: widget.state.tracks,
                      isLoadingMore: widget.state.isLoadingMore,
                      hasMore: widget.state.hasMore,
                      onLoadMore: widget.onLoadMore,
                    ),
                    _ProfileTab(profiles: widget.state.profiles),
                    _PlaylistTab(playlists: widget.state.playlists),
                    _AlbumTab(albums: widget.state.albums),
                  ],
                ),
        ),
      ],
    );
  }
}

// ── All tab ───────────────────────────────────────────────────────────────────

class _AllTab extends StatelessWidget {
  const _AllTab({required this.state, required this.onLoadMore});
  final SearchState state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final result = state.allResult;
    if (result == null ||
        (result.topResult == null &&
            result.tracks.isEmpty &&
            result.playlists.isEmpty &&
            result.profiles.isEmpty &&
            result.albums.isEmpty)) {
      return _SearchEmptyState(query: state.query);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (result.topResult != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Top Result',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          _TopResultCard(topResult: result.topResult!),
          const SizedBox(height: 16),
        ],
        if (result.tracks.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'Tracks',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    SearchSeeAllScreen(title: 'Tracks', tracks: result.tracks),
              ),
            ),
          ),
          ...result.tracks.take(4).map((t) => SearchResultTileTrack(track: t)),
          const SizedBox(height: 16),
        ],
        if (result.playlists.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'Playlists',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchSeeAllScreen(
                  title: 'Playlists',
                  playlists: result.playlists,
                ),
              ),
            ),
          ),
          ...result.playlists
              .take(3)
              .map((p) => SearchResultTilePlaylist(playlist: p)),
          const SizedBox(height: 16),
        ],
        if (result.profiles.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'Profiles',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchSeeAllScreen(
                  title: 'Profiles',
                  profiles: result.profiles,
                ),
              ),
            ),
          ),
          ...result.profiles
              .take(3)
              .map((p) => SearchResultTileProfile(profile: p)),
          const SizedBox(height: 16),
        ],
        if (result.albums.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'Albums',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    SearchSeeAllScreen(title: 'Albums', albums: result.albums),
              ),
            ),
          ),
          ...result.albums.take(3).map((a) => SearchResultTileAlbum(album: a)),
          const SizedBox(height: 32),
        ],
      ],
    );
  }
}

// ── Per-tab lists ─────────────────────────────────────────────────────────────

class _TrackTab extends StatelessWidget {
  const _TrackTab({
    required this.tracks,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
  });
  final List<TrackResultEntity> tracks;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return const _SearchEmptyTabState();
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollEndNotification && n.metrics.extentAfter < 200) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tracks.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == tracks.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return SearchResultTileTrack(track: tracks[i]);
        },
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.profiles});
  final List<ProfileResultEntity> profiles;
  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) return const _SearchEmptyTabState();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: profiles.length,
      itemBuilder: (_, i) => SearchResultTileProfile(profile: profiles[i]),
    );
  }
}

class _PlaylistTab extends StatelessWidget {
  const _PlaylistTab({required this.playlists});
  final List<PlaylistResultEntity> playlists;
  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) return const _SearchEmptyTabState();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: playlists.length,
      itemBuilder: (_, i) => SearchResultTilePlaylist(playlist: playlists[i]),
    );
  }
}

class _AlbumTab extends StatelessWidget {
  const _AlbumTab({required this.albums});
  final List<AlbumResultEntity> albums;
  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) return const _SearchEmptyTabState();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: albums.length,
      itemBuilder: (_, i) => SearchResultTileAlbum(album: albums[i]),
    );
  }
}

// ── Top result card ────────────────────────────────────────────────────────────

class _TopResultCard extends StatelessWidget {
  const _TopResultCard({required this.topResult});
  final TopResultEntity topResult;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                topResult.type == TopResultType.profile ? 40 : 8,
              ),
              child: topResult.artworkUrl != null
                  ? Image.network(
                      topResult.artworkUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : SearchArtworkPlaceholder(
                      size: 80,
                      isCircle: topResult.type == TopResultType.profile,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topResult.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topResult.subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty / error states ──────────────────────────────────────────────────────

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, color: Colors.white24, size: 56),
            const SizedBox(height: 16),
            Text(
              'No matches for "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Double-check your spelling or try other search keywords.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchEmptyTabState extends StatelessWidget {
  const _SearchEmptyTabState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No results found.',
        style: TextStyle(color: Colors.white54, fontSize: 15),
      ),
    );
  }
}

class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({required this.error});
  final String error;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 15),
        ),
      ),
    );
  }
}

// ─── Filter row ───────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.state,
    required this.onOpenFilter,
    required this.onClearFilters,
  });

  final SearchState state;
  final VoidCallback onOpenFilter;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final hasFilters = state.activeTabHasFilters;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Filter icon button
          GestureDetector(
            onTap: onOpenFilter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: hasFilters ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: hasFilters ? Colors.white : Colors.white30,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune,
                    size: 16,
                    color: hasFilters ? Colors.black : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: hasFilters ? Colors.black : Colors.white,
                      fontSize: 13,
                      fontWeight: hasFilters
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Clear filters pill — shown only when filters are active
          if (hasFilters) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, size: 14, color: Colors.white54),
                    SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
