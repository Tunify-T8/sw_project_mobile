import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/followers_and_social_graph/presentation/widgets/relationship_button.dart';
import '../../../../features/playlists/domain/entities/collection_privacy.dart';
import '../../../../features/playlists/domain/entities/collection_type.dart';
import '../../../../features/playlists/domain/entities/playlist_summary_entity.dart';
import '../../../../features/playlists/presentation/providers/playlist_providers.dart';
import '../../../../features/playlists/presentation/widgets/playlist_options_sheet.dart';
import '../../../../features/playlists/presentation/widgets/playlist_share_sheet.dart';
import '../../../../features/profile/presentation/screens/other_user_profile_screen.dart';
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
                      currentUserId: ref.read(authControllerProvider).value?.id,
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
    this.currentUserId,
  });

  final GenreDetailEntity? detail;
  final String genreId;
  final String genreLabel;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    if (detail == null) {
      return const _GenreEmptyState(message: 'Nothing here yet.');
    }

    final trendingTracks = detail!.trendingTracks;
    final introducingTracks = detail!.introducingTracks;
    final playlists = detail!.playlists;
    final albums = detail!.albums;

    if (trendingTracks.isEmpty &&
        introducingTracks.isEmpty &&
        playlists.isEmpty &&
        albums.isEmpty &&
        detail!.profiles.isEmpty) {
      return const _GenreEmptyState(
        message: 'No content in this genre yet.\nCheck back soon.',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // ── Trending tracks ─────────────────────────────────────────────────
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

        // ── Introducing tracks ──────────────────────────────────────────────
        if (introducingTracks.isNotEmpty) ...[
          const SizedBox(height: 16),
          SearchSectionHeader(
            title: 'Introducing',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchSeeAllScreen(
                  title: 'Introducing in $genreLabel',
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
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _IntroducingCard(
                track: introducingTracks[i],
                allTracks: introducingTracks,
              ),
            ),
          ),
        ],

        // ── Playlists ───────────────────────────────────────────────────────
        if (playlists.isNotEmpty) ...[
          const SizedBox(height: 16),
          SearchSectionHeader(
            title: 'Playlists',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchSeeAllScreen(
                  title: 'Playlists in $genreLabel',
                  playlists: playlists,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 192,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: playlists.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => Consumer(
                builder: (context, ref, _) {
                  final playlist = playlists[i];
                  final currentUserId =
                      ref.watch(authControllerProvider).value?.id.trim() ?? '';
                  final isMine = currentUserId.isNotEmpty &&
                      playlist.creatorId == currentUserId;
                  final summary = PlaylistSummaryEntity(
                    id: playlist.id,
                    title: playlist.title,
                    description: null,
                    type: CollectionType.playlist,
                    privacy: CollectionPrivacy.public,
                    coverUrl: playlist.artworkUrl,
                    trackCount: playlist.trackCount,
                    likeCount: playlist.likesCount,
                    repostsCount: 0,
                    ownerFollowerCount: 0,
                    isMine: isMine,
                    isLiked: playlist.isLiked,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  return _CollectionCard(
                    title: playlist.title,
                    subtitle: playlist.creatorName,
                    artworkUrl: playlist.artworkUrl,
                    onTap: () => Navigator.of(context).pushNamed(
                      Routes.playlistDetail,
                      arguments: {'playlistId': playlist.id, 'isMine': isMine},
                    ),
                    onMoreTap: () => showPlaylistOptionsSheet(
                      context: context,
                      playlist: summary,
                      collectionType: CollectionType.playlist,
                      onShare: () => showPlaylistShareSheet(
                        context: context,
                        playlist: summary,
                      ),
                      onLike: isMine
                          ? null
                          : () => ref
                              .read(playlistNotifierProvider.notifier)
                              .toggleLike(
                                playlist.id,
                                currentlyLiked: playlist.isLiked,
                              ),
                      onRepost: isMine
                          ? null
                          : () => ref
                              .read(playlistNotifierProvider.notifier)
                              .repostCollection(playlist.id),
                      onGoToArtistProfile: (!isMine &&
                              playlist.creatorId.isNotEmpty)
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OtherUserProfileScreen(
                                    userId: playlist.creatorId,
                                  ),
                                ),
                              )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ],

        // ── Albums ──────────────────────────────────────────────────────────
        if (albums.isNotEmpty) ...[
          const SizedBox(height: 16),
          SearchSectionHeader(
            title: 'Albums',
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchSeeAllScreen(
                  title: 'Albums in $genreLabel',
                  albums: albums,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 192,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: albums.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _CollectionCard(
                title: albums[i].title,
                subtitle: albums[i].artistName,
                artworkUrl: albums[i].artworkUrl,
                onTap: () => Navigator.of(context).pushNamed(
                  Routes.playlistDetail,
                  arguments: {'playlistId': albums[i].id},
                ),
              ),
            ),
          ),
        ],

        // ── Artists ─────────────────────────────────────────────────────────
        if (detail!.profiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SearchSectionHeader(title: 'Artists'),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: detail!.profiles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _GenreProfileTile(
                profile: detail!.profiles[i],
                currentUserId: currentUserId,
              ),
            ),
          ),
        ],

        // ── Discover More ───────────────────────────────────────────────────
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
              separatorBuilder: (_, __) => const SizedBox(width: 12),
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
    if (tracks.isEmpty) {
      return const _GenreEmptyState(message: 'No trending tracks yet.');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tracks.length,
      itemBuilder: (context, i) {
        final track = tracks[i];
        return SearchResultTileTrack(
          track: track,
          onTap: () =>
              playSearchTrack(context, ref, track, queueTracks: tracks),
        );
      },
    );
  }
}

class _GenrePlaylistList extends ConsumerWidget {
  const _GenrePlaylistList({required this.playlists});
  final List<PlaylistResultEntity> playlists;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (playlists.isEmpty) {
      return const _GenreEmptyState(message: 'No playlists yet.');
    }
    final currentUserId =
        ref.watch(authControllerProvider).value?.id.trim() ?? '';
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: playlists.length,
      itemBuilder: (context, i) {
        final playlist = playlists[i];
        final isMine =
            currentUserId.isNotEmpty && playlist.creatorId == currentUserId;
        return SearchResultTilePlaylist(
          playlist: playlist,
          onTap: () => Navigator.of(context).pushNamed(
            Routes.playlistDetail,
            arguments: {'playlistId': playlist.id, 'isMine': isMine},
          ),
        );
      },
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
      itemBuilder: (context, i) => SearchResultTileAlbum(
        album: albums[i],
        onTap: () => Navigator.of(context).pushNamed(
          Routes.playlistDetail,
          arguments: {'playlistId': albums[i].id},
        ),
      ),
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
                          const SearchArtworkPlaceholder(size: 140),
                    )
                  : const SearchArtworkPlaceholder(size: 140),
            ),
            const SizedBox(height: 6),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
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

/// Shared horizontal card for playlists and albums in the All tab.
class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.title,
    required this.subtitle,
    this.artworkUrl,
    required this.onTap,
    this.onMoreTap,
  });

  final String title;
  final String subtitle;
  final String? artworkUrl;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: artworkUrl != null
                  ? Image.network(
                      artworkUrl!,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const SearchArtworkPlaceholder(size: 140),
                    )
                  : const SearchArtworkPlaceholder(size: 140),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (onMoreTap != null)
                  InkWell(
                    onTap: onMoreTap,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.white54,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              subtitle,
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

class _GenreProfileTile extends StatelessWidget {
  const _GenreProfileTile({required this.profile, this.currentUserId});

  final ProfileResultEntity profile;
  final String? currentUserId;

  void _open(BuildContext context) {
    navigateToProfile(context, profile.id, currentUserId: currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              profile.displayLabel,
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

// ─── Error / empty states ─────────────────────────────────────────────────────

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
          child: const Text('Try again', style: TextStyle(color: Colors.white)),
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
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white54),
    ),
  );
}
