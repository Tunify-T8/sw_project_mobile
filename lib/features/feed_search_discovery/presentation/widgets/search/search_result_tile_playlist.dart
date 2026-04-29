import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../features/playlists/domain/entities/collection_privacy.dart';
import '../../../../../features/playlists/domain/entities/collection_type.dart';
import '../../../../../features/playlists/domain/entities/playlist_summary_entity.dart';
import '../../../../../features/playlists/presentation/providers/playlist_providers.dart';
import '../../../../../features/playlists/presentation/widgets/playlist_options_sheet.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../../features/profile/presentation/screens/other_user_profile_screen.dart';
import '../../../domain/entities/playlist_result_entity.dart';
import 'search_artwork_placeholder.dart';

class SearchResultTilePlaylist extends ConsumerWidget {
  const SearchResultTilePlaylist({
    super.key,
    required this.playlist,
    this.onTap,
  });

  final PlaylistResultEntity playlist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authControllerProvider).value?.id.trim() ?? '';
    final isMine = currentUserId.isNotEmpty && playlist.creatorId == currentUserId;
    return ListTile(
      key: ValueKey('search_playlist_tile_${playlist.id}'),
      onTap:
          onTap ??
          () => Navigator.of(context).pushNamed(
            Routes.playlistDetail,
            arguments: {'playlistId': playlist.id, 'isMine': isMine},
          ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: playlist.artworkUrl != null
            ? Image.network(
                playlist.artworkUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => SearchArtworkPlaceholder(size: 48),
              )
            : SearchArtworkPlaceholder(size: 48),
      ),
      title: Text(
        playlist.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            playlist.creatorName,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              const Icon(
                Icons.favorite_border,
                color: Colors.white38,
                size: 12,
              ),
              const SizedBox(width: 3),
              Text(
                _fmt(playlist.likesCount),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(width: 4),
              const Text(
                '·',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(width: 4),
              const Text(
                'Playlist',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(width: 4),
              const Text(
                '·',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(width: 4),
              Text(
                '${playlist.trackCount} Tracks',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        key: ValueKey('search_playlist_more_${playlist.id}'),
        icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
        onPressed: () {
          showPlaylistOptionsSheet(
            context: context,
            playlist: PlaylistSummaryEntity(
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
            ),
            collectionType: CollectionType.playlist,
            onLike: isMine
                ? null
                : () => ref.read(playlistNotifierProvider.notifier).toggleLike(
                      playlist.id,
                      currentlyLiked: playlist.isLiked,
                    ),
            onRepost: isMine
                ? null
                : () => ref
                    .read(playlistNotifierProvider.notifier)
                    .repostCollection(playlist.id),
            onGoToArtistProfile: (!isMine && playlist.creatorId.isNotEmpty)
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OtherUserProfileScreen(
                          userId: playlist.creatorId,
                        ),
                      ),
                    )
                : null,
          );
        },
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }
}
