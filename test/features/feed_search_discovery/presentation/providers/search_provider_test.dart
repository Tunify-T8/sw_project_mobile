import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:software_project/features/feed_search_discovery/domain/entities/top_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/repositories/search_repository.dart';
import 'package:software_project/features/feed_search_discovery/domain/usecases/search_usecases.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/search_provider.dart';

import 'search_provider_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SearchAllUseCase>(),
  MockSpec<SearchTracksUseCase>(),
  MockSpec<SearchProfilesUseCase>(),
  MockSpec<SearchPlaylistsUseCase>(),
  MockSpec<SearchAlbumsUseCase>(),
  MockSpec<GetGenresUseCase>(),
  MockSpec<GetGenreDetailUseCase>(),
])
void main() {
  late MockSearchAllUseCase mockSearchAllUseCase;
  late MockSearchTracksUseCase mockSearchTracksUseCase;
  late MockSearchProfilesUseCase mockSearchProfilesUseCase;
  late MockSearchPlaylistsUseCase mockSearchPlaylistsUseCase;
  late MockSearchAlbumsUseCase mockSearchAlbumsUseCase;
  late MockGetGenresUseCase mockGetGenresUseCase;
  late MockGetGenreDetailUseCase mockGetGenreDetailUseCase;
  late ProviderContainer container;
  late SearchNotifier notifier;

  const genreRock = SearchGenreEntity(
    id: 'rock',
    label: 'Rock',
    colorValue: 0xFFFF3D2E,
  );
  const genrePop = SearchGenreEntity(
    id: 'pop',
    label: 'Pop',
    colorValue: 0xFFFFD60A,
  );

  const trackOcean = TrackResultEntity(
    id: 'track-ocean',
    title: 'Ocean Drive',
    artistName: 'Duke',
    artworkUrl: 'https://example.com/ocean.jpg',
    durationSeconds: 180,
    playCount: '1.2K',
  );
  const trackDon = TrackResultEntity(
    id: 'track-don',
    title: 'Don Anthem',
    artistName: 'Don Toliver',
    durationSeconds: 210,
    playCount: '9.9K',
  );
  const trackPaged = TrackResultEntity(
    id: 'track-paged',
    title: 'Paged Song',
    artistName: 'Artist',
    durationSeconds: 200,
  );
  const profileDon = ProfileResultEntity(
    id: 'profile-don',
    username: 'Don Toliver',
    avatarUrl: 'https://example.com/don.jpg',
    followersCount: 688000,
    isVerified: true,
  );
  const profileOther = ProfileResultEntity(
    id: 'profile-other',
    username: 'Donna',
    followersCount: 1200,
  );
  const playlistOctane = PlaylistResultEntity(
    id: 'playlist-octane',
    title: 'Octane Mix',
    creatorName: 'DJ Set',
    trackCount: 12,
  );
  const albumOctane = AlbumResultEntity(
    id: 'album-octane',
    title: 'OCTANE',
    artistName: 'Don Toliver',
    trackCount: 18,
    releaseYear: 2026,
  );
  const genreDetail = GenreDetailEntity(
    genreId: 'rock',
    genreLabel: 'Rock',
    trendingTracks: [trackOcean],
    introducingTracks: [trackDon],
    playlists: [playlistOctane],
    profiles: [profileDon],
    albums: [albumOctane],
  );

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        searchAllUseCaseProvider.overrideWithValue(mockSearchAllUseCase),
        searchTracksUseCaseProvider.overrideWithValue(mockSearchTracksUseCase),
        searchProfilesUseCaseProvider.overrideWithValue(
          mockSearchProfilesUseCase,
        ),
        searchPlaylistsUseCaseProvider.overrideWithValue(
          mockSearchPlaylistsUseCase,
        ),
        searchAlbumsUseCaseProvider.overrideWithValue(mockSearchAlbumsUseCase),
        getGenresUseCaseProvider.overrideWithValue(mockGetGenresUseCase),
        getGenreDetailUseCaseProvider.overrideWithValue(
          mockGetGenreDetailUseCase,
        ),
      ],
    );
  }

  Future<void> flush() async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  setUp(() {
    mockSearchAllUseCase = MockSearchAllUseCase();
    mockSearchTracksUseCase = MockSearchTracksUseCase();
    mockSearchProfilesUseCase = MockSearchProfilesUseCase();
    mockSearchPlaylistsUseCase = MockSearchPlaylistsUseCase();
    mockSearchAlbumsUseCase = MockSearchAlbumsUseCase();
    mockGetGenresUseCase = MockGetGenresUseCase();
    mockGetGenreDetailUseCase = MockGetGenreDetailUseCase();

    when(mockGetGenresUseCase()).thenAnswer((_) async => const [genreRock]);

    container = buildContainer();
    notifier = container.read(searchProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('SearchState helpers', () {
    test('hasResults reflects active tab contents and activeTabHasFilters reflects filters', () {
      const state = SearchState(
        activeTab: SearchTab.tracks,
        tracks: [trackOcean],
        trackFilters: TrackSearchFilters(tag: 'rock'),
      );

      expect(state.hasResults, isTrue);
      expect(state.activeTabHasFilters, isTrue);
      expect(
        const SearchState(
          activeTab: SearchTab.all,
          allResult: SearchAllResultEntity(),
        ).hasResults,
        isFalse,
      );
    });

    test('hasResults and activeTabHasFilters cover all remaining tab branches', () {
      expect(
        const SearchState(
          activeTab: SearchTab.all,
          allResult: SearchAllResultEntity(
            topResult: TopResultEntity(
              id: 'top',
              type: TopResultType.track,
              title: 'Top',
              subtitle: 'Artist',
            ),
          ),
        ).hasResults,
        isTrue,
      );
      expect(
        const SearchState(
          activeTab: SearchTab.profiles,
          profiles: [profileDon],
          peopleFilters: PeopleSearchFilters(location: 'Cairo'),
        ).hasResults,
        isTrue,
      );
      expect(
        const SearchState(
          activeTab: SearchTab.playlists,
          playlists: [playlistOctane],
          collectionFilters: CollectionSearchFilters(tag: 'party'),
        ).hasResults,
        isTrue,
      );
      expect(
        const SearchState(
          activeTab: SearchTab.albums,
          albums: [albumOctane],
          collectionFilters: CollectionSearchFilters(tag: 'party'),
        ).hasResults,
        isTrue,
      );
      expect(
        const SearchState(
          activeTab: SearchTab.profiles,
          peopleFilters: PeopleSearchFilters(location: 'Cairo'),
        ).activeTabHasFilters,
        isTrue,
      );
      expect(
        const SearchState(
          activeTab: SearchTab.playlists,
          collectionFilters: CollectionSearchFilters(tag: 'party'),
        ).activeTabHasFilters,
        isTrue,
      );
      expect(
        const SearchState(
          activeTab: SearchTab.all,
          trackFilters: TrackSearchFilters(tag: 'ignored'),
        ).activeTabHasFilters,
        isFalse,
      );
    });
  });

  group('initialization', () {
    test('loads genres on build successfully', () async {
      await flush();

      final state = container.read(searchProvider);
      expect(state.genres, const [genreRock]);
      expect(state.isLoadingGenres, isFalse);
      verify(mockGetGenresUseCase()).called(1);
    });

    test('swallows genre loading errors and clears loading flag', () async {
      container.dispose();
      mockGetGenresUseCase = MockGetGenresUseCase();
      when(mockGetGenresUseCase()).thenThrow(Exception('genres failed'));
      container = buildContainer();
      notifier = container.read(searchProvider.notifier);

      await flush();

      final state = container.read(searchProvider);
      expect(state.genres, isEmpty);
      expect(state.isLoadingGenres, isFalse);
      verify(mockGetGenresUseCase()).called(1);
    });
  });

  group('provider wiring', () {
    test('default repository and use case providers build from the mock repository path', () {
      final defaultContainer = ProviderContainer();
      addTearDown(defaultContainer.dispose);

      expect(defaultContainer.read(searchRepositoryProvider), isA<SearchRepository>());
      expect(defaultContainer.read(searchAllUseCaseProvider), isA<SearchAllUseCase>());
      expect(defaultContainer.read(searchTracksUseCaseProvider), isA<SearchTracksUseCase>());
      expect(defaultContainer.read(searchProfilesUseCaseProvider), isA<SearchProfilesUseCase>());
      expect(defaultContainer.read(searchPlaylistsUseCaseProvider), isA<SearchPlaylistsUseCase>());
      expect(defaultContainer.read(searchAlbumsUseCaseProvider), isA<SearchAlbumsUseCase>());
      expect(defaultContainer.read(getGenresUseCaseProvider), isA<GetGenresUseCase>());
      expect(defaultContainer.read(getGenreDetailUseCaseProvider), isA<GetGenreDetailUseCase>());
    });
  });

  group('search box interactions', () {
    test('onSearchFocused only switches idle mode to typing', () async {
      await flush();

      notifier.onSearchFocused();
      expect(container.read(searchProvider).mode, SearchScreenMode.typing);

      notifier.state = notifier.state.copyWith(mode: SearchScreenMode.results);
      notifier.onSearchFocused();
      expect(container.read(searchProvider).mode, SearchScreenMode.results);
    });

    test('onQueryChanged updates query, enters typing mode, and builds suggestions from state and pool', () async {
      await flush();
      notifier.state = notifier.state.copyWith(
        tracks: const [trackDon],
        profiles: const [profileDon],
        albums: const [albumOctane],
        playlists: const [playlistOctane],
      );

      notifier.onQueryChanged('do');

      final state = container.read(searchProvider);
      expect(state.query, 'do');
      expect(state.mode, SearchScreenMode.typing);
      expect(state.typingSuggestions, contains('Don Anthem'));
      expect(state.typingSuggestions, contains('Don Toliver'));
      expect(state.typingSuggestions.length, lessThanOrEqualTo(8));
    });

    test('onQueryChanged includes partial matches after exact suggestions', () async {
      await flush();
      notifier.state = notifier.state.copyWith(
        tracks: const [
          TrackResultEntity(
            id: 'track-partial',
            title: 'The Octane Story',
            artistName: 'Artist',
            durationSeconds: 180,
          ),
        ],
      );

      notifier.onQueryChanged('tan');

      expect(container.read(searchProvider).typingSuggestions, contains('The Octane Story'));
    });

    test('onQueryChanged clears suggestions for short queries', () async {
      await flush();
      notifier.state = notifier.state.copyWith(
        typingSuggestions: const ['existing'],
      );

      notifier.onQueryChanged('d');

      final state = container.read(searchProvider);
      expect(state.query, 'd');
      expect(state.typingSuggestions, isEmpty);
      expect(state.mode, SearchScreenMode.typing);
    });

    test('onQuerySubmitted ignores empty trimmed query', () async {
      await flush();

      await notifier.onQuerySubmitted('   ');

      expect(container.read(searchProvider).query, '');
      verifyNever(mockSearchAllUseCase(any));
    });

    test('onQuerySubmitted loads all-tab results, rescored top result, and records recents', () async {
      await flush();
      const rawResult = SearchAllResultEntity(
        topResult: TopResultEntity(
          id: 'profile-other',
          type: TopResultType.profile,
          title: 'Someone Else',
          subtitle: '5 Followers',
        ),
        tracks: [trackOcean],
        playlists: [playlistOctane],
        profiles: [profileDon],
        albums: [albumOctane],
      );

      when(mockSearchAllUseCase('octane')).thenAnswer((_) async => rawResult);

      await notifier.onQuerySubmitted('  octane  ');

      final state = container.read(searchProvider);
      expect(state.query, 'octane');
      expect(state.mode, SearchScreenMode.results);
      expect(state.activeTab, SearchTab.all);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.allResult?.topResult?.type, TopResultType.album);
      expect(state.allResult?.topResult?.id, albumOctane.id);
      expect(state.recentSearches.first, 'octane');
      expect(state.recentResults.first.kind, RecentResultKind.track);
      expect(state.recentResults.first.id, trackOcean.id);
      expect(state.recentResults[1].kind, RecentResultKind.album);
      expect(state.recentResults[1].id, albumOctane.id);
      verify(mockSearchAllUseCase('octane')).called(1);
    });

    test('onQuerySubmitted stores friendly error on failure', () async {
      await flush();
      when(mockSearchAllUseCase('broken')).thenThrow(Exception('boom'));

      await notifier.onQuerySubmitted('broken');

      final state = container.read(searchProvider);
      expect(state.mode, SearchScreenMode.results);
      expect(state.isLoading, isFalse);
      expect(state.error, 'Search failed. Please try again.');
      verify(mockSearchAllUseCase('broken')).called(1);
    });

    test('onQuerySubmitted records only the top profile when no playable result exists', () async {
      await flush();
      const rawResult = SearchAllResultEntity(
        profiles: [profileDon],
      );
      when(
        mockSearchAllUseCase('don toliver'),
      ).thenAnswer((_) async => rawResult);

      await notifier.onQuerySubmitted('don toliver');

      final state = container.read(searchProvider);
      expect(state.allResult?.topResult?.type, TopResultType.profile);
      expect(state.recentResults, hasLength(1));
      expect(state.recentResults.single.kind, RecentResultKind.profile);
      expect(state.recentResults.single.id, profileDon.id);
    });

    test('onQuerySubmitted preserves original top result when rescoring finds no better match', () async {
      await flush();
      const rawResult = SearchAllResultEntity(
        topResult: TopResultEntity(
          id: 'raw-top',
          type: TopResultType.track,
          title: 'Fallback Top',
          subtitle: 'Original Artist',
        ),
      );
      when(mockSearchAllUseCase('zzz')).thenAnswer((_) async => rawResult);

      await notifier.onQuerySubmitted('zzz');

      final state = container.read(searchProvider);
      expect(state.allResult?.topResult?.id, 'raw-top');
      expect(state.recentResults.single.kind, RecentResultKind.track);
      expect(state.recentResults.single.id, 'raw-top');
    });

    test('onQuerySubmitted rescales playlist results and records playlist as recently played', () async {
      await flush();
      const rawResult = SearchAllResultEntity(
        playlists: [playlistOctane],
      );
      when(
        mockSearchAllUseCase('octane mix'),
      ).thenAnswer((_) async => rawResult);

      await notifier.onQuerySubmitted('octane mix');

      final state = container.read(searchProvider);
      expect(state.allResult?.topResult?.type, TopResultType.playlist);
      expect(state.allResult?.topResult?.id, playlistOctane.id);
      expect(state.recentResults, hasLength(1));
      expect(state.recentResults.single.kind, RecentResultKind.playlist);
      expect(state.recentResults.single.id, playlistOctane.id);
    });

    test('onQuerySubmitted rescales track results and album-only results into recent items', () async {
      await flush();
      const trackOnly = SearchAllResultEntity(tracks: [trackOcean]);
      const albumOnly = SearchAllResultEntity(albums: [albumOctane]);
      when(mockSearchAllUseCase('ocean drive')).thenAnswer((_) async => trackOnly);
      when(mockSearchAllUseCase('octane')).thenAnswer((_) async => albumOnly);

      await notifier.onQuerySubmitted('ocean drive');
      expect(container.read(searchProvider).allResult?.topResult?.type, TopResultType.track);
      expect(container.read(searchProvider).recentResults.first.kind, RecentResultKind.track);

      await notifier.onQuerySubmitted('octane');
      expect(container.read(searchProvider).allResult?.topResult?.type, TopResultType.album);
      expect(container.read(searchProvider).recentResults.first.kind, RecentResultKind.album);
      expect(container.read(searchProvider).recentResults.first.id, albumOctane.id);
    });

    test('onSearchCleared resets results but stays in typing mode', () async {
      await flush();
      notifier.state = notifier.state.copyWith(
        query: 'rock',
        mode: SearchScreenMode.results,
        allResult: const SearchAllResultEntity(tracks: [trackOcean]),
        tracks: const [trackOcean],
        profiles: const [profileDon],
        playlists: const [playlistOctane],
        albums: const [albumOctane],
        error: 'old error',
        typingSuggestions: const ['rock'],
      );

      notifier.onSearchCleared();

      final state = container.read(searchProvider);
      expect(state.query, '');
      expect(state.mode, SearchScreenMode.typing);
      expect(state.typingSuggestions, isEmpty);
      expect(state.allResult, isNull);
      expect(state.tracks, isEmpty);
      expect(state.profiles, isEmpty);
      expect(state.playlists, isEmpty);
      expect(state.albums, isEmpty);
      expect(state.error, isNull);
    });

    test('onSearchDismissed moves results to typing then typing to idle', () async {
      await flush();
      notifier.state = notifier.state.copyWith(
        mode: SearchScreenMode.results,
        error: 'old',
      );

      notifier.onSearchDismissed();
      expect(container.read(searchProvider).mode, SearchScreenMode.typing);
      expect(container.read(searchProvider).error, isNull);

      notifier.onSearchDismissed();
      final state = container.read(searchProvider);
      expect(state.mode, SearchScreenMode.idle);
      expect(state.query, '');
      expect(state.typingSuggestions, isEmpty);
    });
  });

  group('tabs, filters, and pagination', () {
    test('setActiveTab does nothing for same tab or blank query', () async {
      await flush();
      await notifier.setActiveTab(SearchTab.all);
      verifyNever(mockSearchAllUseCase(any));

      notifier.state = notifier.state.copyWith(query: '');
      await notifier.setActiveTab(SearchTab.tracks);
      verifyNever(mockSearchTracksUseCase(any));
    });

    test('setActiveTab loads track results and forwards filters', () async {
      await flush();
      const filters = TrackSearchFilters(tag: 'hip hop');
      notifier.state = notifier.state.copyWith(
        query: 'don',
        mode: SearchScreenMode.results,
        trackFilters: filters,
      );
      when(
        mockSearchTracksUseCase(
          'don',
          page: 1,
          limit: 20,
          filters: filters,
        ),
      ).thenAnswer((_) async => const [trackDon]);

      await notifier.setActiveTab(SearchTab.tracks);

      final state = container.read(searchProvider);
      expect(state.activeTab, SearchTab.tracks);
      expect(state.tracks, const [trackDon]);
      expect(state.hasMore, isFalse);
      expect(state.isLoading, isFalse);
      verify(
        mockSearchTracksUseCase(
          'don',
          page: 1,
          limit: 20,
          filters: filters,
        ),
      ).called(1);
    });

    test('setActiveTab loads profiles, playlists, and albums through their use cases', () async {
      await flush();
      notifier.state = notifier.state.copyWith(
        query: 'don',
        mode: SearchScreenMode.results,
      );
      when(
        mockSearchProfilesUseCase(
          'don',
          page: 1,
          limit: 20,
          filters: const PeopleSearchFilters(),
        ),
      ).thenAnswer((_) async => const [profileDon]);
      when(
        mockSearchPlaylistsUseCase(
          'don',
          page: 1,
          limit: 20,
          filters: const CollectionSearchFilters(),
        ),
      ).thenAnswer((_) async => const [playlistOctane]);
      when(
        mockSearchAlbumsUseCase(
          'don',
          page: 1,
          limit: 20,
          filters: const CollectionSearchFilters(),
        ),
      ).thenAnswer((_) async => const [albumOctane]);

      await notifier.setActiveTab(SearchTab.profiles);
      expect(container.read(searchProvider).profiles, const [profileDon]);

      await notifier.setActiveTab(SearchTab.playlists);
      expect(container.read(searchProvider).playlists, const [playlistOctane]);

      await notifier.setActiveTab(SearchTab.albums);
      expect(container.read(searchProvider).albums, const [albumOctane]);
    });

    test('applyTrackFilters resets paging and loads filtered tracks', () async {
      await flush();
      const filters = TrackSearchFilters(
        tag: 'rock',
        timeAdded: TrackTimeAdded.pastWeek,
      );
      notifier.state = notifier.state.copyWith(
        query: 'ocean',
        activeTab: SearchTab.tracks,
        tracks: const [trackDon],
        page: 3,
        hasMore: false,
      );
      when(
        mockSearchTracksUseCase(
          'ocean',
          page: 1,
          limit: 20,
          filters: filters,
        ),
      ).thenAnswer((_) async => const [trackOcean]);

      await notifier.applyTrackFilters(filters);

      final state = container.read(searchProvider);
      expect(state.trackFilters, filters);
      expect(state.tracks, const [trackOcean]);
      expect(state.page, 1);
      expect(state.hasMore, isFalse);
      verify(
        mockSearchTracksUseCase(
          'ocean',
          page: 1,
          limit: 20,
          filters: filters,
        ),
      ).called(1);
    });

    test('applyCollectionFilters routes through active playlist tab', () async {
      await flush();
      const filters = CollectionSearchFilters(tag: 'party');
      notifier.state = notifier.state.copyWith(
        query: 'mix',
        activeTab: SearchTab.playlists,
        playlists: const [playlistOctane],
      );
      when(
        mockSearchPlaylistsUseCase(
          'mix',
          page: 1,
          limit: 20,
          filters: filters,
        ),
      ).thenAnswer((_) async => const [playlistOctane]);

      await notifier.applyCollectionFilters(filters);

      final state = container.read(searchProvider);
      expect(state.collectionFilters, filters);
      expect(state.playlists, const [playlistOctane]);
      verify(
        mockSearchPlaylistsUseCase(
          'mix',
          page: 1,
          limit: 20,
          filters: filters,
        ),
      ).called(1);
      verifyNever(mockSearchAlbumsUseCase(any));
    });

    test('applyTrackFilters, applyCollectionFilters, and applyPeopleFilters do nothing for blank query', () async {
      await flush();

      await notifier.applyTrackFilters(const TrackSearchFilters(tag: 'rock'));
      await notifier.applyCollectionFilters(
        const CollectionSearchFilters(tag: 'party'),
      );
      await notifier.applyPeopleFilters(
        const PeopleSearchFilters(location: 'Cairo'),
      );

      verifyNever(mockSearchTracksUseCase(any));
      verifyNever(mockSearchPlaylistsUseCase(any));
      verifyNever(mockSearchProfilesUseCase(any));
    });

    test('applyPeopleFilters routes through profiles and clearFiltersForActiveTab resets them', () async {
      await flush();
      const peopleFilters = PeopleSearchFilters(
        location: 'Cairo',
        minFollowers: 1000,
        verifiedOnly: true,
        sort: PeopleSort.followers,
      );
      notifier.state = notifier.state.copyWith(
        query: 'don',
        activeTab: SearchTab.profiles,
      );
      when(
        mockSearchProfilesUseCase(
          'don',
          page: 1,
          limit: 20,
          filters: peopleFilters,
        ),
      ).thenAnswer((_) async => const [profileDon]);
      when(
        mockSearchProfilesUseCase(
          'don',
          page: 1,
          limit: 20,
          filters: const PeopleSearchFilters(),
        ),
      ).thenAnswer((_) async => const [profileOther]);

      await notifier.applyPeopleFilters(peopleFilters);
      expect(container.read(searchProvider).peopleFilters, peopleFilters);

      await notifier.clearFiltersForActiveTab();

      final state = container.read(searchProvider);
      expect(state.peopleFilters.hasAny, isFalse);
      expect(state.profiles, const [profileOther]);
      verify(
        mockSearchProfilesUseCase(
          'don',
          page: 1,
          limit: 20,
          filters: peopleFilters,
        ),
      ).called(1);
      verify(
        mockSearchProfilesUseCase(
          'don',
          page: 1,
          limit: 20,
          filters: const PeopleSearchFilters(),
        ),
        ).called(1);
    });

    test('clearFiltersForActiveTab covers track, album, and all-tab branches', () async {
      await flush();
      notifier.state = notifier.state.copyWith(
        query: 'don',
        activeTab: SearchTab.tracks,
        trackFilters: const TrackSearchFilters(tag: 'rock'),
      );
      when(
        mockSearchTracksUseCase(
          'don',
          page: 1,
          limit: 20,
          filters: const TrackSearchFilters(),
        ),
      ).thenAnswer((_) async => const [trackDon]);

      await notifier.clearFiltersForActiveTab();
      expect(container.read(searchProvider).trackFilters.hasAny, isFalse);

      notifier.state = notifier.state.copyWith(
        activeTab: SearchTab.albums,
        collectionFilters: const CollectionSearchFilters(tag: 'party'),
      );
      when(
        mockSearchAlbumsUseCase(
          'don',
          page: 1,
          limit: 20,
          filters: const CollectionSearchFilters(),
        ),
      ).thenAnswer((_) async => const [albumOctane]);

      await notifier.clearFiltersForActiveTab();
      expect(container.read(searchProvider).collectionFilters.hasAny, isFalse);

      notifier.state = notifier.state.copyWith(activeTab: SearchTab.all);
      await notifier.clearFiltersForActiveTab();
    });

    test('loadMore appends tracks and advances page', () async {
      await flush();
      notifier.state = notifier.state.copyWith(
        query: 'don',
        activeTab: SearchTab.tracks,
        tracks: const [trackDon],
        page: 1,
        hasMore: true,
      );
      when(
        mockSearchTracksUseCase(
          'don',
          page: 2,
          limit: 20,
          filters: const TrackSearchFilters(),
        ),
      ).thenAnswer((_) async => const [trackPaged]);

      await notifier.loadMore();

      final state = container.read(searchProvider);
      expect(state.tracks, const [trackDon, trackPaged]);
      expect(state.page, 2);
      expect(state.isLoadingMore, isFalse);
      expect(state.hasMore, isFalse);
      verify(
        mockSearchTracksUseCase(
          'don',
          page: 2,
          limit: 20,
          filters: const TrackSearchFilters(),
        ),
      ).called(1);
    });

    test('loadMore guards duplicate and invalid fetches', () async {
      await flush();

      notifier.state = notifier.state.copyWith(
        query: 'don',
        activeTab: SearchTab.all,
      );
      await notifier.loadMore();

      notifier.state = notifier.state.copyWith(
        activeTab: SearchTab.tracks,
        isLoading: true,
      );
      await notifier.loadMore();

      notifier.state = notifier.state.copyWith(
        isLoading: false,
        isLoadingMore: true,
      );
      await notifier.loadMore();

      notifier.state = notifier.state.copyWith(
        isLoadingMore: false,
        hasMore: false,
      );
      await notifier.loadMore();

      verifyNever(mockSearchTracksUseCase(any));
    });

    test('loadMore swallows errors and resets loadingMore flag', () async {
      await flush();
      notifier.state = notifier.state.copyWith(
        query: 'don',
        activeTab: SearchTab.tracks,
        tracks: const [trackDon],
        hasMore: true,
      );
      when(
        mockSearchTracksUseCase(
          'don',
          page: 2,
          limit: 20,
          filters: const TrackSearchFilters(),
        ),
      ).thenThrow(Exception('page failed'));

      await notifier.loadMore();

      final state = container.read(searchProvider);
      expect(state.tracks, const [trackDon]);
      expect(state.isLoadingMore, isFalse);
      expect(state.page, 1);
      verify(
        mockSearchTracksUseCase(
          'don',
          page: 2,
          limit: 20,
          filters: const TrackSearchFilters(),
        ),
        ).called(1);
    });

    test('loadMore appends profiles, playlists, and albums in their respective tabs', () async {
      await flush();

      notifier.state = notifier.state.copyWith(
        query: 'don',
        activeTab: SearchTab.profiles,
        profiles: const [profileDon],
        page: 1,
        hasMore: true,
      );
      when(
        mockSearchProfilesUseCase(
          'don',
          page: 2,
          limit: 20,
          filters: const PeopleSearchFilters(),
        ),
      ).thenAnswer((_) async => const [profileOther]);
      await notifier.loadMore();
      expect(
        container.read(searchProvider).profiles,
        const [profileDon, profileOther],
      );

      notifier.state = notifier.state.copyWith(
        activeTab: SearchTab.playlists,
        playlists: const [playlistOctane],
        profiles: const [],
        page: 1,
        hasMore: true,
      );
      when(
        mockSearchPlaylistsUseCase(
          'don',
          page: 2,
          limit: 20,
          filters: const CollectionSearchFilters(),
        ),
      ).thenAnswer((_) async => const [playlistOctane]);
      await notifier.loadMore();
      expect(container.read(searchProvider).playlists, hasLength(2));

      notifier.state = notifier.state.copyWith(
        activeTab: SearchTab.albums,
        albums: const [albumOctane],
        playlists: const [],
        page: 1,
        hasMore: true,
      );
      when(
        mockSearchAlbumsUseCase(
          'don',
          page: 2,
          limit: 20,
          filters: const CollectionSearchFilters(),
        ),
      ).thenAnswer((_) async => const [albumOctane]);
      await notifier.loadMore();
      expect(container.read(searchProvider).albums, hasLength(2));
    });
  });

  group('recent searches and recents', () {
    test('removeRecentSearch and clearRecentSearches update state', () async {
      await flush();
      notifier.state = notifier.state.copyWith(
        recentSearches: const ['don', 'rock', 'pop'],
      );

      notifier.removeRecentSearch('rock');
      expect(
        container.read(searchProvider).recentSearches,
        const ['don', 'pop'],
      );

      notifier.clearRecentSearches();
      expect(container.read(searchProvider).recentSearches, isEmpty);
    });

    test('recordResultTapped deduplicates and remove/clear recent results work', () async {
      await flush();
      const first = RecentResultItem(
        kind: RecentResultKind.profile,
        id: '1',
        title: 'Don Toliver',
        subtitle: '688000 Followers',
      );
      const second = RecentResultItem(
        kind: RecentResultKind.track,
        id: '2',
        title: 'Ocean Drive',
        subtitle: 'Duke',
      );

      notifier.recordResultTapped(first);
      notifier.recordResultTapped(second);
      notifier.recordResultTapped(first);

      expect(container.read(searchProvider).recentResults, const [first, second]);

      notifier.removeRecentResult(first);
      expect(container.read(searchProvider).recentResults, const [second]);

      notifier.clearRecentResults();
      expect(container.read(searchProvider).recentResults, isEmpty);
    });

    test('recordResultTapped keeps only the latest eight items', () async {
      await flush();

      for (var i = 0; i < 9; i++) {
        notifier.recordResultTapped(
          RecentResultItem(
            kind: RecentResultKind.track,
            id: '$i',
            title: 'Track $i',
            subtitle: 'Artist $i',
          ),
        );
      }

      final results = container.read(searchProvider).recentResults;
      expect(results, hasLength(8));
      expect(results.first.id, '8');
      expect(results.last.id, '1');
    });

    test('onRecentSearchTapped delegates to query submission', () async {
      await flush();
      when(
        mockSearchAllUseCase('don'),
      ).thenAnswer((_) async => const SearchAllResultEntity());

      await notifier.onRecentSearchTapped('don');

      expect(container.read(searchProvider).query, 'don');
      verify(mockSearchAllUseCase('don')).called(1);
    });
  });

  group('GenreDetailNotifier', () {
    test('loads genre detail on build successfully', () async {
      when(mockGetGenreDetailUseCase('rock')).thenAnswer((_) async => genreDetail);

      final states = <GenreDetailState>[];
      container.listen<GenreDetailState>(
        genreDetailProvider('rock'),
        (_, next) => states.add(next),
        fireImmediately: true,
      );

      await flush();

      final state = container.read(genreDetailProvider('rock'));
      expect(states.first.isLoading, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.detail, genreDetail);
      expect(state.error, isNull);
      verify(mockGetGenreDetailUseCase('rock')).called(1);
    });

    test('stores friendly error and retry reloads detail', () async {
      var calls = 0;
      when(mockGetGenreDetailUseCase('rock')).thenAnswer((_) async {
        calls++;
        if (calls == 1) {
          throw Exception('load failed');
        }
        return genreDetail;
      });

      final notifier = container.read(genreDetailProvider('rock').notifier);

      await flush();

      var state = container.read(genreDetailProvider('rock'));
      expect(state.isLoading, isFalse);
      expect(state.error, 'Could not load genre details.');

      notifier.setActiveTab(SearchTab.albums);
      expect(
        container.read(genreDetailProvider('rock')).activeTab,
        SearchTab.albums,
      );

      notifier.retry();
      await flush();

      state = container.read(genreDetailProvider('rock'));
      expect(state.detail, genreDetail);
      expect(state.error, isNull);
      verify(mockGetGenreDetailUseCase('rock')).called(2);
    });
  });
}
