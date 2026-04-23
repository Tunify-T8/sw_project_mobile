// Search Feature Guide:
// Purpose: Tab-based results view shown when user submits a search query.
//          Hosts All / Tracks / Profiles / Playlists / Albums tabs.
// Used by: search_screen.dart
// Concerns: Module 8 search results display; profile navigation; recently played.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/followers_and_social_graph/presentation/widgets/relationship_button.dart';
import '../../../../../features/profile/presentation/screens/other_user_profile_screen.dart';
import '../../../domain/entities/album_result_entity.dart';
import '../../../domain/entities/playlist_result_entity.dart';
import '../../../domain/entities/profile_result_entity.dart';
import '../../../domain/entities/top_result_entity.dart';
import '../../../domain/entities/track_result_entity.dart';
import '../../providers/search_provider.dart';
import '../../screens/search_see_all_screen.dart';
import '../../utils/search_track_playback.dart';
import 'search_artwork_placeholder.dart';
import 'search_result_tile_album.dart';
import 'search_result_tile_playlist.dart';
import 'search_result_tile_profile.dart';
import 'search_result_tile_track.dart';
import 'search_section_header.dart';

// ── Public entry point ────────────────────────────────────────────────────────

/// Tab controller that hosts All / Tracks / Profiles / Playlists / Albums.
///
/// Passed [state] from [searchProvider] — rebuilds whenever the provider
/// emits a new state. Tab bar index stays in sync with [state.activeTab].
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
  static const _labels = ['All', 'Tracks', 'Profiles', 'Playlists', 'Albums'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      widget.onTabChanged(_tabs[_tabController.index]);
    });
  }

  @override
  void didUpdateWidget(covariant SearchResultsTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    final idx = _tabs.indexOf(widget.state.activeTab);
    if (idx != -1 && idx != _tabController.index) {
      _tabController.animateTo(idx);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Navigates to the public profile screen for [profile].
  void _openProfile(ProfileResultEntity profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtherUserProfileScreen(userId: profile.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tab bar ────────────────────────────────────────────────────────
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),

        // ── Tab body ───────────────────────────────────────────────────────
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
                        queueTracks: widget.state.allResult?.tracks ?? const [],
                      ),
                      onProfileTap: _openProfile,
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
                    _ProfileTab(
                      profiles: widget.state.profiles,
                      onProfileTap: _openProfile,
                    ),
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
    required this.onProfileTap,
  });

  final SearchState state;
  final VoidCallback onLoadMore;
  final ValueChanged<RecentResultItem> onResultTapped;
  final ValueChanged<TrackResultEntity> onTrackTap;
  final ValueChanged<ProfileResultEntity> onProfileTap;

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

    // Tracks shown in the Tracks section (exclude top result + second inline).
    final visibleTracks = result.tracks
        .where((t) => t.id != result.topResult?.id)
        .skip(1)
        .take(4)
        .toList();

    // Overflow items shown in "More Results".
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
        // ── Top Result ─────────────────────────────────────────────────────
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
            onProfileTap: onProfileTap,
            onTap: () => onResultTapped(
              RecentResultItem(
                kind: _kindFrom(result.topResult!.type),
                id: result.topResult!.id,
                title: result.topResult!.title,
                subtitle: result.topResult!.subtitle,
                artworkUrl: result.topResult!.artworkUrl,
                isVerified: result.topResult!.type == TopResultType.profile,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Recently Played ────────────────────────────────────────────────
        // Only populated via recordTrackPlayed() — never auto-added on search.
        Builder(
          builder: (context) {
            final played = state.recentResults
                .where((r) => r.kind != RecentResultKind.profile)
                .toList();
            if (played.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SearchSectionHeader(title: 'Recently Played'),
                // Horizontal scroll — shows all played items, no arbitrary limit.
                SizedBox(
                  height: 196,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: played.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => _RecentlyPlayedCard(
                      item: played[i],
                      onTap: played[i].track != null
                          ? () => onTrackTap(played[i].track!)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),

        // ── Tracks ─────────────────────────────────────────────────────────
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
            (t) => SearchResultTileTrack(track: t, onTap: () => onTrackTap(t)),
          ),
          const SizedBox(height: 16),
        ],

        // ── Playlists ───────────────────────────────────────────────────────
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

        // ── Profiles ────────────────────────────────────────────────────────
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
              .map(
                (p) => SearchResultTileProfile(
                  profile: p,
                  onTap: () => onProfileTap(p),
                ),
              ),
          const SizedBox(height: 16),
        ],

        // ── Albums ──────────────────────────────────────────────────────────
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

        // ── More Results ────────────────────────────────────────────────────
        if (moreItems.isNotEmpty) ...[
          const SearchSectionHeader(title: 'More Results'),
          ...moreItems.map(
            (item) => _MixedResultTile(
              item: item,
              onTrackTap: onTrackTap,
              onProfileTap: onProfileTap,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ],
    );
  }

  static RecentResultKind _kindFrom(TopResultType type) {
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

// ── Track tab ─────────────────────────────────────────────────────────────────

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
        if (n is ScrollEndNotification &&
            n.metrics.extentAfter < 300 &&
            hasMore &&
            !isLoadingMore) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tracks.length + (isLoadingMore && hasMore ? 1 : 0),
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
          return SearchResultTileTrack(
            track: tracks[i],
            onTap: () => onTrackTap(tracks[i]),
          );
        },
      ),
    );
  }
}

// ── Profile tab ───────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.profiles, required this.onProfileTap});

  final List<ProfileResultEntity> profiles;
  final ValueChanged<ProfileResultEntity> onProfileTap;

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) return const _SearchEmptyTabState();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: profiles.length,
      itemBuilder: (context, i) => SearchResultTileProfile(
        profile: profiles[i],
        onTap: () => onProfileTap(profiles[i]),
      ),
    );
  }
}

// ── Playlist tab ──────────────────────────────────────────────────────────────

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

// ── Album tab ─────────────────────────────────────────────────────────────────

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

// ── Top result card ───────────────────────────────────────────────────────────

/// Shows the single best result for the query with artwork, title, subtitle,
/// and — for profiles — a working [RelationshipButton].
class _TopResultCard extends StatelessWidget {
  const _TopResultCard({
    required this.state,
    required this.topResult,
    required this.onTap,
    required this.onTrackTap,
    required this.onProfileTap,
  });

  final SearchState state;
  final TopResultEntity topResult;
  final VoidCallback onTap;
  final ValueChanged<TrackResultEntity> onTrackTap;
  final ValueChanged<ProfileResultEntity> onProfileTap;

  @override
  Widget build(BuildContext context) {
    final topTrack = state.allResult?.tracks
        .where((t) => t.id == topResult.id)
        .firstOrNull;
    final secondTrack = state.allResult?.tracks
        .where((t) => t.id != topResult.id)
        .firstOrNull;
    final secondAlbum = state.allResult?.albums
        .where((a) => a.id != topResult.id)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top result row
        if (topTrack != null)
          SearchResultTileTrack(
            track: topTrack,
            onTap: () => onTrackTap(topTrack),
          )
        else
          GestureDetector(
            onTap: () {
              onTap();
              if (topResult.type == TopResultType.profile) {
                final p = state.allResult?.profiles
                    .where((p) => p.id == topResult.id)
                    .firstOrNull;
                if (p != null) onProfileTap(p);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Artwork
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
                            errorBuilder: (_, __, ___) =>
                                SearchArtworkPlaceholder(size: 72),
                          )
                        : SearchArtworkPlaceholder(
                            size: 72,
                            isCircle: topResult.type == TopResultType.profile,
                          ),
                  ),
                  const SizedBox(width: 14),
                  // Title / subtitle
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
                  // Profile: RelationshipButton instead of dead OutlinedButton
                  if (topResult.type == TopResultType.profile) ...[
                    const SizedBox(width: 8),
                    RelationshipButton(
                      userId: topResult.id,
                      initialIsFollowing: state.allResult?.profiles
                          .where((p) => p.id == topResult.id)
                          .firstOrNull
                          ?.isFollowing,
                    ),
                  ],
                ],
              ),
            ),
          ),

        // Second inline result
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

// ── Mixed result tile (More Results) ─────────────────────────────────────────

class _MixedResultItem {
  const _MixedResultItem._({
    this.track,
    this.album,
    this.profile,
    this.playlist,
  });
  factory _MixedResultItem.track(TrackResultEntity t) =>
      _MixedResultItem._(track: t);
  factory _MixedResultItem.album(AlbumResultEntity a) =>
      _MixedResultItem._(album: a);
  factory _MixedResultItem.profile(ProfileResultEntity p) =>
      _MixedResultItem._(profile: p);
  factory _MixedResultItem.playlist(PlaylistResultEntity pl) =>
      _MixedResultItem._(playlist: pl);

  final TrackResultEntity? track;
  final AlbumResultEntity? album;
  final ProfileResultEntity? profile;
  final PlaylistResultEntity? playlist;
}

class _MixedResultTile extends StatelessWidget {
  const _MixedResultTile({
    required this.item,
    required this.onTrackTap,
    required this.onProfileTap,
  });

  final _MixedResultItem item;
  final ValueChanged<TrackResultEntity> onTrackTap;
  final ValueChanged<ProfileResultEntity> onProfileTap;

  @override
  Widget build(BuildContext context) {
    if (item.track != null) {
      return SearchResultTileTrack(
        track: item.track!,
        onTap: () => onTrackTap(item.track!),
      );
    }
    if (item.album != null) return SearchResultTileAlbum(album: item.album!);
    if (item.profile != null) {
      return SearchResultTileProfile(
        profile: item.profile!,
        onTap: () => onProfileTap(item.profile!),
      );
    }
    if (item.playlist != null) {
      return SearchResultTilePlaylist(playlist: item.playlist!);
    }
    return const SizedBox.shrink();
  }
}

// ── Recently Played card ──────────────────────────────────────────────────────

class _RecentlyPlayedCard extends StatelessWidget {
  const _RecentlyPlayedCard({required this.item, this.onTap});

  final RecentResultItem item;
  final VoidCallback? onTap;

  static const double _cardSize = 140.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
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
                      errorBuilder: (_, __, ___) =>
                          SearchArtworkPlaceholder(size: _cardSize),
                    )
                  : SearchArtworkPlaceholder(size: _cardSize),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            Text(
              item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
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
  Widget build(BuildContext context) => const Center(
    child: Text('Nothing found.', style: TextStyle(color: Colors.white54)),
  );
}

class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white24, size: 56),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
