import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/album_result_entity.dart';
import '../../../domain/entities/playlist_result_entity.dart';
import '../../../domain/entities/profile_result_entity.dart';
import '../../../domain/entities/track_result_entity.dart';
import '../../../domain/entities/top_result_entity.dart';
import '../../../domain/entities/search_genre_entity.dart';
import '../../providers/search_provider.dart';
import '../../utils/search_track_playback.dart';
import 'search_artwork_placeholder.dart';
import 'search_section_header.dart';
import 'search_result_tile_track.dart';
import 'search_result_tile_profile.dart';
import 'search_result_tile_playlist.dart';
import 'search_result_tile_album.dart';
import '../../screens/search_see_all_screen.dart';

class SearchResultsTabs extends ConsumerStatefulWidget {
  const SearchResultsTabs({
    super.key,
    required this.state,
    required this.onTabChanged,
    required this.onLoadMore,
    required this.onToggleLike,
  });

  final SearchState state;
  final ValueChanged<SearchTab> onTabChanged;
  final VoidCallback onLoadMore;
  final ValueChanged<String> onToggleLike;

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
                    _AllTab(
                      state: widget.state,
                      onLoadMore: widget.onLoadMore,
                      onResultTapped: (item) => ref
                          .read(searchProvider.notifier)
                          .recordResultTapped(item),
                      onTrackTap: (track) => playSearchTrack(
                        context,
                        ref,
                        track,
                        queueTracks:
                            widget.state.allResult?.tracks ?? const [],
                      ),
                    ),
                    _TrackTab(
                      tracks: widget.state.tracks,
                      isLoadingMore: widget.state.isLoadingMore,
                      hasMore: widget.state.hasMore,
                      onLoadMore: widget.onLoadMore,
                      onTrackTap: (track) => playSearchTrack(
                        context,
                        ref,
                        track,
                        queueTracks: widget.state.tracks,
                      ),
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
  const _AllTab({
    required this.state,
    required this.onLoadMore,
    required this.onResultTapped,
    required this.onTrackTap,
  });

  final SearchState state;
  final VoidCallback onLoadMore;
  final ValueChanged<RecentResultItem> onResultTapped;
  final ValueChanged<TrackResultEntity> onTrackTap;

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

    // Tracks that appear in the Tracks section:
    // exclude the top result track and the second inline track shown in the card
    final visibleTracks = result.tracks
        .where((t) => t.id != result.topResult?.id)
        .skip(1)
        .take(4)
        .toList();

    // Build "More Results" — anything beyond the first few shown in each section
    final moreItems = <_MixedResultItem>[];
    for (final t in result.tracks.skip(4)) {
      moreItems.add(_MixedResultItem.track(t));
    }
    for (final a in result.albums.skip(3)) {
      moreItems.add(_MixedResultItem.album(a));
    }
    for (final p in result.profiles.skip(3)) {
      moreItems.add(_MixedResultItem.profile(p));
    }
    for (final pl in result.playlists.skip(3)) {
      moreItems.add(_MixedResultItem.playlist(pl));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Top result card
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
          _TopResultCard(
            state: state,
            topResult: result.topResult!,
            onTrackTap: onTrackTap,
            onTap: () {
              final top = result.topResult!;
              onResultTapped(
                RecentResultItem(
                  kind: _kindFromTopResultType(top.type),
                  id: top.id,
                  title: top.title,
                  subtitle: top.subtitle,
                  artworkUrl: top.artworkUrl,
                  isVerified: top.type == TopResultType.profile,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // Recently Played — large square cards, 2 per row, tracks/albums/playlists only
        Builder(
          builder: (context) {
            final playedItems = state.recentResults
                .where((r) => r.kind != RecentResultKind.profile)
                .take(2)
                .toList();
            if (playedItems.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SearchSectionHeader(title: 'Recently Played'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(playedItems.length, (i) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: i == 0 && playedItems.length > 1 ? 8 : 0,
                          ),
                          child: _RecentlyPlayedCard(item: playedItems[i]),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),

        // Tracks section — only shown when there are tracks beyond top+second
        if (visibleTracks.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'Tracks',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    SearchSeeAllScreen(title: 'Tracks', tracks: result.tracks),
              ),
            ),
          ),
          ...visibleTracks.map(
            (t) => SearchResultTileTrack(
              track: t,
              onTap: () => onTrackTap(t),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Playlists section
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

        // Profiles section
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

        // Albums section
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
          const SizedBox(height: 16),
        ],

        // More Results — mixed remaining items
        if (moreItems.isNotEmpty) ...[
          const SearchSectionHeader(title: 'More Results'),
          ...moreItems.map(
            (item) => _MixedResultTile(item: item, onTrackTap: onTrackTap),
          ),
          const SizedBox(height: 32),
        ],
      ],
    );
  }

  RecentResultKind _kindFromTopResultType(TopResultType type) {
    switch (type) {
      case TopResultType.profile:
        return RecentResultKind.profile;
      case TopResultType.track:
        return RecentResultKind.track;
      case TopResultType.album:
        return RecentResultKind.album;
      case TopResultType.playlist:
        return RecentResultKind.playlist;
    }
  }
}

// ─── Mixed result item for More Results ──────────────────────────────────────

class _MixedResultItem {
  const _MixedResultItem._({
    required this.kind,
    required this.title,
    required this.subtitle,
    this.artworkUrl,
    this.isUnavailable = false,
    this.track,
  });

  factory _MixedResultItem.track(TrackResultEntity t) => _MixedResultItem._(
    kind: RecentResultKind.track,
    title: t.title,
    subtitle: t.artistName,
    artworkUrl: t.artworkUrl,
    isUnavailable: t.isUnavailable,
    track: t,
  );

  factory _MixedResultItem.album(AlbumResultEntity a) => _MixedResultItem._(
    kind: RecentResultKind.album,
    title: a.title,
    subtitle: a.artistName,
    artworkUrl: a.artworkUrl,
  );

  factory _MixedResultItem.profile(ProfileResultEntity p) => _MixedResultItem._(
    kind: RecentResultKind.profile,
    title: p.username,
    subtitle: '${p.followersCount} Followers',
    artworkUrl: p.avatarUrl,
  );

  factory _MixedResultItem.playlist(PlaylistResultEntity pl) =>
      _MixedResultItem._(
        kind: RecentResultKind.playlist,
        title: pl.title,
        subtitle: pl.creatorName,
        artworkUrl: pl.artworkUrl,
      );

  final RecentResultKind kind;
  final String title;
  final String subtitle;
  final String? artworkUrl;
  final bool isUnavailable;
  final TrackResultEntity? track;
}

class _MixedResultTile extends StatelessWidget {
  const _MixedResultTile({required this.item, required this.onTrackTap});
  final _MixedResultItem item;
  final ValueChanged<TrackResultEntity> onTrackTap;

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
          errorBuilder: (c, e, s) => SearchArtworkPlaceholder(size: 48),
        ),
      );
    } else {
      leading = isProfile
          ? const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF2A2A2A),
              child: Icon(Icons.person, color: Colors.white38),
            )
          : SearchArtworkPlaceholder(size: 48);
    }

    final track = item.track;
    return ListTile(
      onTap: (track != null && !track.isUnavailable)
          ? () => onTrackTap(track)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: SizedBox(width: 48, height: 48, child: leading),
      title: Text(
        item.title,
        style: TextStyle(
          color: item.isUnavailable ? Colors.white38 : Colors.white,
          fontSize: 15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          if (item.isUnavailable)
            const Text(
              'Not available in your country',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
        ],
      ),
      trailing: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
    );
  }
}

// ─── Recently Played card ─────────────────────────────────────────────────────

class _RecentlyPlayedCard extends StatelessWidget {
  const _RecentlyPlayedCard({required this.item});
  final RecentResultItem item;

  static const double _cardSize = 140.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _cardSize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.artworkUrl != null
                ? Image.network(
                    item.artworkUrl!,
                    width: _cardSize,
                    height: _cardSize,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                        SearchArtworkPlaceholder(size: _cardSize),
                  )
                : SearchArtworkPlaceholder(size: _cardSize),
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            item.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
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
    required this.onTrackTap,
  });

  final List<TrackResultEntity> tracks;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final ValueChanged<TrackResultEntity> onTrackTap;

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
        itemBuilder: (context, i) {
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
          final track = tracks[i];
          return SearchResultTileTrack(
            track: track,
            onTap: () => onTrackTap(track),
          );
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
      itemBuilder: (context, i) =>
          SearchResultTileProfile(profile: profiles[i]),
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
      itemBuilder: (context, i) =>
          SearchResultTilePlaylist(playlist: playlists[i]),
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
      itemBuilder: (context, i) => SearchResultTileAlbum(album: albums[i]),
    );
  }
}

// ── Top result card ────────────────────────────────────────────────────────────

class _TopResultCard extends StatelessWidget {
  const _TopResultCard({
    required this.state,
    required this.topResult,
    required this.onTap,
    required this.onTrackTap,
  });

  final SearchState state;
  final TopResultEntity topResult;
  final VoidCallback onTap;
  final ValueChanged<TrackResultEntity> onTrackTap;

  @override
  Widget build(BuildContext context) {
    // Find the top result as a track entity (if it is one)
    final topTrack = state.allResult?.tracks
        .where((t) => t.id == topResult.id)
        .firstOrNull;

    // Second item — first track/album that is NOT the top result
    final secondTrack = state.allResult?.tracks
        .where((t) => t.id != topResult.id)
        .firstOrNull;
    final secondAlbum = state.allResult?.albums
        .where((a) => a.id != topResult.id)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top result — standard track tile when it's a track
        if (topTrack != null)
          SearchResultTileTrack(
            track: topTrack,
            onTap: () => onTrackTap(topTrack),
          )
        else
          // Fallback large card for profile / album / playlist top results
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      topResult.type == TopResultType.profile ? 36 : 8,
                    ),
                    child: topResult.artworkUrl != null
                        ? Image.network(
                            topResult.artworkUrl!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                SearchArtworkPlaceholder(size: 72),
                          )
                        : SearchArtworkPlaceholder(
                            size: 72,
                            isCircle: topResult.type == TopResultType.profile,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topResult.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          topResult.subtitle,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (topResult.type == TopResultType.profile)
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        minimumSize: const Size(72, 34),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Follow'),
                    ),
                ],
              ),
            ),
          ),

        // Second item inline — different from top result
        if (secondTrack != null)
          SearchResultTileTrack(
            track: secondTrack,
            onTap: () => onTrackTap(secondTrack),
          )
        else if (secondAlbum != null)
          SearchResultTileAlbum(album: secondAlbum),
      ],
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
              'Double-check your spelling or try other search keywords.',
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
