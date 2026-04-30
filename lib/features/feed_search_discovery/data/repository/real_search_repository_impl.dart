import '../../domain/entities/autocomplete_result_entity.dart';
import '../../domain/entities/search_all_result_entity.dart';
import '../../domain/entities/album_result_entity.dart';
import '../../domain/entities/genre_detail_entity.dart';
import '../../domain/entities/search_genre_entity.dart';
import '../../domain/entities/playlist_result_entity.dart';
import '../../domain/entities/profile_result_entity.dart';
import '../../domain/entities/track_result_entity.dart';
import '../../domain/entities/search_filters_entity.dart';
import '../../domain/entities/top_result_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../api/discovery_api.dart';
import '../dto/collection_search_response_dto.dart';
import '../dto/trending_item_dto.dart';
import '../dto/user_search_response_dto.dart';
import '../../presentation/utils/genre_id_mapper.dart';

class RealSearchRepositoryImpl implements SearchRepository {
  RealSearchRepositoryImpl(this._api);

  final DiscoveryApi _api;

  // ── searchAll ─────────────────────────────────────────────────────────────

  @override
  Future<SearchAllResultEntity> searchAll(String query) async {
    final dto = await _api.search(q: query, page: 1, limit: 20);

    final tracks = <TrackResultEntity>[];
    final playlists = <PlaylistResultEntity>[];
    final albums = <AlbumResultEntity>[];
    final profiles = <ProfileResultEntity>[];

    for (final item in dto.items) {
      if (item.track != null) {
        final t = item.track!;
        tracks.add(
          TrackResultEntity(
            id: t.id,
            title: t.title,
            artistName: t.artist,
            artworkUrl: t.coverUrl,
            durationSeconds: t.durationSeconds,
            playCount: _formatCount(t.playsCount),
          ),
        );
      } else if (item.collection != null) {
        final c = item.collection!;
        if (c.type == 'album') {
          albums.add(
            AlbumResultEntity(
              id: c.id,
              title: c.title,
              artistName: c.artist,
              artworkUrl: c.coverUrl,
              trackCount: c.trackPreview.length,
            ),
          );
        } else {
          playlists.add(
            PlaylistResultEntity(
              id: c.id,
              title: c.title,
              creatorId: '',
              creatorName: c.artist,
              artworkUrl: c.coverUrl,
              trackCount: c.trackPreview.length,
            ),
          );
        }
      } else if (item.user != null) {
        final u = item.user!;
        profiles.add(
          ProfileResultEntity(
            id: u.id,
            username: u.username,
            displayName: u.displayName,
            avatarUrl: u.avatarUrl,
            location: u.location,
            followersCount: u.followersCount,
            isCertified: u.isCertified,
            isFollowing: u.isFollowing ?? false,
          ),
        );
      }
    }

    TopResultEntity? topResult;
    if (tracks.isNotEmpty) {
      final t = tracks.first;
      topResult = TopResultEntity(
        id: t.id,
        type: TopResultType.track,
        title: t.title,
        subtitle: t.artistName,
        artworkUrl: t.artworkUrl,
      );
    } else if (profiles.isNotEmpty) {
      final p = profiles.first;
      topResult = TopResultEntity(
        id: p.id,
        type: TopResultType.profile,
        title: p.displayLabel,
        subtitle: _formatFollowers(p.followersCount),
        artworkUrl: p.avatarUrl,
      );
    }

    return SearchAllResultEntity(
      topResult: topResult,
      tracks: tracks,
      playlists: playlists,
      albums: albums,
      profiles: profiles,
    );
  }

  // ── searchAutocomplete ────────────────────────────────────────────────────

  @override
  Future<AutocompleteResultEntity> searchAutocomplete(String query) async {
    final dto = await _api.searchAutocomplete(q: query);
    return AutocompleteResultEntity(
      tracks: dto.tracks
          .map(
            (t) => AutocompleteTrackEntity(
              id: t.id,
              title: t.title,
              artist: t.artist,
            ),
          )
          .toList(),
      users: dto.users
          .map(
            (u) => AutocompleteUserEntity(
              id: u.id,
              username: u.username,
              displayName: u.displayName,
            ),
          )
          .toList(),
      collections: dto.collections
          .map(
            (c) => AutocompleteCollectionEntity(
              id: c.id,
              title: c.title,
              artist: c.artist,
            ),
          )
          .toList(),
    );
  }

  // ── searchTracks ──────────────────────────────────────────────────────────

  @override
  Future<List<TrackResultEntity>> searchTracks(
    String query, {
    int page = 1,
    int limit = 20,
    TrackSearchFilters filters = const TrackSearchFilters(),
  }) async {
    final dto = await _api.searchTracks(
      q: query,
      page: page,
      limit: limit,
      tag: filters.tag,
      timeAdded: filters.timeAdded?.apiValue,
      duration: filters.duration?.apiValue,
      toListen: filters.toListen?.apiValue,
      allowDownloads: filters.allowDownloads,
    );
    return dto.items
        .map(
          (t) => TrackResultEntity(
            id: t.trackId,
            title: t.title,
            artistName: t.artistName,
            artworkUrl: t.coverUrl,
            durationSeconds: t.duration,
            playCount: _formatCount(t.likesCount),
          ),
        )
        .toList();
  }

  // ── searchProfiles ────────────────────────────────────────────────────────

  @override
  Future<List<ProfileResultEntity>> searchProfiles(
    String query, {
    int page = 1,
    int limit = 20,
    PeopleSearchFilters filters = const PeopleSearchFilters(),
  }) async {
    final dto = await _api.searchPeople(
      q: query,
      page: page,
      limit: limit,
      location: filters.location,
      minFollowers: filters.minFollowers,
      verifiedOnly: filters.verifiedOnly,
    );
    return dto.items
        .map(
          (u) => ProfileResultEntity(
            id: u.id,
            username: u.username,
            avatarUrl: u.avatarUrl,
            location: u.location,
            followersCount: u.followersCount,
            isCertified: u.isCertified,
            isFollowing: u.isFollowing,
          ),
        )
        .toList();
  }

  // ── searchPlaylists ───────────────────────────────────────────────────────

  @override
  Future<List<PlaylistResultEntity>> searchPlaylists(
    String query, {
    int page = 1,
    int limit = 20,
    CollectionSearchFilters filters = const CollectionSearchFilters(),
  }) async {
    final dto = await _api.searchCollections(
      q: query,
      page: page,
      limit: limit,
      tag: filters.tag,
    );
    return dto.items
        .where((c) => c.type.name == 'playlist')
        .map(
          (c) => PlaylistResultEntity(
            id: c.id,
            title: c.title,
            creatorId: c.creatorId,
            creatorName: c.creatorName,
            artworkUrl: c.coverUrl,
            trackCount: c.trackCount,
          ),
        )
        .toList();
  }

  // ── searchAlbums ──────────────────────────────────────────────────────────

  @override
  Future<List<AlbumResultEntity>> searchAlbums(
    String query, {
    int page = 1,
    int limit = 20,
    CollectionSearchFilters filters = const CollectionSearchFilters(),
  }) async {
    final dto = await _api.searchCollections(
      q: query,
      page: page,
      limit: limit,
      tag: filters.tag,
    );
    return dto.items
        .where((c) => c.type.name == 'album')
        .map(
          (c) => AlbumResultEntity(
            id: c.id,
            title: c.title,
            artistName: c.creatorName,
            artworkUrl: c.coverUrl,
            trackCount: c.trackCount,
          ),
        )
        .toList();
  }

  // ── getGenres ─────────────────────────────────────────────────────────────
  @override
  Future<List<SearchGenreEntity>> getGenres() async {
    return const [
      // ── Left column ────────────────────────────────────────────────────────
      SearchGenreEntity(
        id: 'hip_hop_rap',
        label: 'Hip Hop & Rap',
        colorValue: 0xFFA259FF,
      ),
      SearchGenreEntity(id: 'pop', label: 'Pop', colorValue: 0xFFFFD60A),
      SearchGenreEntity(id: 'chill', label: 'Chill', colorValue: 0xFF0FA3B1),
      SearchGenreEntity(
        id: 'workout',
        label: 'Workout',
        colorValue: 0xFF10A674,
      ),
      SearchGenreEntity(id: 'house', label: 'House', colorValue: 0xFFFF4FA3),
      SearchGenreEntity(
        id: 'at_home',
        label: 'At Home',
        colorValue: 0xFFA259FF,
      ),
      SearchGenreEntity(id: 'study', label: 'Study', colorValue: 0xFFFF4FA3),
      SearchGenreEntity(id: 'indie', label: 'Indie', colorValue: 0xFF2D6CDF),
      SearchGenreEntity(
        id: 'country',
        label: 'Country',
        colorValue: 0xFFFF8C42,
      ),
      SearchGenreEntity(id: 'rock', label: 'Rock', colorValue: 0xFFFF3D2E),
      SearchGenreEntity(
        id: 'ambient',
        label: 'Ambient',
        colorValue: 0xFF5E8C9E,
      ),
      SearchGenreEntity(
        id: 'classical',
        label: 'Classical',
        colorValue: 0xFF8B5CF6,
      ),
      // ── Right column ───────────────────────────────────────────────────────
      SearchGenreEntity(
        id: 'electronic',
        label: 'Electronic',
        colorValue: 0xFFFF4FA3,
      ),
      SearchGenreEntity(id: 'rnb', label: 'R&B', colorValue: 0xFF0FA3B1),
      SearchGenreEntity(id: 'party', label: 'Party', colorValue: 0xFFFF8C42),
      SearchGenreEntity(id: 'techno', label: 'Techno', colorValue: 0xFFFF4FA3),
      SearchGenreEntity(
        id: 'dance_edm',
        label: 'Dance & EDM',
        colorValue: 0xFF00B8D9,
      ),
      SearchGenreEntity(
        id: 'dancehall',
        label: 'Dancehall',
        colorValue: 0xFFFF6B35,
      ),
      SearchGenreEntity(
        id: 'feel_good',
        label: 'Feel Good',
        colorValue: 0xFFFFD60A,
      ),
      SearchGenreEntity(
        id: 'healing_era',
        label: 'Healing Era',
        colorValue: 0xFF2D6CDF,
      ),
      SearchGenreEntity(id: 'folk', label: 'Folk', colorValue: 0xFFFF8C42),
      SearchGenreEntity(id: 'soul', label: 'Soul', colorValue: 0xFF0FA3B1),
      SearchGenreEntity(id: 'latin', label: 'Latin', colorValue: 0xFFD94FFF),
    ];
  }

  @override
  Future<GenreDetailEntity> getGenreDetail(String genreId) async {
    final backendUuid = GenreIdMapper.getId(genreId);
    final hasUuid = backendUuid.isNotEmpty;
    // Convert short id → human label for use as search keyword.
    final label = _shortIdToLabel(genreId);

    final results = await Future.wait([
      _api.getTrending(
        type: 'track',
        period: 'week',
        genreId: hasUuid ? backendUuid : null,
      ),
      // FIX: q must not be empty — use the genre label as the search keyword.
      // The UUID is passed as tag so backend genre-filters correctly.
      _api.searchCollections(
        q: label,
        tag: hasUuid ? backendUuid : null,
        limit: 10,
      ),
      _api.searchPeople(q: label, limit: 6),
    ]);

    final trendingDto = results[0] as PaginatedTrendingResponseDto;
    final collectionDto = results[1] as CollectionSearchResponseDto;
    final profileDto = results[2] as UserSearchResponseDto;

    final allTracks = trendingDto.items
        .map(
          (i) => TrackResultEntity(
            id: i.id,
            title: i.name,
            artistName: i.artist,
            artworkUrl: i.coverUrl,
            // TrendingItemDto has no durationSeconds — UI hides timer for 0.
            durationSeconds: 0,
            // FIX: score is non-nullable int — convert directly.
            playCount: i.score.toString(),
          ),
        )
        .toList();

    final half = (allTracks.length / 2).ceil();
    final trendingTracks = allTracks.take(half).toList();
    final introducingTracks = allTracks.skip(half).toList();

    final playlists = collectionDto.items
        .where((c) => c.type.name == 'playlist')
        .map(
          (c) => PlaylistResultEntity(
            id: c.id,
            title: c.title,
            creatorId: c.creatorId,
            creatorName: c.creatorName,
            artworkUrl: c.coverUrl,
            trackCount: c.trackCount,
          ),
        )
        .toList();

    final albums = collectionDto.items
        .where((c) => c.type.name == 'album')
        .map(
          (c) => AlbumResultEntity(
            id: c.id,
            title: c.title,
            artistName: c.creatorName,
            artworkUrl: c.coverUrl,
            trackCount: c.trackCount,
          ),
        )
        .toList();

    final profiles = profileDto.items
        .map(
          (u) => ProfileResultEntity(
            id: u.id,
            username: u.username,
            avatarUrl: u.avatarUrl,
            location: u.location,
            followersCount: u.followersCount,
            isCertified: u.isCertified,
            isFollowing: u.isFollowing,
          ),
        )
        .toList();

    return GenreDetailEntity(
      genreId: genreId,
      genreLabel: label,
      trendingTracks: trendingTracks,
      introducingTracks: introducingTracks,
      playlists: playlists,
      albums: albums,
      profiles: profiles,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Converts a short genre id back to a human-readable label for display
  /// and for use as a people-search keyword.
  static const Map<String, String> _shortIdLabels = {
    'hip_hop_rap': 'Hip Hop & Rap',
    'pop': 'Pop',
    'chill': 'Chill',
    'workout': 'Workout',
    'house': 'House',
    'at_home': 'At Home',
    'study': 'Study',
    'indie': 'Indie',
    'country': 'Country',
    'rock': 'Rock',
    'ambient': 'Ambient',
    'classical': 'Classical',
    'electronic': 'Electronic',
    'rnb': 'R&B',
    'party': 'Party',
    'techno': 'Techno',
    'dance_edm': 'Dance & EDM',
    'dancehall': 'Dancehall',
    'feel_good': 'Feel Good',
    'healing_era': 'Healing Era',
    'folk': 'Folk',
    'soul': 'Soul',
    'latin': 'Latin',
  };

  String _shortIdToLabel(String id) => _shortIdLabels[id] ?? id;

  String _formatCount(int? n) {
    if (n == null || n == 0) return '0';
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }

  String _formatFollowers(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M followers';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K followers';
    return '$n followers';
  }
}
