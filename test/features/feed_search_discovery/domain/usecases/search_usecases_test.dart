import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/album_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/genre_detail_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/playlist_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/profile_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/search_all_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/search_filters_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/search_genre_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/repositories/search_repository.dart';
import 'package:software_project/features/feed_search_discovery/domain/usecases/search_usecases.dart';

import 'search_usecases_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SearchRepository>()])
void main() {
  late MockSearchRepository repository;

  setUp(() {
    repository = MockSearchRepository();
  });

  test('SearchAllUseCase forwards query', () async {
    const result = SearchAllResultEntity();
    when(repository.searchAll('don')).thenAnswer((_) async => result);

    final value = await SearchAllUseCase(repository)('don');

    expect(value, result);
    verify(repository.searchAll('don')).called(1);
  });

  test('SearchTracksUseCase forwards paging and filters', () async {
    const filters = TrackSearchFilters(tag: 'rock');
    const result = [TrackResultEntity(id: '1', title: 'Song', artistName: 'A', durationSeconds: 10)];
    when(
      repository.searchTracks('don', page: 2, limit: 5, filters: filters),
    ).thenAnswer((_) async => result);

    final value = await SearchTracksUseCase(repository)(
      'don',
      page: 2,
      limit: 5,
      filters: filters,
    );

    expect(value, result);
    verify(repository.searchTracks('don', page: 2, limit: 5, filters: filters))
        .called(1);
  });

  test('SearchProfilesUseCase forwards paging and people filters', () async {
    const filters = PeopleSearchFilters(location: 'Cairo');
    const result = [ProfileResultEntity(id: '1', username: 'User', followersCount: 1)];
    when(
      repository.searchProfiles('don', page: 3, limit: 6, filters: filters),
    ).thenAnswer((_) async => result);

    final value = await SearchProfilesUseCase(repository)(
      'don',
      page: 3,
      limit: 6,
      filters: filters,
    );

    expect(value, result);
    verify(
      repository.searchProfiles('don', page: 3, limit: 6, filters: filters),
    ).called(1);
  });

  test('SearchPlaylistsUseCase forwards paging and collection filters', () async {
    const filters = CollectionSearchFilters(tag: 'party');
    const result = [PlaylistResultEntity(id: '1', title: 'Mix', creatorName: 'DJ', trackCount: 4)];
    when(
      repository.searchPlaylists('mix', page: 4, limit: 7, filters: filters),
    ).thenAnswer((_) async => result);

    final value = await SearchPlaylistsUseCase(repository)(
      'mix',
      page: 4,
      limit: 7,
      filters: filters,
    );

    expect(value, result);
    verify(
      repository.searchPlaylists('mix', page: 4, limit: 7, filters: filters),
    ).called(1);
  });

  test('SearchAlbumsUseCase forwards paging and collection filters', () async {
    const filters = CollectionSearchFilters(type: CollectionFilterType.album);
    const result = [AlbumResultEntity(id: '1', title: 'Album', artistName: 'A', trackCount: 3)];
    when(
      repository.searchAlbums('mix', page: 5, limit: 8, filters: filters),
    ).thenAnswer((_) async => result);

    final value = await SearchAlbumsUseCase(repository)(
      'mix',
      page: 5,
      limit: 8,
      filters: filters,
    );

    expect(value, result);
    verify(
      repository.searchAlbums('mix', page: 5, limit: 8, filters: filters),
    ).called(1);
  });

  test('GetGenresUseCase forwards to repository', () async {
    const result = [SearchGenreEntity(id: 'pop', label: 'Pop', colorValue: 1)];
    when(repository.getGenres()).thenAnswer((_) async => result);

    final value = await GetGenresUseCase(repository)();

    expect(value, result);
    verify(repository.getGenres()).called(1);
  });

  test('GetGenreDetailUseCase forwards genre id', () async {
    const result = GenreDetailEntity(genreId: 'pop', genreLabel: 'Pop');
    when(repository.getGenreDetail('pop')).thenAnswer((_) async => result);

    final value = await GetGenreDetailUseCase(repository)('pop');

    expect(value, result);
    verify(repository.getGenreDetail('pop')).called(1);
  });
}
