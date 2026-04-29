import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../playback_streaming_engine/domain/entities/playback_queue.dart';
import '../../../playback_streaming_engine/domain/entities/playback_status.dart';
import '../../../playback_streaming_engine/domain/entities/player_seed_track.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../../playback_streaming_engine/presentation/widgets/mini_player.dart';
import '../../../../shared/ui/widgets/play_button.dart';
import '../widgets/add_track_sheet.dart';
import '../widgets/playlist_share_sheet.dart';
import '../widgets/secret_token_section.dart';
import '../widgets/track_in_playlist_options_sheet.dart';
import '../../../../core/routing/routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/screens/other_user_profile_screen.dart';
import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../../domain/entities/playlist_track_entity.dart';
import '../providers/playlist_providers.dart';
import '../providers/recent_playlists_provider.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_track_tile.dart';
import '../../../../shared/ui/patterns/error_message_view.dart';
import '../../../../shared/ui/patterns/error_retry_view.dart';
import '../../../../shared/ui/patterns/error_ui_mapper.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  const PlaylistDetailScreen({
    super.key,
    this.playlistId,
    this.secretToken,
    this.isMine = false,
  });
  final String? playlistId;
  final String? secretToken;
  final bool isMine;

  @override
  ConsumerState<PlaylistDetailScreen> createState() =>
      _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  Future<void> _reloadPlaylist() async {
    final notifier = ref.read(playlistNotifierProvider.notifier);
    final secretToken = widget.secretToken?.trim();
    if (secretToken != null && secretToken.isNotEmpty) {
      await notifier.openPlaylistByToken(secretToken);
      return;
    }

    final playlistId = widget.playlistId?.trim() ?? '';
    await notifier.openPlaylist(playlistId);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      _reloadPlaylist,
    );
  }

  Future<void> _playPlaylistTrack({
    required PlaylistEntity playlist,
    required PlaylistTrackEntity track,
    required List<PlaylistTrackEntity> tracks,
    bool shuffle = false,
  }) async {
    await ref.read(recentPlaylistsProvider.notifier).record(
          playlist,
          isMine: widget.isMine,
          coverUrl: playlist.coverUrl?.trim().isNotEmpty == true
              ? playlist.coverUrl
              : track.coverUrl,
        );

    try {
      await ref.read(playerProvider.notifier).buildAndLoadQueue(
            contextType: PlaybackContextType.playlist,
            contextId: playlist.id,
            startTrackId: track.trackId,
            shuffle: shuffle,
            privateToken: widget.secretToken,
            seedTrack: _seedTrack(track),
          );
      return;
    } catch (_) {
      final queueTrackIds = tracks
          .map((item) => item.trackId.trim())
          .where((id) => id.isNotEmpty)
          .toList(growable: true);

      if (!queueTrackIds.contains(track.trackId)) {
        queueTrackIds.insert(0, track.trackId);
      }

      var currentIndex = queueTrackIds.indexOf(track.trackId);
      if (shuffle && queueTrackIds.length > 1) {
        final rest = queueTrackIds
            .where((id) => id != track.trackId)
            .toList(growable: true)
          ..shuffle();
        queueTrackIds
          ..clear()
          ..add(track.trackId)
          ..addAll(rest);
        currentIndex = 0;
      }

      await ref.read(playerProvider.notifier).loadTrackWithQueue(
            trackId: track.trackId,
            trackIds: queueTrackIds,
            currentIndex: currentIndex < 0 ? 0 : currentIndex,
            privateToken: widget.secretToken,
            seedTrack: _seedTrack(track),
            source: QueueSource.playlist,
          );
    }
  }

  PlayerSeedTrack _seedTrack(PlaylistTrackEntity track) {
    return PlayerSeedTrack(
      trackId: track.trackId,
      title: track.title,
      artistName: track.ownerDisplayName ?? track.ownerUsername,
      durationSeconds: track.durationSeconds,
      coverUrl: track.coverUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistNotifierProvider);
    final playlist = state.activePlaylist;
    final tracks = state.activeTracks;
    final profileRole = ref.watch(profileProvider).profile?.role.toUpperCase();
    final authRole = ref.watch(authControllerProvider).value?.role.toUpperCase();
    final currentRole = (profileRole ?? authRole ?? 'USER').toUpperCase();
    final canEditAlbumAsCurrentUser = currentRole == 'ARTIST';
    final useAlbumListenerLayout =
        playlist?.type == CollectionType.album && !canEditAlbumAsCurrentUser;

    if (state.isDetailLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (state.detailError != null || playlist == null) {
      final uiError = mapToUiErrorState(state.detailError ?? 'Could not fetch playlist');
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: const BackButton(color: Colors.white),
        ),
        body: uiError.retryable
            ? ErrorRetryView(onRetry: _reloadPlaylist)
            : ErrorMessageView(message: uiError.message),
      );
    }

    final effectiveCoverUrl = (playlist.coverUrl != null &&
            playlist.coverUrl!.isNotEmpty)
        ? playlist.coverUrl
        : (tracks.isNotEmpty ? tracks.first.coverUrl : null);

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
                  _CoverImage(coverUrl: effectiveCoverUrl),
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

          SliverToBoxAdapter(
            child: SecretTokenSection(playlist: playlist),
          ),

          // ── Description ───────────────────────────────────────────────────
          if (playlist.description != null &&
              playlist.description!.isNotEmpty)
            SliverToBoxAdapter(
              child: _DescriptionSection(
                description: playlist.description!,
              ),
            ),

          // ── Action row ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('playlist_detail_more_button'),
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => showPlaylistOptionsSheet(
                      context: context,
                      playlist: _toSummary(playlist, isMine: widget.isMine),
                      collectionType: playlist.type,
                      useAlbumListenerLayout: useAlbumListenerLayout,
                      isDetailView: true,
                      // Own-playlist actions
                      onEdit: widget.isMine && !useAlbumListenerLayout
                          ? () async {
                              if (playlist.type == CollectionType.album &&
                                  !canEditAlbumAsCurrentUser) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Only artists can edit albums',
                                    ),
                                  ),
                                );
                                return;
                              }
                              await Navigator.of(context).pushNamed(
                                Routes.playlistEdit,
                                arguments: {'collectionId': playlist.id},
                              );
                              if (!mounted) return;
                              await _reloadPlaylist();
                            }
                          : null,
                      onTogglePrivacy: widget.isMine && !useAlbumListenerLayout
                          ? () {
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
                            }
                          : null,
                      onAddMusic: widget.isMine && !useAlbumListenerLayout
                          ? () => showAddTrackSheet(
                              context: context,
                              ref: ref,
                              collectionId: playlist.id,
                              collectionType: playlist.type,
                            )
                          : null,
                      onDelete: widget.isMine && !useAlbumListenerLayout
                          ? () {
                              ref
                                  .read(playlistNotifierProvider.notifier)
                                  .deleteCollection(playlist.id);
                              Navigator.of(context).pop();
                            }
                          : null,
                      // Other-user actions
                      onLike: widget.isMine
                          ? null
                          : () => ref
                              .read(playlistNotifierProvider.notifier)
                              .toggleLike(
                                playlist.id,
                                currentlyLiked: playlist.isLiked,
                              ),
                      onRepost: widget.isMine
                          ? null
                          : () => ref
                              .read(playlistNotifierProvider.notifier)
                              .repostCollection(playlist.id),
                      onGoToArtistProfile:
                          (widget.isMine || playlist.owner == null)
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OtherUserProfileScreen(
                                      userId: playlist.owner!.id,
                                    ),
                                  ),
                                ),
                      // Shared
                      onShare: () => showPlaylistShareSheet(
                        context: context,
                        playlist: _toSummary(playlist, isMine: widget.isMine),
                        secretToken: playlist.secretToken,
                      ),
                      onCopyPlaylist:
                          widget.isMine && !useAlbumListenerLayout ? () {} : null,
                      onConvertToAlbum: widget.isMine &&
                              !useAlbumListenerLayout &&
                              playlist.type == CollectionType.playlist
                          ? () {
                              if (!canEditAlbumAsCurrentUser) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Only artists can convert playlists to albums',
                                    ),
                                  ),
                                );
                                return;
                              }
                              ref
                                  .read(playlistNotifierProvider.notifier)
                                  .convertToAlbum(playlist.id);
                            }
                          : null,
                      onShufflePlay: tracks.isEmpty
                          ? null
                          : () => _playPlaylistTrack(
                                playlist: playlist,
                                track: tracks.first,
                                tracks: tracks,
                                shuffle: true,
                              ),
                    ),
                  ),
                  if (!widget.isMine) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => ref
                          .read(playlistNotifierProvider.notifier)
                          .toggleLike(
                            playlist.id,
                            currentlyLiked: playlist.isLiked,
                          ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            playlist.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: playlist.isLiked
                                ? Colors.redAccent
                                : Colors.white70,
                            size: 22,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatCount(playlist.likeCount),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (tracks.isNotEmpty) ...[
                    ShuffleButton(
                      onTap: () => _playPlaylistTrack(
                            playlist: playlist,
                            track: tracks.first,
                            tracks: tracks,
                            shuffle: true,
                          ),
                    ),
                    const SizedBox(width: 8),
                    PlayButton(
                      onTap: () => _playPlaylistTrack(
                            playlist: playlist,
                            track: tracks.first,
                            tracks: tracks,
                          ),
                    ),
                  ],
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
                  onTap: () => _playPlaylistTrack(
                    playlist: playlist,
                    track: track,
                    tracks: tracks,
                  ),
                  onMoreTap: () => showTrackInPlaylistOptionsSheet(
                    context: context,
                    ref: ref,
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

PlaylistSummaryEntity _toSummary(PlaylistEntity e, {bool isMine = true}) =>
    PlaylistSummaryEntity(
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
      isMine: isMine,
      isLiked: e.isLiked,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );

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
          ? Image.network(
            coverUrl!, 
            key: ValueKey(coverUrl),
            fit: BoxFit.cover)
          : const Icon(Icons.queue_music, color: Colors.white24, size: 48),
    );
  }
}

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
    final privacyLabel = playlist.privacy == CollectionPrivacy.private
        ? 'Private'
        : 'Public';
    final ownerName = playlist.owner?.displayName ?? playlist.owner?.username;
    final ownerAvatarUrl = playlist.owner?.avatarUrl;

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
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              playlist.privacy == CollectionPrivacy.private
                  ? Icons.lock_rounded
                  : Icons.public,
              color: Colors.white70,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              privacyLabel,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (ownerName != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF2A2A2A),
                backgroundImage: ownerAvatarUrl != null
                    ? NetworkImage(ownerAvatarUrl)
                    : null,
                child: ownerAvatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white38, size: 14)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      ownerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      '·',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      privacyLabel,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

String _formatCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.description});
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          GestureDetector(
            onTap: () => _showFull(context),
            child: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Show more',
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFull(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Text(
                  description,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
