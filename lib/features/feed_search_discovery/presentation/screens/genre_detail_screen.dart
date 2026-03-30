// lib/features/feed_search_discovery/presentation/screens/genre_detail_screen.dart
//
// Shown when user taps a genre from the idle grid.
// Has its own tab bar: All | Trending | Playlists | Albums
// "All" shows Trending section + Introducing section + Playlists row + Profiles row.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/genre_detail_entity.dart';
import '../../domain/entities/playlist_result_entity.dart';
import '../../domain/entities/profile_result_entity.dart';
import '../../domain/entities/track_result_entity.dart';
import '../../domain/entities/album_result_entity.dart';
import '../providers/search_provider.dart';
import '../widgets/search/search_result_tile_track.dart';
import '../widgets/search/search_result_tile_playlist.dart';
import '../widgets/search/search_result_tile_album.dart';
import '../widgets/search/search_section_header.dart';
import '../widgets/search/search_artwork_placeholder.dart';
import 'search_see_all_screen.dart';

class GenreDetailScreen extends ConsumerWidget {
  const GenreDetailScreen({
    super.key,
    required this.genreId,
    required this.genreLabel,
  });

  final String genreId;
  final String genreLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(genreDetailProvider(genreId));

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              backgroundColor: Colors.black,
              expandedHeight: 180,
              pinned: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  genreLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                background: state.detail?.artworkUrl != null
                    ? Image.network(
                        state.detail!.artworkUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            _GenreHeaderPlaceholder(label: genreLabel),
                      )
                    : _GenreHeaderPlaceholder(label: genreLabel),
              ),
              bottom: const TabBar(
                isScrollable: false,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Trending'),
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
                    // All tab
                    _GenreAllTab(
                      detail: state.detail,
                      genreId: genreId,
                      genreLabel: genreLabel,
                    ),
                    // Trending tab
                    _GenreTrackList(tracks: state.detail?.trendingTracks ?? []),
                    // Playlists tab
                    _GenrePlaylistList(
                      playlists: state.detail?.playlists ?? [],
                    ),
                    // Albums tab
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

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Trending section
        if (detail!.trendingTracks.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'Trending',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchSeeAllScreen(
                  title: 'Trending in $genreLabel',
                  tracks: detail!.trendingTracks,
                ),
              ),
            ),
          ),
          ...detail!.trendingTracks
              .take(5)
              .map((track) => SearchResultTileTrack(track: track)),
        ],

        // Introducing section
        if (detail!.introducingTracks.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SearchSectionHeader(title: 'Introducing'),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: detail!.introducingTracks.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (_, i) =>
                  _IntroducingCard(track: detail!.introducingTracks[i]),
            ),
          ),
        ],

        // Playlists section
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
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: detail!.playlists.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (_, i) =>
                  _PlaylistCard(playlist: detail!.playlists[i]),
            ),
          ),
        ],

        // Profiles section
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
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: detail!.profiles.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (_, i) => _ProfileCard(profile: detail!.profiles[i]),
            ),
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── Trending tab ─────────────────────────────────────────────────────────────

class _GenreTrackList extends StatelessWidget {
  const _GenreTrackList({required this.tracks});
  final List<TrackResultEntity> tracks;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return const _GenreEmptyState(message: 'No trending tracks yet.');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tracks.length,
      itemBuilder: (_, i) => SearchResultTileTrack(track: tracks[i]),
    );
  }
}

// ─── Playlists tab ────────────────────────────────────────────────────────────

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
      itemBuilder: (_, i) => SearchResultTilePlaylist(playlist: playlists[i]),
    );
  }
}

// ─── Albums tab ───────────────────────────────────────────────────────────────

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
      itemBuilder: (_, i) => SearchResultTileAlbum(album: albums[i]),
    );
  }
}

// ─── Small cards used in the All tab horizontal rows ─────────────────────────

class _IntroducingCard extends StatelessWidget {
  const _IntroducingCard({required this.track});
  final TrackResultEntity track;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist});
  final PlaylistResultEntity playlist;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});
  final ProfileResultEntity profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(60, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(fontSize: 11),
            ),
            child: Text(profile.isFollowing ? 'Following' : 'Follow'),
          ),
        ],
      ),
    );
  }
}

// ─── Header placeholder ───────────────────────────────────────────────────────

class _GenreHeaderPlaceholder extends StatelessWidget {
  const _GenreHeaderPlaceholder({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C1C1E),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─── Empty / error states ─────────────────────────────────────────────────────

class _GenreEmptyState extends StatelessWidget {
  const _GenreEmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.white54, fontSize: 15),
      ),
    );
  }
}

class _GenreErrorState extends StatelessWidget {
  const _GenreErrorState({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error,
            style: const TextStyle(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
