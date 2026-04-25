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
import '../dto/collection_dto.dart';
import '../dto/user_preview_dto.dart';
import '../dto/collection_search_response_dto.dart';
import '../dto/user_search_response_dto.dart';
import '../dto/trending_item_dto.dart';
import '../dto/track_search_response_dto.dart';

class RealSearchRepositoryImpl implements SearchRepository {
  RealSearchRepositoryImpl(this._api);

  final DiscoveryApi _api;

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
        title: p.username,
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
      sort: filters.sort.apiValue,
    );
    return dto.items.map(_userDtoToEntity).toList();
  }

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
        .map(_collectionDtoToPlaylist)
        .toList();
  }

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
        .map(_collectionDtoToAlbum)
        .toList();
  }

  // ── Genre list ─────────────────────────────────────────────────────────────
  @override
  Future<List<SearchGenreEntity>> getGenres() async {
    return const [
      SearchGenreEntity(
        id: 'hip_hop_rap',
        label: 'Hip Hop & Rap',
        colorValue: 0xFFA259FF,
        imageAsset: 'assets/genres/hip_hop_rap.jpg',
      ),
      SearchGenreEntity(
        id: 'pop',
        label: 'Pop',
        colorValue: 0xFFFFD60A,
        imageAsset: 'assets/genres/pop.jpg',
      ),
      SearchGenreEntity(
        id: 'chill',
        label: 'Chill',
        colorValue: 0xFF0FA3B1,
        imageAsset: 'assets/genres/chill.jpg',
      ),
      SearchGenreEntity(
        id: 'workout',
        label: 'Workout',
        colorValue: 0xFF10A674,
        imageAsset: 'assets/genres/workout.jpg',
      ),
      SearchGenreEntity(
        id: 'house',
        label: 'House',
        colorValue: 0xFFFF4FA3,
        imageAsset: 'assets/genres/house.jpg',
      ),
      SearchGenreEntity(
        id: 'indie',
        label: 'Indie',
        colorValue: 0xFF2D6CDF,
        imageAsset: 'assets/genres/indie.jpg',
      ),
      SearchGenreEntity(
        id: 'electronic',
        label: 'Electronic',
        colorValue: 0xFFFF4FA3,
        imageAsset: 'assets/genres/electronic.jpg',
      ),
      SearchGenreEntity(
        id: 'rnb',
        label: 'R&B',
        colorValue: 0xFF0FA3B1,
        imageAsset: 'assets/genres/rnb.jpg',
      ),
      SearchGenreEntity(
        id: 'party',
        label: 'Party',
        colorValue: 0xFFFF8C42,
        imageAsset: 'assets/genres/party.jpg',
      ),
      SearchGenreEntity(
        id: 'techno',
        label: 'Techno',
        colorValue: 0xFFFF4FA3,
        imageAsset: 'assets/genres/techno.jpg',
      ),
      SearchGenreEntity(
        id: 'folk',
        label: 'Folk',
        colorValue: 0xFFFF8C42,
        imageAsset: 'assets/genres/folk.jpg',
      ),
      SearchGenreEntity(
        id: 'soul',
        label: 'Soul',
        colorValue: 0xFF0FA3B1,
        imageAsset: 'assets/genres/soul.jpg',
      ),
      SearchGenreEntity(
        id: 'at_home',
        label: 'At Home',
        colorValue: 0xFFA259FF,
        imageAsset: 'assets/genres/at_home.jpg',
      ),
      SearchGenreEntity(
        id: 'study',
        label: 'Study',
        colorValue: 0xFFFF4FA3,
        imageAsset: 'assets/genres/study.jpg',
      ),
      SearchGenreEntity(
        id: 'country',
        label: 'Country',
        colorValue: 0xFFFF8C42,
        imageAsset: 'assets/genres/country.jpg',
      ),
      SearchGenreEntity(
        id: 'rock',
        label: 'Rock',
        colorValue: 0xFFFF3D2E,
        imageAsset: 'assets/genres/rock.jpg',
      ),
      SearchGenreEntity(
        id: 'feel_good',
        label: 'Feel Good',
        colorValue: 0xFFFFD60A,
        imageAsset: 'assets/genres/feel_good.jpg',
      ),
      SearchGenreEntity(
        id: 'healing_era',
        label: 'Healing Era',
        colorValue: 0xFF2D6CDF,
        imageAsset: 'assets/genres/healing_era.jpg',
      ),
      SearchGenreEntity(
        id: 'latin',
        label: 'Latin',
        colorValue: 0xFFD94FFF,
        imageAsset: 'assets/genres/latin.jpg',
      ),
    ];
  }

  // ── Genre detail ───────────────────────────────────────────────────────────
  //
  // FIX: Now calls getTrending WITH genreId so the correct genre's trending
  // tracks are returned. Previously genreId was omitted, returning global trending.
  @override
  Future<GenreDetailEntity> getGenreDetail(String genreId) async {
    final results = await Future.wait([
      _api.getTrending(type: 'track', period: 'week', genreId: genreId),
      _api.searchCollections(q: genreId, tag: genreId, limit: 10),
      _api.searchPeople(q: genreId, limit: 6),
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
            durationSeconds: 0, // backend does not return duration on trending
            playCount: _formatCount(i.score),
          ),
        )
        .toList();

    // First half → trending section; second half → introducing / discover more
    final half = (allTracks.length / 2).ceil();
    final trendingTracks = allTracks.take(half).toList();
    final introducingTracks = allTracks.skip(half).toList();

    final playlists = collectionDto.items
        .where((c) => c.type.name == 'playlist')
        .map(_collectionDtoToPlaylist)
        .toList();

    final albums = collectionDto.items
        .where((c) => c.type.name == 'album')
        .map(_collectionDtoToAlbum)
        .toList();

    final profiles = profileDto.items.map(_userDtoToEntity).toList();

    return GenreDetailEntity(
      genreId: genreId,
      genreLabel: genreId,
      trendingTracks: trendingTracks,
      introducingTracks: introducingTracks,
      playlists: playlists,
      albums: albums,
      profiles: profiles,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  PlaylistResultEntity _collectionDtoToPlaylist(CollectionDto c) {
    return PlaylistResultEntity(
      id: c.id,
      title: c.title,
      creatorName: c.creatorName,
      artworkUrl: c.coverUrl,
      trackCount: c.trackCount,
    );
  }

  AlbumResultEntity _collectionDtoToAlbum(CollectionDto c) {
    return AlbumResultEntity(
      id: c.id,
      title: c.title,
      artistName: c.creatorName,
      artworkUrl: c.coverUrl,
      trackCount: c.trackCount,
    );
  }

  ProfileResultEntity _userDtoToEntity(UserPreviewDto u) {
    return ProfileResultEntity(
      id: u.id,
      username: u.username,
      avatarUrl: u.avatarUrl,
      location: u.location,
      followersCount: u.followersCount,
      isCertified: u.isCertified,
      isFollowing: u.isFollowing,
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String _formatFollowers(int count) {
    if (count >= 1000000)
      return '${(count / 1000000).toStringAsFixed(1)}M followers';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K followers';
    return '$count followers';
  }
}
