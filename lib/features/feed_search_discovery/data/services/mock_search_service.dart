// Hardcoded mock data for all search scenarios:
//   - genre grid (idle state)
//   - all-tab aggregate result
//   - per-tab paginated results
//   - genre detail (trending, introducing, playlists, profiles, albums)
//
// artworkUrl fields are null throughout — placeholder widgets handle rendering.
// Replace with real URLs when backend is connected.
import '../../domain/entities/search_all_result_entity.dart';
import '../../domain/entities/top_result_entity.dart';
import '../../domain/entities/track_result_entity.dart';
import '../../domain/entities/playlist_result_entity.dart';
import '../../domain/entities/profile_result_entity.dart';
import '../../domain/entities/album_result_entity.dart';
import '../../domain/entities/search_genre_entity.dart';
import '../../domain/entities/genre_detail_entity.dart';

class MockSearchService {
  // ─── Genres ────────────────────────────────────────────────────────────────

  Future<List<SearchGenreEntity>> getGenres() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      SearchGenreEntity(
        id: 'hip_hop_rap',
        label: 'Hip Hop & Rap',
        colorValue: 0xFFA259FF,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'pop',
        label: 'Pop',
        colorValue: 0xFFFFD60A,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'chill',
        label: 'Chill',
        colorValue: 0xFF0FA3B1,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'workout',
        label: 'Workout',
        colorValue: 0xFF10A674,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'house',
        label: 'House',
        colorValue: 0xFFFF4FA3,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'indie',
        label: 'Indie',
        colorValue: 0xFF2D6CDF,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'electronic',
        label: 'Electronic',
        colorValue: 0xFFFF4FA3,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'rnb',
        label: 'R&B',
        colorValue: 0xFF0FA3B1,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'party',
        label: 'Party',
        colorValue: 0xFFFF8C42,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'techno',
        label: 'Techno',
        colorValue: 0xFFFF4FA3,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'folk',
        label: 'Folk',
        colorValue: 0xFFFF8C42,
        artworkUrl: null,
      ),
      SearchGenreEntity(
        id: 'soul',
        label: 'Soul',
        colorValue: 0xFF0FA3B1,
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

    final tracks = _mockTracks();
    final playlists = _mockPlaylists();
    final profiles = _mockProfiles();
    final albums = _mockAlbums();

    return SearchAllResultEntity(
      topResult: _selectTopResult(query, tracks, profiles, albums, playlists),
      tracks: tracks,
      playlists: playlists,
      profiles: profiles,
      albums: albums,
    );
  }

  TopResultEntity? _selectTopResult(
    String query,
    List<TrackResultEntity> tracks,
    List<ProfileResultEntity> profiles,
    List<AlbumResultEntity> albums,
    List<PlaylistResultEntity> playlists,
  ) {
    final q = query.toLowerCase().trim();

    int score(String name) {
      final n = name.toLowerCase();
      if (n == q) return 3;
      if (n.startsWith(q)) return 2;
      if (n.contains(q)) return 1;
      return 0;
    }

    TopResultEntity? best;
    int bestScore = 0;

    // Profiles checked first — tied scores: profile beats other types
    for (final p in profiles) {
      final s = score(p.username);
      if (s > bestScore) {
        bestScore = s;
        best = TopResultEntity(
          id: p.id,
          type: TopResultType.profile,
          title: p.username,
          subtitle: '${_fmtFollowers(p.followersCount)} Followers',
          artworkUrl: p.avatarUrl,
        );
      }
    }

    // Albums only beat profile if strictly higher score
    for (final a in albums) {
      final s = score(a.title);
      if (s > bestScore) {
        bestScore = s;
        best = TopResultEntity(
          id: a.id,
          type: TopResultType.album,
          title: a.title,
          subtitle: '${a.artistName} · ${a.trackCount} tracks',
          artworkUrl: a.artworkUrl,
        );
      }
    }

    for (final pl in playlists) {
      final s = score(pl.title);
      if (s > bestScore) {
        bestScore = s;
        best = TopResultEntity(
          id: pl.id,
          type: TopResultType.playlist,
          title: pl.title,
          subtitle: '${pl.creatorName} · ${pl.trackCount} tracks',
          artworkUrl: pl.artworkUrl,
        );
      }
    }

    for (final t in tracks) {
      final s = score(t.title);
      if (s > bestScore) {
        bestScore = s;
        best = TopResultEntity(
          id: t.id,
          type: TopResultType.track,
          title: t.title,
          subtitle: t.artistName,
          artworkUrl: t.artworkUrl,
        );
      }
    }

    // Default fallback
    if (best == null && profiles.isNotEmpty) {
      final p = profiles.first;
      best = TopResultEntity(
        id: p.id,
        type: TopResultType.profile,
        title: p.username,
        subtitle: '${_fmtFollowers(p.followersCount)} Followers',
        artworkUrl: p.avatarUrl,
      );
    }
    return best;
  }

  String _fmtFollowers(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(0)}K';
    return count.toString();
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
