import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/routes.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../providers/playlist_providers.dart';

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(
              height: 248,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 0),
                itemCount: _playlists.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final playlist = _playlists[index];
                  return _ProfilePlaylistCard(
                    playlist: playlist,
                    ownerName: widget.ownerName,
                    onTap: () async {
                      await Navigator.of(context).pushNamed(
                        Routes.playlistDetail,
                        arguments: {
                          'playlistId': playlist.id,
                          'isMine': playlist.isMine,
                        },
                      );
                      if (!mounted) return;
                      await _load();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfilePlaylistCard extends StatelessWidget {
  const _ProfilePlaylistCard({
    required this.playlist,
    required this.onTap,
    this.ownerName,
  });

  final PlaylistSummaryEntity playlist;
  final String? ownerName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayOwner = ownerName?.trim() ?? '';

    return SizedBox(
      width: 180,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(2),
              ),
              clipBehavior: Clip.antiAlias,
              child: playlist.coverUrl != null && playlist.coverUrl!.isNotEmpty
                  ? Image.network(
                      playlist.coverUrl!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.queue_music,
                      color: Colors.white24,
                      size: 42,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              playlist.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            if (displayOwner.isNotEmpty)
              Text(
                displayOwner,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
