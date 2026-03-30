import '../../domain/entities/search_all_result_entity.dart';
import '../../domain/entities/album_result_entity.dart';
import '../../domain/entities/genre_detail_entity.dart';
import '../../domain/entities/search_genre_entity.dart';
import '../../domain/entities/playlist_result_entity.dart';
import '../../domain/entities/profile_result_entity.dart';
import '../../domain/entities/track_result_entity.dart';
import '../../domain/entities/top_result_entity.dart';
// Hardcoded mock data for all search scenarios:
//   - genre grid (idle state)
//   - all-tab aggregate result
//   - per-tab paginated results
//   - genre detail (trending, introducing, playlists, profiles, albums)
//
// artworkUrl fields are null throughout — placeholder widgets handle rendering.
// Replace with real URLs when backend is connected.

class MockSearchService {
  // ─── Genres ────────────────────────────────────────────────────────────────

  Future<List<SearchGenreEntity>> getGenres() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      SearchGenreEntity(
        id: 'hip_hop_rap',
        label: 'Hip Hop & Rap',
        colorValue: 0xFF6B2D8B,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'electronic',
        label: 'Electronic',
        colorValue: 0xFF1A6B8A,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'pop',
        label: 'Pop',
        colorValue: 0xFF8B2D6B,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'rnb',
        label: 'R&B',
        colorValue: 0xFF2D6B8B,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'party',
        label: 'Party',
        colorValue: 0xFF8B6B2D,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'chill',
        label: 'Chill',
        colorValue: 0xFF2D8B6B,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'workout',
        label: 'Workout',
        colorValue: 0xFF8B2D2D,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'techno',
        label: 'Techno',
        colorValue: 0xFF3D3D8B,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'indie',
        label: 'Indie',
        colorValue: 0xFF6B8B2D,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'house',
        label: 'House',
        colorValue: 0xFF8B4A2D,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'soul',
        label: 'Soul',
        colorValue: 0xFF5A2D8B,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'folk',
        label: 'Folk',
        colorValue: 0xFF4A6B2D,
        artworkUrl: null,
      ),
    ];
  }

  // ─── All-tab aggregate ─────────────────────────────────────────────────────

  Future<SearchAllResultEntity> searchAll(String query) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (query.trim().isEmpty) {
      return const SearchAllResultEntity();
    }

    return SearchAllResultEntity(
      topResult: const TopResultEntity(
        id: 'artist_001',
        type: TopResultType.profile,
        title: 'Don Toliver',
        subtitle: '688K Followers',
        artworkUrl: null,
      ),
      tracks: _mockTracks(),
      playlists: _mockPlaylists(),
      profiles: _mockProfiles(),
      albums: _mockAlbums(),
    );
  }

  // ─── Tab-specific searches ─────────────────────────────────────────────────

  Future<List<TrackResultEntity>> searchTracks(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (query.trim().isEmpty) return [];
    final all = _mockTracks();
    return _paginate(all, page, limit);
  }

  Future<List<ProfileResultEntity>> searchProfiles(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (query.trim().isEmpty) return [];
    final all = _mockProfiles();
    return _paginate(all, page, limit);
  }

  Future<List<PlaylistResultEntity>> searchPlaylists(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (query.trim().isEmpty) return [];
    final all = _mockPlaylists();
    return _paginate(all, page, limit);
  }

  Future<List<AlbumResultEntity>> searchAlbums(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (query.trim().isEmpty) return [];
    final all = _mockAlbums();
    return _paginate(all, page, limit);
  }

  // ─── Genre detail ──────────────────────────────────────────────────────────

  Future<GenreDetailEntity> getGenreDetail(String genreId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final label = _genreLabelFromId(genreId);

    return GenreDetailEntity(
      genreId: genreId,
      genreLabel: label,
      artworkUrl: null,
      trendingTracks: _mockTracks().take(5).toList(),
      introducingTracks: [
        const TrackResultEntity(
          id: 'intro_001',
          title: 'Buzzing Hip Hop & Rap',
          artistName: 'Various Artists',
          artworkUrl: null,
          durationSeconds: 210,
          playCount: null,
        ),
        const TrackResultEntity(
          id: 'intro_002',
          title: 'FOREVER (Prod.Emidivine1)',
          artistName: 'Latenek',
          artworkUrl: null,
          durationSeconds: 185,
          playCount: null,
        ),
      ],
      playlists: _mockPlaylists(),
      profiles: _mockProfiles().take(3).toList(),
      albums: _mockAlbums(),
    );
  }

  // ─── Shared mock data ──────────────────────────────────────────────────────

  List<TrackResultEntity> _mockTracks() => const [
    TrackResultEntity(
      id: 'track_001',
      title: 'Ocean (Long Way)',
      artistName: 'Don Toliver',
      artworkUrl: null,
      durationSeconds: 218,
      playCount: '45K',
    ),
    TrackResultEntity(
      id: 'track_002',
      title: 'Rocket Power (Ocean)',
      artistName: 'Don Toliver',
      artworkUrl: null,
      durationSeconds: 245,
      playCount: '20.1K',
    ),
    TrackResultEntity(
      id: 'track_003',
      title: 'Falling Asleep (Ocean)',
      artistName: 'Don Toliver',
      artworkUrl: null,
      durationSeconds: 199,
      playCount: '19.2K',
    ),
    TrackResultEntity(
      id: 'track_004',
      title: 'OPPOSITE [LIVE]',
      artistName: 'Don Toliver',
      artworkUrl: null,
      durationSeconds: 230,
      playCount: '84.2K',
    ),
    TrackResultEntity(
      id: 'track_005',
      title: 'Cardigan',
      artistName: 'Peppuzz',
      artworkUrl: null,
      durationSeconds: 174,
      playCount: '12K',
    ),
    TrackResultEntity(
      id: 'track_006',
      title: 'Nothing Above Y...',
      artistName: 'Don Toliver',
      artworkUrl: null,
      durationSeconds: 207,
      playCount: '17.6K',
      isUnavailable: true,
    ),
  ];

  List<ProfileResultEntity> _mockProfiles() => const [
    ProfileResultEntity(
      id: 'profile_001',
      username: 'Don Toliver',
      avatarUrl: null,
      location: 'United States',
      followersCount: 688000,
      isVerified: true,
      isFollowing: false,
    ),
    ProfileResultEntity(
      id: 'profile_002',
      username: 'Don Toliver•',
      avatarUrl: null,
      location: null,
      followersCount: 1472,
      isFollowing: false,
    ),
    ProfileResultEntity(
      id: 'profile_003',
      username: 'Don Toliver AI Songs',
      avatarUrl: null,
      location: null,
      followersCount: 624,
      isFollowing: false,
    ),
    ProfileResultEntity(
      id: 'profile_004',
      username: 'Don Toliver Vault',
      avatarUrl: null,
      location: 'Nigeria',
      followersCount: 193,
      isFollowing: false,
    ),
  ];

  List<PlaylistResultEntity> _mockPlaylists() => const [
    PlaylistResultEntity(
      id: 'playlist_001',
      title: 'OCTANE DON TOLIVER ALBUM',
      creatorName: 'GBP',
      artworkUrl: null,
      trackCount: 7,
    ),
    PlaylistResultEntity(
      id: 'playlist_002',
      title: 'OCTANE - DON TOLIVER | NE...',
      creatorName: 'RUN IT UP',
      artworkUrl: null,
      trackCount: 6,
    ),
    PlaylistResultEntity(
      id: 'playlist_003',
      title: 'OCTANE - DON TOLIVER [2026...',
      creatorName: 'The Wave Cache',
      artworkUrl: null,
      trackCount: 8,
    ),
    PlaylistResultEntity(
      id: 'playlist_004',
      title: 'Trap Leg Day',
      creatorName: 'Trending Music',
      artworkUrl: null,
      trackCount: 33,
    ),
    PlaylistResultEntity(
      id: 'playlist_005',
      title: 'Hip Hop & Rap',
      creatorName: 'Discovery Playlists',
      artworkUrl: null,
      trackCount: 50,
    ),
  ];

  List<AlbumResultEntity> _mockAlbums() => const [
    AlbumResultEntity(
      id: 'album_001',
      title: 'OCTANE',
      artistName: 'Don Toliver',
      artworkUrl: null,
      trackCount: 18,
      releaseYear: 2026,
    ),
    AlbumResultEntity(
      id: 'album_002',
      title: 'early life crisis',
      artistName: 'nattepati',
      artworkUrl: null,
      trackCount: 9,
      releaseYear: 2025,
    ),
    AlbumResultEntity(
      id: 'album_003',
      title: 'THE COMEDOWN',
      artistName: 'Smokedope2016',
      artworkUrl: null,
      trackCount: 12,
      releaseYear: 2025,
    ),
    AlbumResultEntity(
      id: 'album_004',
      title: 'ANABIOS',
      artistName: 'Miyagi & Эндшпиль',
      artworkUrl: null,
      trackCount: 14,
      releaseYear: 2026,
    ),
  ];

  String _genreLabelFromId(String id) {
    const map = {
      'hip_hop_rap': 'Hip Hop & Rap',
      'electronic': 'Electronic',
      'pop': 'Pop',
      'rnb': 'R&B',
      'party': 'Party',
      'chill': 'Chill',
      'workout': 'Workout',
      'techno': 'Techno',
      'indie': 'Indie',
      'house': 'House',
      'soul': 'Soul',
      'folk': 'Folk',
    };
    return map[id] ?? id;
  }

  List<T> _paginate<T>(List<T> items, int page, int limit) {
    final start = (page - 1) * limit;
    if (start >= items.length) return [];
    final end = (start + limit).clamp(0, items.length);
    return items.sublist(start, end);
  }
}
