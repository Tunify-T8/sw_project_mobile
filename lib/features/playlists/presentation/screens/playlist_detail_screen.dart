import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../playback_streaming_engine/presentation/widgets/mini_player.dart';
import '../widgets/add_track_sheet.dart';
import '../widgets/create_edit_playlist_sheet.dart';
import '../widgets/track_in_playlist_options_sheet.dart';
import '../../../../core/routing/routes.dart';
import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../../domain/entities/playlist_track_entity.dart';
import '../providers/playlist_providers.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_track_tile.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});
  final String playlistId;

  @override
  ConsumerState<PlaylistDetailScreen> createState() =>
      _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(playlistNotifierProvider.notifier)
          .openPlaylist(widget.playlistId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistNotifierProvider);
    final playlist = state.activePlaylist;
    final tracks = state.activeTracks;

    if (state.isDetailLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (state.detailError != null || playlist == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: const BackButton(color: Colors.white),
        ),
        body: Center(
          child: Text(
            state.detailError ?? 'Playlist not found',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const MiniPlayer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Colors.black,
            floating: true,
            leading: const BackButton(color: Colors.white),
            title: Text(
              playlist.type.name[0].toUpperCase() +
                  playlist.type.name.substring(1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.cast, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CoverImage(coverUrl: playlist.coverUrl),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _HeaderInfo(
                      playlist: playlist,
                      tracks: tracks,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Action row ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => showPlaylistOptionsSheet(
                      context: context,
                      playlist: _toSummary(playlist),
                      isDetailView: true,
                      onEdit: () => showCreateEditPlaylistSheet(
                        context: context,
                        ref: ref,
                        existing: _toSummary(playlist),
                      ),
                      onTogglePrivacy: () {
                        final newPrivacy =
                            playlist.privacy == CollectionPrivacy.private
                                ? CollectionPrivacy.public
                                : CollectionPrivacy.private;
                        ref
                            .read(playlistNotifierProvider.notifier)
                            .editCollection(
                              id: playlist.id,
                              privacy: newPrivacy,
                            );
                      },
                      onAddMusic: () => showAddTrackSheet(
                        context: context,
                        ref: ref,
                        collectionId: playlist.id,
                      ),
                      onDelete: () {
                        ref
                            .read(playlistNotifierProvider.notifier)
                            .deleteCollection(playlist.id);
                        Navigator.of(context).pop();
                      },
                      onCopyPlaylist: () {},
                      onShufflePlay: () {},
                    ),
                  ),
                  const Spacer(),
                  if (tracks.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.reorder, color: Colors.white),
                      tooltip: 'Reorder',
                      onPressed: () => Navigator.of(context).pushNamed(
                        Routes.playlistReorder,
                        arguments: {'collectionId': playlist.id},
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.shuffle, color: Colors.white),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  _PlayButton(onTap: () {}),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Divider(color: Colors.white12, height: 1),
          ),

          // ── Track list ────────────────────────────────────────────────────
          if (tracks.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No tracks yet',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: tracks.length,
              itemBuilder: (_, i) {
                final track = tracks[i];
                return PlaylistTrackTile(
                  track: track,
                  onTap: () {},
                  onMoreTap: () => showTrackInPlaylistOptionsSheet(
                    context: context,
                    track: track,
                    onRemoveFromPlaylist: () => ref
                        .read(playlistNotifierProvider.notifier)
                        .removeTrack(
                          collectionId: playlist.id,
                          trackId: track.trackId,
                        ),
                  ),
                );
              },
            ),

          // ── Suggested for you (stub) ───────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Suggested for you',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 160)),
        ],
      ),
    );
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

PlaylistSummaryEntity _toSummary(PlaylistEntity e) => PlaylistSummaryEntity(
      id: e.id,
      title: e.title,
      description: e.description,
      type: e.type,
      privacy: e.privacy,
      coverUrl: e.coverUrl,
      trackCount: e.trackCount,
      likeCount: e.likeCount,
      repostsCount: e.repostsCount,
      ownerFollowerCount: e.ownerFollowerCount,
      isMine: true,
      isLiked: e.isLiked,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );

// ─── Cover image ──────────────────────────────────────────────────────────────

class _CoverImage extends StatelessWidget {
  const _CoverImage({this.coverUrl});
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl != null
          ? Image.network(coverUrl!, fit: BoxFit.cover)
          : const Icon(Icons.queue_music, color: Colors.white24, size: 48),
    );
  }
}

// ─── Header info ─────────────────────────────────────────────────────────────

class _HeaderInfo extends StatelessWidget {
  const _HeaderInfo({required this.playlist, required this.tracks});

  final PlaylistEntity playlist;
  final List<PlaylistTrackEntity> tracks;

  String _totalDuration() {
    final total =
        tracks.fold<int>(0, (sum, t) => sum + t.durationSeconds);
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) return '${h}h ${m}m';
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    return 'today';
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = playlist.type.name[0].toUpperCase() +
        playlist.type.name.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          playlist.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          '$typeLabel · ${playlist.trackCount} Track${playlist.trackCount != 1 ? 's' : ''}'
          '${tracks.isNotEmpty ? ' · ${_totalDuration()}' : ''}'
          ' · ${_timeAgo(playlist.createdAt)}',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        if (playlist.owner != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF2A2A2A),
                backgroundImage: playlist.owner!.avatarUrl != null
                    ? NetworkImage(playlist.owner!.avatarUrl!)
                    : null,
                child: playlist.owner!.avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white38, size: 14)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'By ',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              Text(
                playlist.owner!.displayName ?? playlist.owner!.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Play button ──────────────────────────────────────────────────────────────

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.play_arrow, color: Colors.black, size: 30),
      ),
    );
  }
}
