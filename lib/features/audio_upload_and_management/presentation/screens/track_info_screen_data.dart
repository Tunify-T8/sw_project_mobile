part of 'track_info_screen.dart';

class _MockTrackStats {
  const _MockTrackStats({
    required this.likeCountText,
    required this.commentCountText,
    required this.repostCountText,
    required this.releaseDateText,
  });

  final String likeCountText;
  final String commentCountText;
  final String repostCountText;
  final String releaseDateText;

  factory _MockTrackStats.fromItem(UploadItem item) {
    final seed = item.id.hashCode.abs();
    final likes = 14000 + (seed % 22000);
    final comments = 70 + (seed % 300);
    final reposts = 40 + (seed % 220);
    final date = item.createdAt;

    return _MockTrackStats(
      likeCountText: _compactNumber(likes),
      commentCountText: '$comments',
      repostCountText: '$reposts',
      releaseDateText: '${date.day} ${_monthName(date.month)} ${date.year}',
    );
  }

  static String _compactNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[((month - 1).clamp(0, 11) as num).toInt()];
  }
}

final _trackInfoArtistProfileProvider = FutureProvider.autoDispose
    .family<ProfileDto?, String>((ref, trackId) async {
      var artistId = _resolveTrackArtistIdFromProvider(ref, trackId);
      if (artistId == null || artistId.isEmpty) {
        try {
          final bundle = await ref
              .read(playerRepositoryProvider)
              .getPlaybackBundle(trackId);
          artistId = bundle.artist.id.trim();
        } catch (_) {
          artistId = null;
        }
      }
      if (artistId == null || artistId.isEmpty) return null;
      return ref.read(profileRepositoryProvider).getProfileById(artistId);
    });

final _artistPublicPlaylistsProvider = FutureProvider.autoDispose
    .family<List<PlaylistSummaryEntity>, String>((ref, username) async {
      final safeUsername = username.trim();
      if (safeUsername.isEmpty) return const <PlaylistSummaryEntity>[];

      final repo = ref.read(playlistRepositoryProvider);
      final result = await repo.getUserPlaylists(
        username: safeUsername,
        limit: 20,
      );
      final publicPlaylists = result.items
          .where(
            (playlist) =>
                playlist.type == CollectionType.playlist &&
                playlist.privacy == CollectionPrivacy.public,
          )
          .toList(growable: false);
      return _resolvePlaylistCovers(repo, publicPlaylists);
    });

String? _resolveTrackArtistIdFromProvider(Ref ref, String trackId) {
  final storeOwner = ref
      .read(globalTrackStoreProvider)
      .ownerUserIdForTrack(trackId)
      ?.trim();
  if (storeOwner != null &&
      storeOwner.isNotEmpty &&
      storeOwner != '__global__') {
    return storeOwner;
  }

  final bundle = ref.read(playerProvider).asData?.value.bundle;
  if (bundle != null && bundle.trackId == trackId) {
    final id = bundle.artist.id.trim();
    if (id.isNotEmpty) return id;
  }

  return null;
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
        final firstTrackCover = tracks.items.isNotEmpty
            ? tracks.items.first.coverUrl
            : null;
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
