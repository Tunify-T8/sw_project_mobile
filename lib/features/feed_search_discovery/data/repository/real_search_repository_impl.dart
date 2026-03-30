// lib/features/feed_search_discovery/data/repository/real_search_repository_impl.dart

import '../../domain/entities/resource_type.dart';
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
import '../dto/track_preview_dto.dart';
import '../dto/collection_dto.dart';
import '../dto/user_preview_dto.dart';

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
      switch (item.itemType) {
        case ResourceType.track:
          if (item.track != null) {
            tracks.add(_trackDtoToEntity(item.track!));
          }
          break;
        case ResourceType.collection:
          if (item.collection != null) {
            final c = item.collection!;
            if (c.type.name == 'album') {
              albums.add(_albumDtoToEntity(c));
            } else {
              playlists.add(_playlistDtoToEntity(c));
            }
          }
          break;
        case ResourceType.user:
          if (item.user != null) {
            profiles.add(_userDtoToEntity(item.user!));
          }
          break;
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
    );
    return dto.items.map(_trackDtoToEntity).toList();
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
        .map(_playlistDtoToEntity)
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
        .map(_albumDtoToEntity)
        .toList();
  }

  @override
  Future<List<SearchGenreEntity>> getGenres() async {
    return const [
      SearchGenreEntity(
        id: 'hip_hop_rap',
        label: 'Hip Hop & Rap',
        colorValue: 0xFF6B2D8B,
      ),
      SearchGenreEntity(
        id: 'electronic',
        label: 'Electronic',
        colorValue: 0xFF1A6B8A,
      ),
      SearchGenreEntity(id: 'pop', label: 'Pop', colorValue: 0xFF8B2D6B),
      SearchGenreEntity(id: 'rnb', label: 'R&B', colorValue: 0xFF2D6B8B),
      SearchGenreEntity(id: 'party', label: 'Party', colorValue: 0xFF8B6B2D),
      SearchGenreEntity(id: 'chill', label: 'Chill', colorValue: 0xFF2D8B6B),
      SearchGenreEntity(
        id: 'workout',
        label: 'Workout',
        colorValue: 0xFF8B2D2D,
      ),
      SearchGenreEntity(id: 'techno', label: 'Techno', colorValue: 0xFF3D3D8B),
      SearchGenreEntity(id: 'indie', label: 'Indie', colorValue: 0xFF6B8B2D),
      SearchGenreEntity(id: 'house', label: 'House', colorValue: 0xFF8B4A2D),
      SearchGenreEntity(id: 'soul', label: 'Soul', colorValue: 0xFF5A2D8B),
      SearchGenreEntity(id: 'folk', label: 'Folk', colorValue: 0xFF4A6B2D),
    ];
  }

  @override
  Future<GenreDetailEntity> getGenreDetail(String genreId) async {
    final results = await Future.wait([
      _api.getTrending(type: 'track', since: 'week', limit: 10),
      _api.searchCollections(q: '', tag: genreId, limit: 10),
      _api.searchPeople(q: genreId, limit: 6),
    ]);

    final trendingDto = results[0] as dynamic;
    final playlistDto = results[1] as dynamic;
    final profileDto = results[2] as dynamic;

    final trendingTracks = (trendingDto.items as List)
        .where((i) => i.itemType == ResourceType.track && i.track != null)
        .map<TrackResultEntity>((i) => _trackDtoToEntity(i.track!))
        .toList();

    final playlists = (playlistDto.items as List)
        .where((c) => c.type.name == 'playlist')
        .map<PlaylistResultEntity>((c) => _playlistDtoToEntity(c))
        .toList();

    final profiles = (profileDto.items as List)
        .map<ProfileResultEntity>((u) => _userDtoToEntity(u))
        .toList();

    return GenreDetailEntity(
      genreId: genreId,
      genreLabel: _genreLabelFromId(genreId),
      trendingTracks: trendingTracks,
      introducingTracks: const [],
      playlists: playlists,
      profiles: profiles,
      albums: const [],
    );
  }

  // ─── Mappers ───────────────────────────────────────────────────────────────

  TrackResultEntity _trackDtoToEntity(TrackPreviewDto dto) => TrackResultEntity(
    id: dto.trackId,
    title: dto.title,
    artistName: dto.artistName,
    artworkUrl: dto.coverUrl,
    durationSeconds: dto.duration,
    playCount: _formatPlayCount(dto.likesCount),
  );

  PlaylistResultEntity _playlistDtoToEntity(CollectionDto dto) =>
      PlaylistResultEntity(
        id: dto.id,
        title: dto.title,
        creatorName: dto.creatorName,
        artworkUrl: dto.coverUrl,
        trackCount: dto.trackCount,
      );

  AlbumResultEntity _albumDtoToEntity(CollectionDto dto) => AlbumResultEntity(
    id: dto.id,
    title: dto.title,
    artistName: dto.creatorName,
    artworkUrl: dto.coverUrl,
    trackCount: dto.trackCount,
    releaseYear: dto.releaseYear,
  );

  ProfileResultEntity _userDtoToEntity(UserPreviewDto dto) =>
      ProfileResultEntity(
        id: dto.id,
        username: dto.username,
        avatarUrl: dto.avatarUrl,
        location: dto.location,
        followersCount: dto.followersCount,
        isVerified: dto.verified,
        isFollowing: dto.isFollowing,
      );

  String? _formatPlayCount(int? count) {
    if (count == null) {
      return null;
    }
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatFollowers(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M Followers';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}K Followers';
    }
    return '$count Followers';
  }

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
}
