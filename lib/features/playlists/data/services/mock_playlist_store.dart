import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../dto/playlist_dto.dart';
import '../dto/playlist_track_dto.dart';

/// In-memory data store for [MockPlaylistRepositoryImpl].
///
/// Kept as a separate class so the mock repo stays small and the store
/// can be shared or reset between tests.
class MockPlaylistStore {
  MockPlaylistStore() {
    _seed();
  }

  // Mutable in-memory collections keyed by id.
  final Map<String, PlaylistDto> collections = {};

  // Tracks per collection: collectionId → ordered list of track DTOs.
  final Map<String, List<PlaylistTrackDto>> tracks = {};

  // Liked collection ids for the current mock user.
  final Set<String> likedCollectionIds = {};

  // Simulated current user.
  static const String currentUserId = 'mock-user-1';
  static const String currentUsername = 'mock_user';

  void _seed() {
    final now = DateTime.now().toIso8601String();

    // ── Playlist 1 — public ──────────────────────────────────────────────
    collections['pl-1'] = PlaylistDto(
      id: 'pl-1',
      title: 'Summer Vibes',
      description: 'Chill tracks for the season',
      type: CollectionType.playlist.toJson(),
      privacy: CollectionPrivacy.public.toJson(),
      secretToken: null,
      coverUrl: null,
      trackCount: 3,
      likeCount: 12,
      owner: PlaylistOwnerDto(
        id: currentUserId,
        username: currentUsername,
        displayName: 'Mock User',
        avatarUrl: null,
      ),
      createdAt: now,
      updatedAt: now,
    );

    tracks['pl-1'] = [
      _stubTrack(position: 1, trackId: 'track-a', title: 'Ocean Drive'),
      _stubTrack(position: 2, trackId: 'track-b', title: 'Midnight Run'),
      _stubTrack(position: 3, trackId: 'track-c', title: 'Golden Hour'),
    ];

    // ── Playlist 2 — private ─────────────────────────────────────────────
    collections['pl-2'] = PlaylistDto(
      id: 'pl-2',
      title: 'Late Night Sessions',
      description: null,
      type: CollectionType.playlist.toJson(),
      privacy: CollectionPrivacy.private.toJson(),
      secretToken: 'a3f9d2b1c4e7f8a0b2c3d4e5f6a7b8c9',
      coverUrl: null,
      trackCount: 1,
      likeCount: 0,
      owner: PlaylistOwnerDto(
        id: currentUserId,
        username: currentUsername,
        displayName: 'Mock User',
        avatarUrl: null,
      ),
      createdAt: now,
      updatedAt: now,
    );

    tracks['pl-2'] = [
      _stubTrack(position: 1, trackId: 'track-d', title: 'Slow Burn'),
    ];
  }

  /// Resets the store to its seeded state (useful in tests).
  void reset() {
    collections.clear();
    tracks.clear();
    likedCollectionIds.clear();
    _seed();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  PlaylistTrackDto _stubTrack({
    required int position,
    required String trackId,
    required String title,
  }) {
    return PlaylistTrackDto(
      position: position,
      addedAt: DateTime.now().toIso8601String(),
      trackId: trackId,
      title: title,
      durationSeconds: 180,
      coverUrl: null,
      genreId: null,
      isPublic: true,
      ownerId: currentUserId,
      ownerUsername: currentUsername,
      ownerDisplayName: 'Mock User',
      ownerAvatarUrl: null,
    );
  }
}
