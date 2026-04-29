import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/playlist_summary_entity.dart';

void showPlaylistOptionsSheet({
  required BuildContext context,
  required PlaylistSummaryEntity playlist,
  // Own-playlist callbacks
  VoidCallback? onEdit,
  VoidCallback? onTogglePrivacy,
  VoidCallback? onAddMusic,
  VoidCallback? onDelete,
  VoidCallback? onCopyPlaylist,
  VoidCallback? onConvertToAlbum,
  VoidCallback? onConvertToPlaylist,
  // Other-user-playlist callbacks
  VoidCallback? onLike,
  VoidCallback? onRepost,
  VoidCallback? onGoToArtistProfile,
  // Shared
  bool isDetailView = false,
  VoidCallback? onShare,
  VoidCallback? onShufflePlay,
  CollectionType collectionType = CollectionType.playlist,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PlaylistOptionsSheet(
      hostContext: context,
      playlist: playlist,
      onEdit: onEdit,
      onTogglePrivacy: onTogglePrivacy,
      onAddMusic: onAddMusic,
      onDelete: onDelete,
      onCopyPlaylist: onCopyPlaylist,
      onConvertToAlbum: onConvertToAlbum,
      onConvertToPlaylist: onConvertToPlaylist,
      onLike: onLike,
      onRepost: onRepost,
      onGoToArtistProfile: onGoToArtistProfile,
      isDetailView: isDetailView,
      onShare: onShare,
      onShufflePlay: onShufflePlay,
      collectionType: collectionType,
    ),
  );
}

class _PlaylistOptionsSheet extends StatelessWidget {
  const _PlaylistOptionsSheet({
    required this.hostContext,
    required this.playlist,
    this.onEdit,
    this.onTogglePrivacy,
    this.onAddMusic,
    this.onDelete,
    this.onCopyPlaylist,
    this.onConvertToAlbum,
    this.onConvertToPlaylist,
    this.onLike,
    this.onRepost,
    this.onGoToArtistProfile,
    this.isDetailView = false,
    this.onShare,
    this.onShufflePlay,
    this.collectionType = CollectionType.playlist,
  });

  final BuildContext hostContext;
  final PlaylistSummaryEntity playlist;
  final VoidCallback? onEdit;
  final VoidCallback? onTogglePrivacy;
  final VoidCallback? onAddMusic;
  final VoidCallback? onDelete;
  final VoidCallback? onCopyPlaylist;
  final VoidCallback? onConvertToAlbum;
  final VoidCallback? onConvertToPlaylist;
  final VoidCallback? onLike;
  final VoidCallback? onRepost;
  final VoidCallback? onGoToArtistProfile;
  final bool isDetailView;
  final VoidCallback? onShare;
  final VoidCallback? onShufflePlay;
  final CollectionType collectionType;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _DragHandle(),
          _Header(playlist: playlist),
          const Divider(color: Colors.white12, height: 1),
          _OptionRow(
            key: const Key('playlist_option_share'),
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {
              Navigator.pop(context);
              onShare?.call();
            },
          ),
          if (playlist.isMine) ...[
            _OptionRow(
              key: const Key('playlist_option_edit'),
              icon: Icons.edit_outlined,
              label: 'Edit',
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
            _OptionRow(
              key: const Key('playlist_option_toggle_privacy'),
              icon: playlist.privacy == CollectionPrivacy.private
                  ? Icons.lock_open_outlined
                  : Icons.lock_outline,
              label: playlist.privacy == CollectionPrivacy.private
                  ? 'Make public'
                  : 'Make private',
              onTap: () {
                Navigator.pop(context);
                onTogglePrivacy?.call();
              },
            ),
            _OptionRow(
              key: const Key('playlist_option_add_music'),
              icon: Icons.library_add_outlined,
              label: 'Add music',
              onTap: () {
                Navigator.pop(context);
                onAddMusic?.call();
              },
            ),
            _OptionRow(
              key: const Key('playlist_option_delete'),
              icon: Icons.delete_outline,
              label: 'Delete',
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(hostContext);
              },
            ),
            if (isDetailView)
              _OptionRow(
                icon: Icons.copy_outlined,
                label: 'Copy playlist',
                onTap: () {
                  Navigator.pop(context);
                  onCopyPlaylist?.call();
                },
              ),
            if ((collectionType == CollectionType.playlist &&
                    onConvertToAlbum != null) ||
                (collectionType == CollectionType.album &&
                    onConvertToPlaylist != null))
              _OptionRow(
                icon: collectionType == CollectionType.playlist
                    ? Icons.album_outlined
                    : Icons.playlist_play,
                label: collectionType == CollectionType.playlist
                    ? 'Convert to album'
                    : 'Convert to playlist',
                onTap: () {
                  Navigator.pop(context);
                  if (collectionType == CollectionType.playlist) {
                    onConvertToAlbum?.call();
                  } else {
                    onConvertToPlaylist?.call();
                  }
                },
              ),
          ] else ...[
            if (onLike != null)
              _OptionRow(
                key: const Key('playlist_option_like'),
                icon: playlist.isLiked
                    ? Icons.favorite
                    : Icons.favorite_border_outlined,
                label: playlist.isLiked ? 'Unlike' : 'Like',
                onTap: () {
                  Navigator.pop(context);
                  onLike?.call();
                },
              ),
            if (onRepost != null)
              _OptionRow(
                key: const Key('playlist_option_repost'),
                icon: Icons.repeat_outlined,
                label: 'Repost',
                onTap: () {
                  Navigator.pop(context);
                  onRepost?.call();
                },
              ),
            if (onGoToArtistProfile != null)
              _OptionRow(
                key: const Key('playlist_option_go_to_artist'),
                icon: Icons.person_outline,
                label: 'Go to artist profile',
                onTap: () {
                  Navigator.pop(context);
                  onGoToArtistProfile?.call();
                },
              ),
          ],
          const Divider(color: Colors.white12, height: 1),
          _OptionRow(
            icon: Icons.queue_play_next_outlined,
            label: 'Play Next',
            onTap: () => Navigator.pop(context),
          ),
          _OptionRow(
            icon: Icons.add_to_queue_outlined,
            label: 'Play Last',
            onTap: () => Navigator.pop(context),
          ),
          if (isDetailView)
            _OptionRow(
              icon: Icons.shuffle,
              label: 'Shuffle play',
              onTap: () {
                Navigator.pop(context);
                onShufflePlay?.call();
              },
            ),
          SizedBox(height: bottomPadding + 8),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text(
          'Delete playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Delete "${playlist.title}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              onDelete?.call();
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.playlist});
  final PlaylistSummaryEntity playlist;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (playlist.coverUrl != null)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Image.network(playlist.coverUrl!, fit: BoxFit.cover),
            ),
          ),
        Container(color: Colors.black.withValues(alpha: 0.6)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              _CoverArt(coverUrl: playlist.coverUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist.privacy == CollectionPrivacy.private
                          ? 'Private'
                          : 'Public',
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverArt extends StatelessWidget {
  const _CoverArt({this.coverUrl});
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl != null
          ? Image.network(coverUrl!, fit: BoxFit.cover)
          : const Icon(Icons.queue_music, color: Colors.white38, size: 32),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: TextStyle(color: color, fontSize: 16)),
      dense: true,
    );
  }
}

//  Drag handle 

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
