import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/paginated_playlists.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_owner_entity.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../../domain/entities/playlist_track_entity.dart';
import '../dto/paginated_dto.dart';
import '../dto/playlist_dto.dart';
import '../dto/playlist_summary_dto.dart';
import '../dto/playlist_track_dto.dart';

/// Pure DTO → entity conversion functions.
/// No state, no side effects — safe to call from any layer.
class PlaylistMapper {
  const PlaylistMapper._();

  // ─── Full collection ──────────────────────────────────────────────────────

  static PlaylistEntity playlist(PlaylistDto d) => PlaylistEntity(
    id: d.id,
    title: d.title,
    description: d.description,
    type: CollectionType.fromJson(d.type),
    privacy: CollectionPrivacy.fromJson(d.privacy),
    secretToken: d.secretToken,
    coverUrl: d.coverUrl,
    trackCount: d.trackCount,
    likeCount: d.likeCount,
    repostsCount: d.repostsCount,
    ownerFollowerCount: d.ownerFollowerCount,
    isLiked: d.isLiked,
    owner: d.owner != null ? _owner(d.owner!) : null,
    createdAt: DateTime.parse(d.createdAt),
    updatedAt: DateTime.parse(d.updatedAt),
  );

  static PlaylistOwnerEntity _owner(PlaylistOwnerDto d) => PlaylistOwnerEntity(
    id: d.id,
    username: d.username,
    displayName: d.displayName,
    avatarUrl: d.avatarUrl,
    followerCount: d.followerCount,
  );

  // ─── Summary (list item) ──────────────────────────────────────────────────

  static PlaylistSummaryEntity summary(PlaylistSummaryDto d) =>
      PlaylistSummaryEntity(
        id: d.id,
        title: d.title,
        description: d.description,
        type: CollectionType.fromJson(d.type),
        privacy: CollectionPrivacy.fromJson(d.privacy),
        coverUrl: d.coverUrl,
        trackCount: d.trackCount,
        likeCount: d.likeCount,
        repostsCount: d.repostsCount,
        ownerFollowerCount: d.ownerFollowerCount,
        isMine: d.isMine,
        isLiked: d.isLiked,
        createdAt: DateTime.parse(d.createdAt),
        updatedAt: DateTime.parse(d.updatedAt),
      );

  // ─── Track ────────────────────────────────────────────────────────────────

  static PlaylistTrackEntity track(PlaylistTrackDto d) => PlaylistTrackEntity(
    position: d.position,
    addedAt: DateTime.parse(d.addedAt),
    trackId: d.trackId,
    title: d.title,
    durationSeconds: d.durationSeconds,
    coverUrl: d.coverUrl,
    genreId: d.genreId,
    isPublic: d.isPublic,
    playCount: d.playCount,
    ownerId: d.ownerId,
    ownerUsername: d.ownerUsername,
    ownerDisplayName: d.ownerDisplayName,
    ownerAvatarUrl: d.ownerAvatarUrl,
  );

  // ─── Paginated wrappers ───────────────────────────────────────────────────

  static PaginatedPlaylists paginatedSummaries(
    PaginatedDto<PlaylistSummaryDto> d,
  ) => PaginatedPlaylists(
    items: d.items.map(summary).toList(),
    total: d.total,
    page: d.page,
    limit: d.limit,
    hasMore: d.hasMore,
  );

  static PaginatedPlaylistTracks paginatedTracks(
    PaginatedDto<PlaylistTrackDto> d,
  ) => PaginatedPlaylistTracks(
    items: d.items.map(track).toList(),
    total: d.total,
    page: d.page,
    limit: d.limit,
    hasMore: d.hasMore,
  );
}
