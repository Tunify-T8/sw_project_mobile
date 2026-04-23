import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/profile/presentation/screens/other_user_profile_screen.dart';
import '../../../../features/followers_and_social_graph/presentation/widgets/relationship_button.dart';
import '../../domain/entities/album_result_entity.dart';
import '../../domain/entities/genre_detail_entity.dart';
import '../../domain/entities/playlist_result_entity.dart';
import '../../domain/entities/profile_result_entity.dart';
import '../../domain/entities/track_result_entity.dart';
import '../providers/search_provider.dart';
import '../utils/search_track_playback.dart';
import '../widgets/search/search_artwork_placeholder.dart';
import '../widgets/search/search_result_tile_album.dart';
import '../widgets/search/search_result_tile_playlist.dart';
import '../widgets/search/search_result_tile_track.dart';
import '../widgets/search/search_section_header.dart';
import 'search_see_all_screen.dart';

class GenreDetailScreen extends ConsumerWidget {
  const GenreDetailScreen({
    super.key,
    required this.genreId,
    required this.genreLabel,
    required this.genreColor,
    // Optional local asset path — e.g. 'assets/genres/hip_hop_rap.jpg'
    // When null or the file is missing, genreColor is used as fallback.
    this.genreImageAsset,
  });

  final String genreId;
  final String genreLabel;
  final Color genreColor;
  final String? genreImageAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(genreDetailProvider(genreId));

    final darkerColor = Color.fromARGB(
      255,
      (genreColor.r * 0.65).round(),
      (genreColor.g * 0.65).round(),
      (genreColor.b * 0.65).round(),
    );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: darkerColor,
              expandedHeight: 160,
              pinned: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              titleSpacing: 0,
              title: null,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(
                  left: 56,
                  bottom: 56,
                  right: 16,
                ),
                title: Text(
                  genreLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Background: local asset → remote URL → solid color.
                background: _GenreHeader(
                  genreColor: genreColor,
                  imageAsset: genreImageAsset,
                  artworkUrl: state.detail?.artworkUrl,
                ),
              ),
              bottom: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                onTap: (i) {
                  final tabs = [
                    SearchTab.all,
                    SearchTab.tracks,
                    SearchTab.playlists,
                    SearchTab.albums,
                  ];
                  ref
                      .read(genreDetailProvider(genreId).notifier)
                      .setActiveTab(tabs[i]);
                },
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Tracks'),
                  Tab(text: 'Playlists'),
                  Tab(text: 'Albums'),
                ],
              ),
            ),
          ],
          body: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : state.error != null
              ? _GenreErrorState(
                  error: state.error!,
                  onRetry: () =>
                      ref.read(genreDetailProvider(genreId).notifier).retry(),
                )
              : TabBarView(
                  children: [
                    _GenreAllTab(
                      detail: state.detail,
                      genreId: genreId,
                      genreLabel: genreLabel,
                    ),
                    _GenreTrackList(tracks: state.detail?.trendingTracks ?? []),
                    _GenrePlaylistList(
                      playlists: state.detail?.playlists ?? [],
                    ),
                    _GenreAlbumList(albums: state.detail?.albums ?? []),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── All tab ──────────────────────────────────────────────────────────────────

class _GenreAllTab extends StatelessWidget {
  const _GenreAllTab({
    required this.detail,
    required this.genreId,
    required this.genreLabel,
  });

  final GenreDetailEntity? detail;
  final String genreId;
  final String genreLabel;

  @override
  Widget build(BuildContext context) {
    if (detail == null) return const SizedBox.shrink();

    // Zero-duration tracks are still shown — SearchResultTileTrack hides
    // the timer text when durationSeconds == 0.
    final trendingTracks = detail!.trendingTracks;
    final introducingTracks = detail!.introducingTracks;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Trending — 3 tracks per column, horizontal scroll (original layout)
        if (trendingTracks.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'Trending',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchSeeAllScreen(
                  title: 'Trending in $genreLabel',
                  tracks: trendingTracks,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 261,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: (trendingTracks.length / 3).ceil(),
              itemBuilder: (context, colIndex) {
                final start = colIndex * 3;
                final end = (start + 3).clamp(0, trendingTracks.length);
                final columnTracks = trendingTracks.sublist(start, end);
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.88,
                  child: Consumer(
                    builder: (context, ref, _) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: columnTracks
                          .map(
                            (track) => SearchResultTileTrack(
                              track: track,
                              onTap: () => playSearchTrack(
                                context,
                                ref,
                                track,
                                queueTracks: trendingTracks,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        // Introducing — horizontal art cards
        if (introducingTracks.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SearchSectionHeader(title: 'Introducing'),
          SizedBox(
            height: 192,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: introducingTracks.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _IntroducingCard(
                track: introducingTracks[i],
                allTracks: introducingTracks,
              ),
            ),
          ),
        ],

        // Playlists — horizontal cards
        if (detail!.playlists.isNotEmpty) ...[
          const SizedBox(height: 16),
          SearchSectionHeader(
            title: 'Playlists',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchSeeAllScreen(
                  title: 'Playlists in $genreLabel',
                  playlists: detail!.playlists,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 178,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: detail!.playlists.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, i) =>
                  _PlaylistCard(playlist: detail!.playlists[i]),
            ),
          ),
        ],

        // Profiles — horizontal avatar cards
        if (detail!.profiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          SearchSectionHeader(
            title: 'Profiles',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchSeeAllScreen(
                  title: 'Profiles in $genreLabel',
                  profiles: detail!.profiles,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: detail!.profiles.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, i) =>
                  _ProfileCard(profile: detail!.profiles[i]),
            ),
          ),
        ],

        // Discover More — same shape as Introducing
        if (introducingTracks.isNotEmpty) ...[
          const SizedBox(height: 16),
          SearchSectionHeader(
            title: 'Discover More',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchSeeAllScreen(
                  title: 'Discover More in $genreLabel',
                  tracks: introducingTracks,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 192,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: introducingTracks.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _IntroducingCard(
                track: introducingTracks[i],
                allTracks: introducingTracks,
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── Tab list views ───────────────────────────────────────────────────────────

class _GenreTrackList extends ConsumerWidget {
  const _GenreTrackList({required this.tracks});
  final List<TrackResultEntity> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Zero-duration tracks still appear — SearchResultTileTrack hides
    // the timer text, not the whole tile.
    final visible = tracks;
    if (visible.isEmpty) {
      return const _GenreEmptyState(message: 'No trending tracks yet.');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: visible.length,
      itemBuilder: (context, i) {
        final track = visible[i];
        return SearchResultTileTrack(
          track: track,
          onTap: () =>
              playSearchTrack(context, ref, track, queueTracks: visible),
        );
      },
    );
  }
}

class _GenrePlaylistList extends StatelessWidget {
  const _GenrePlaylistList({required this.playlists});
  final List<PlaylistResultEntity> playlists;

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return const _GenreEmptyState(message: 'No playlists yet.');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: playlists.length,
      itemBuilder: (context, i) =>
          SearchResultTilePlaylist(playlist: playlists[i]),
    );
  }
}

class _GenreAlbumList extends StatelessWidget {
  const _GenreAlbumList({required this.albums});
  final List<AlbumResultEntity> albums;

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) {
      return const _GenreEmptyState(message: 'No albums yet.');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: albums.length,
      itemBuilder: (context, i) => SearchResultTileAlbum(album: albums[i]),
    );
  }
}

// ─── Horizontal card widgets ──────────────────────────────────────────────────

class _IntroducingCard extends ConsumerWidget {
  const _IntroducingCard({required this.track, required this.allTracks});

  final TrackResultEntity track;
  final List<TrackResultEntity> allTracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => playSearchTrack(context, ref, track, queueTracks: allTracks),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: track.artworkUrl != null
                  ? Image.network(
                      track.artworkUrl!,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          SearchArtworkPlaceholder(size: 140),
                    )
                  : SearchArtworkPlaceholder(size: 140),
            ),
            const SizedBox(height: 6),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            Text(
              track.artistName,
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

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist});
  final PlaylistResultEntity playlist;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${playlist.title} — playlist detail coming soon'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF222222),
        ),
      ),
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: playlist.artworkUrl != null
                  ? Image.network(
                      playlist.artworkUrl!,
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          SearchArtworkPlaceholder(size: 130),
                    )
                  : SearchArtworkPlaceholder(size: 130),
            ),
            const SizedBox(height: 6),
            Text(
              playlist.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            Text(
              playlist.creatorName,
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});
  final ProfileResultEntity profile;

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtherUserProfileScreen(userId: profile.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFF2A2A2A),
              backgroundImage: profile.avatarUrl != null
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: profile.avatarUrl == null
                  ? const Icon(Icons.person, color: Colors.white54, size: 28)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              profile.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            RelationshipButton(
              userId: profile.id,
              initialIsFollowing: profile.isFollowing,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Genre header background ──────────────────────────────────────────────────

/// Priority: local imageAsset → remote artworkUrl → solid genreColor.
class _GenreHeader extends StatelessWidget {
  const _GenreHeader({
    required this.genreColor,
    this.imageAsset,
    this.artworkUrl,
  });

  final Color genreColor;
  final String? imageAsset;
  final String? artworkUrl;

  @override
  Widget build(BuildContext context) {
    if (imageAsset != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: genreColor),
          Image.asset(
            imageAsset!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          Container(color: Colors.black.withValues(alpha: 0.25)),
        ],
      );
    }
    if (artworkUrl != null) {
      return Image.network(
        artworkUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: genreColor),
      );
    }
    return Container(color: genreColor);
  }
}

// ─── Error / empty states ──────────────────────────────────────────────────────

class _GenreErrorState extends StatelessWidget {
  const _GenreErrorState({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onRetry,
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

class _GenreEmptyState extends StatelessWidget {
  const _GenreEmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(message, style: const TextStyle(color: Colors.white54)),
  );
}
