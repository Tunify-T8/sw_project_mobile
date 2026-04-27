import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/routes.dart';
import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../providers/playlist_providers.dart';
import 'add_track_sheet.dart';
import 'create_edit_playlist_sheet.dart';
import 'playlist_options_sheet.dart';
import 'playlist_share_sheet.dart';
import 'playlist_tile.dart';

class ProfilePlaylistsSection extends ConsumerStatefulWidget {
  const ProfilePlaylistsSection({
    super.key,
    this.username,
    this.ownerName,
    this.isCurrentUser = false,
  });

  final String? username;
  final String? ownerName;
  final bool isCurrentUser;

  @override
  ConsumerState<ProfilePlaylistsSection> createState() =>
      _ProfilePlaylistsSectionState();
}

class _ProfilePlaylistsSectionState
    extends ConsumerState<ProfilePlaylistsSection> {
  List<PlaylistSummaryEntity> _playlists = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ProfilePlaylistsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username ||
        oldWidget.isCurrentUser != widget.isCurrentUser) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!widget.isCurrentUser &&
        (widget.username == null || widget.username!.trim().isEmpty)) {
      if (mounted) {
        setState(() {
          _playlists = [];
          _loading = false;
          _error = null;
        });
      }
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = ref.read(playlistRepositoryProvider);
      final result = widget.isCurrentUser
          ? await repo.getMyCollections(
              type: CollectionType.playlist,
              limit: 20,
            )
          : await repo.getUserPlaylists(
              username: widget.username!.trim(),
              limit: 20,
            );
      final playlists = await _resolvePlaylistCovers(repo, result.items);
      if (!mounted) return;
      setState(() {
        _playlists = playlists;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _openCreateSheet(BuildContext context) async {
    await showCreatePlaylistSheet(context: context, ref: ref);
    if (!mounted) return;
    await _load();
  }

  Future<void> _deleteAndReload(String playlistId) async {
    await ref.read(playlistNotifierProvider.notifier).deleteCollection(
          playlistId,
        );
    if (!mounted) return;
    await _load();
  }

  Future<void> _togglePrivacyAndReload(
    PlaylistSummaryEntity playlist,
  ) async {
    final newPrivacy = playlist.privacy == CollectionPrivacy.private
        ? CollectionPrivacy.public
        : CollectionPrivacy.private;
    await ref.read(playlistNotifierProvider.notifier).editCollection(
          id: playlist.id,
          privacy: newPrivacy,
        );
    if (!mounted) return;
    await _load();
  }

  Future<List<PlaylistSummaryEntity>> _resolvePlaylistCovers(
    PlaylistRepository repo,
    List<PlaylistSummaryEntity> playlists,
  ) async {
    final resolved = await Future.wait(
      playlists.map((playlist) async {
        if (playlist.coverUrl != null ||
            playlist.trackCount <= 0 ||
            playlist.type != CollectionType.playlist) {
          return playlist;
        }

        try {
          final tracks = await repo.getCollectionTracks(
            collectionId: playlist.id,
            limit: 1,
          );
          final firstTrackCover =
              tracks.items.isNotEmpty ? tracks.items.first.coverUrl : null;
          if (firstTrackCover == null || firstTrackCover.isEmpty) {
            return playlist;
          }
          return _copyPlaylistWithCover(playlist, firstTrackCover);
        } catch (_) {
          return playlist;
        }
      }),
    );

    return resolved;
  }

  PlaylistSummaryEntity _copyPlaylistWithCover(
    PlaylistSummaryEntity playlist,
    String coverUrl,
  ) {
    return PlaylistSummaryEntity(
      id: playlist.id,
      title: playlist.title,
      description: playlist.description,
      type: playlist.type,
      privacy: playlist.privacy,
      coverUrl: coverUrl,
      trackCount: playlist.trackCount,
      likeCount: playlist.likeCount,
      repostsCount: playlist.repostsCount,
      ownerFollowerCount: playlist.ownerFollowerCount,
      isMine: playlist.isMine,
      isLiked: playlist.isLiked,
      createdAt: playlist.createdAt,
      updatedAt: playlist.updatedAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _playlists.isEmpty && !widget.isCurrentUser) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 9),
                child: Text(
                  'Playlists',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (widget.isCurrentUser)
                TextButton(
                  onPressed: () {
                    _openCreateSheet(context);
                  },
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              if (widget.isCurrentUser)
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    Routes.playlists,
                  ),
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.orangeAccent,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            )
          else if (_playlists.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 9, vertical: 12),
              child: Text(
                'No playlists yet',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _playlists.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final playlist = _playlists[index];
                return PlaylistTile(
                  playlist: playlist,
                  ownerName: widget.isCurrentUser ? null : widget.ownerName,
                  onTap: () => Navigator.of(context).pushNamed(
                    Routes.playlistDetail,
                    arguments: {'playlistId': playlist.id},
                  ),
                  onMoreTap: () => _showOptions(context, playlist),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, PlaylistSummaryEntity playlist) {
    if (!widget.isCurrentUser) {
      showPlaylistShareSheet(
        context: context,
        playlist: playlist,
      );
      return;
    }

    showPlaylistOptionsSheet(
      context: context,
      playlist: playlist,
      onShare: () => showPlaylistShareSheet(
        context: context,
        playlist: playlist,
      ),
      onEdit: () => Navigator.of(
        context,
      ).pushNamed(Routes.playlistEdit, arguments: {'collectionId': playlist.id}),
      onTogglePrivacy: () {
        _togglePrivacyAndReload(playlist);
      },
      onAddMusic: () => showAddTrackSheet(
        context: context,
        ref: ref,
        collectionId: playlist.id,
      ),
      onDelete: () {
        _deleteAndReload(playlist.id);
      },
    );
  }
}
