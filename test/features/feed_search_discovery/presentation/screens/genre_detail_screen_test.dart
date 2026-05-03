import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/album_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/genre_detail_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/playlist_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/profile_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/search_provider.dart';
import 'package:software_project/features/feed_search_discovery/presentation/screens/genre_detail_screen.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/search/search_section_header.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_relation_entity.dart';
import 'package:software_project/features/followers_and_social_graph/domain/repositories/social_graph_repository.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/social_graph_repository_provider.dart';

import '../providers/search_provider_test.mocks.dart';
import '../../../../test_utils/mock_network_images.dart';

class FakeSocialGraphRepository implements SocialGraphRepository {
  @override
  Future<SocialRelationEntity> getFollowStatus(String userId) async {
    return SocialRelationEntity(
      targetUserId: userId,
      isFollowing: userId == 'profile-2',
    );
  }

  @override
  Future<void> followUser(String userId) async {}

  @override
  Future<void> unfollowUser(String userId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockGetGenreDetailUseCase mockGetGenreDetailUseCase;
  late ProviderContainer container;

  const trendingTrack = TrackResultEntity(
    id: 'track-1',
    title: 'Midnight Echo',
    artistName: 'Luna Waves',
    durationSeconds: 180,
  );
  const secondTrendingTrack = TrackResultEntity(
    id: 'track-3',
    title: 'After Hours',
    artistName: 'Night Shift',
    durationSeconds: 190,
    isUnavailable: true,
  );
  const introducingTrack = TrackResultEntity(
    id: 'track-2',
    title: 'Neon Dreams',
    artistName: 'Skyline',
    durationSeconds: 210,
  );
  const secondIntroducingTrack = TrackResultEntity(
    id: 'track-4',
    title: 'City Glow',
    artistName: 'Skyline',
    artworkUrl: 'https://example.com/city-glow.png',
    durationSeconds: 205,
    isUnavailable: true,
  );
  const playlist = PlaylistResultEntity(
    id: 'playlist-1',
    title: 'Drive Home',
    creatorId: 'curator-1',
    creatorName: 'Curator',
    trackCount: 8,
  );
  const playlistWithArtwork = PlaylistResultEntity(
    id: 'playlist-2',
    title: 'Afterparty',
    creatorId: 'curator-2',
    creatorName: 'Curator',
    artworkUrl: 'https://example.com/afterparty.png',
    trackCount: 9,
    likesCount: 4,
    isLiked: true,
  );
  const profile = ProfileResultEntity(
    id: 'profile-1',
    username: 'Nova Sky',
    followersCount: 1200,
    isFollowing: false,
  );
  const profileWithAvatar = ProfileResultEntity(
    id: 'profile-2',
    username: 'Echo Park',
    avatarUrl: 'https://example.com/avatar.png',
    followersCount: 900,
    isFollowing: true,
  );
  const album = AlbumResultEntity(
    id: 'album-1',
    title: 'Blue Lights',
    artistName: 'Luna Waves',
    trackCount: 10,
  );

  const fullDetail = GenreDetailEntity(
    genreId: 'pop',
    genreLabel: 'Pop',
    trendingTracks: [trendingTrack, secondTrendingTrack],
    introducingTracks: [introducingTrack, secondIntroducingTrack],
    playlists: [playlist, playlistWithArtwork],
    profiles: [profile, profileWithAvatar],
    albums: [album],
  );

  const fullDetailWithArtwork = GenreDetailEntity(
    genreId: 'pop',
    genreLabel: 'Pop',
    artworkUrl: 'https://example.com/pop-header.png',
    trendingTracks: [trendingTrack],
  );

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        getGenreDetailUseCaseProvider.overrideWithValue(mockGetGenreDetailUseCase),
        socialGraphRepositoryProvider.overrideWithValue(
          FakeSocialGraphRepository(),
        ),
        authControllerProvider.overrideWith(
          () => _TestAuthController('profile-1'),
        ),
      ],
    );
  }

  Widget buildApp({
    required ProviderContainer container,
    required Widget child,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: ThemeData(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('route opened')),
        ),
        home: child,
      ),
    );
  }

  Future<void> settleShort(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    required ProviderContainer container,
  }) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildApp(
        container: container,
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GenreDetailScreen(
                        genreId: 'pop',
                        genreLabel: 'Pop',
                        genreColor: Color(0xFFFFD60A),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
  }

  setUp(() {
    mockGetGenreDetailUseCase = MockGetGenreDetailUseCase();
    container = buildContainer();
  });

  tearDown(() {
    container.dispose();
  });

  testWidgets('shows loading indicator while detail is still resolving', (
    tester,
  ) async {
    final completer = Completer<GenreDetailEntity>();
    when(mockGetGenreDetailUseCase('pop')).thenAnswer((_) => completer.future);

    await pumpScreen(tester, container: container);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(fullDetail);
    await tester.pump();
    await tester.pump();
  });

  testWidgets('renders header artwork overlay when genre artwork is available', (
    tester,
  ) async {
    when(mockGetGenreDetailUseCase('pop')).thenAnswer((_) async => fullDetailWithArtwork);

    await mockNetworkImagesFor(() async {
      await pumpScreen(tester, container: container);
      await tester.pump();
      await tester.pump();
      await settleShort(tester);
    });

    expect(find.byType(Image), findsWidgets);
    expect(find.text('Pop'), findsWidgets);
  });

  testWidgets('renders populated detail, supports navigation, and executes button callbacks', (
    tester,
  ) async {
    when(mockGetGenreDetailUseCase('pop')).thenAnswer((_) async => fullDetail);

    await pumpScreen(tester, container: container);
    await tester.pump();
    await tester.pump();
    await settleShort(tester);

    expect(find.text('Trending'), findsWidgets);
    expect(find.text('Introducing'), findsOneWidget);
    expect(find.text('Playlists'), findsWidgets);
    expect(find.text('Midnight Echo'), findsWidgets);
    expect(find.text('Neon Dreams'), findsWidgets);
    await tester.dragUntilVisible(
      find.text('Drive Home'),
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    expect(find.text('Drive Home'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Nova Sky'),
      find.byType(Scrollable).first,
      const Offset(0, -150),
    );
    expect(find.text('Nova Sky'), findsOneWidget);
    expect(find.byKey(const Key('genre_profile_tile_profile-1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('genre_detail_tab_tracks')));
    await settleShort(tester);
    expect(find.text('Midnight Echo'), findsWidgets);

    await tester.tap(find.byKey(const Key('genre_detail_tab_playlists')));
    await settleShort(tester);
    expect(find.text('Drive Home'), findsWidgets);

    await tester.tap(find.byKey(const Key('genre_detail_tab_albums')));
    await settleShort(tester);
    expect(find.text('Blue Lights'), findsWidgets);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await settleShort(tester);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('renders image, avatar, asset, and all-tab overflow branches', (
    tester,
  ) async {
    when(mockGetGenreDetailUseCase('pop')).thenAnswer((_) async => fullDetail);

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        buildApp(
          container: container,
          child: const GenreDetailScreen(
            genreId: 'pop',
            genreLabel: 'Pop',
            genreColor: Color(0xFFFFD60A),
            genreImageAsset: 'assets/not-real-test-asset.png',
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await settleShort(tester);

      expect(find.text('After Hours'), findsWidgets);

      await tester.dragUntilVisible(
        find.text('City Glow'),
        find.byType(Scrollable).first,
        const Offset(0, -350),
      );
      expect(find.text('City Glow'), findsWidgets);

      await tester.dragUntilVisible(
        find.text('Afterparty'),
        find.byType(Scrollable).first,
        const Offset(0, -350),
      );
      expect(find.text('Afterparty'), findsOneWidget);

      await tester.dragUntilVisible(
        find.byKey(const ValueKey('genre_collection_more_Afterparty')),
        find.byType(Scrollable).first,
        const Offset(0, -250),
      );
      await tester.tap(find.byKey(const ValueKey('genre_collection_more_Afterparty')));
      await tester.pump();
      expect(find.byType(BottomSheet), findsOneWidget);
      Navigator.of(tester.element(find.byType(BottomSheet))).pop();
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('Echo Park'),
        find.byType(Scrollable).first,
        const Offset(0, -350),
      );
      expect(find.byKey(const ValueKey('genre_profile_tile_profile-2')), findsOneWidget);
    });
  });

  testWidgets('opens section see-all pages and collection detail routes', (
    tester,
  ) async {
    when(mockGetGenreDetailUseCase('pop')).thenAnswer((_) async => fullDetail);

    await pumpScreen(tester, container: container);
    await tester.pump();
    await tester.pump();
    await settleShort(tester);

    await tester.tap(find.text('See all').first);
    await tester.pumpAndSettle();
    expect(find.text('Trending in Pop'), findsOneWidget);
    Navigator.of(tester.element(find.text('Trending in Pop'))).pop();
    await tester.pumpAndSettle();

    for (final section in ['Introducing', 'Playlists', 'Albums', 'Discover More']) {
      await tester.dragUntilVisible(
        find.widgetWithText(SearchSectionHeader, section),
        find.byType(Scrollable).first,
        const Offset(0, -400),
      );
      final header = find.widgetWithText(SearchSectionHeader, section);
      final seeAll = find.descendant(
        of: header,
        matching: find.text('See all'),
      );
      await tester.tap(seeAll);
      await tester.pumpAndSettle();
      expect(find.textContaining('in Pop'), findsWidgets);
      Navigator.of(tester.element(find.textContaining('in Pop').last)).pop();
      await tester.pumpAndSettle();
    }

    await tester.dragUntilVisible(
      find.text('Drive Home'),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );
    await tester.tap(find.text('Drive Home'));
    await tester.pumpAndSettle();
    expect(find.text('route opened'), findsOneWidget);
    Navigator.of(tester.element(find.text('route opened'))).pop();
    await tester.pumpAndSettle();

  });

  testWidgets('shows empty tab messages when detail sections are empty', (
    tester,
  ) async {
    when(
      mockGetGenreDetailUseCase('pop'),
    ).thenAnswer(
      (_) async => const GenreDetailEntity(
        genreId: 'pop',
        genreLabel: 'Pop',
      ),
    );

    await pumpScreen(tester, container: container);
    await tester.pump();
    await tester.pump();
    await settleShort(tester);

    await tester.tap(find.byKey(const Key('genre_detail_tab_tracks')));
    await settleShort(tester);
    expect(find.text('No trending tracks yet.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('genre_detail_tab_playlists')));
    await settleShort(tester);
    expect(find.text('No playlists yet.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('genre_detail_tab_albums')));
    await settleShort(tester);
    expect(find.text('No albums yet.'), findsOneWidget);
  });

  testWidgets('shows error state and retries successfully', (tester) async {
    var calls = 0;
    when(mockGetGenreDetailUseCase('pop')).thenAnswer((_) async {
      calls++;
      if (calls == 1) {
        throw Exception('failed');
      }
      return fullDetail;
    });

    await pumpScreen(tester, container: container);
    await tester.pump();
    await tester.pump();
    await settleShort(tester);

    expect(find.text('Could not load genre details.'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();
    await settleShort(tester);

    expect(find.text('Introducing'), findsOneWidget);
    verify(mockGetGenreDetailUseCase('pop')).called(2);
  });
}

class _TestAuthController extends AuthController {
  _TestAuthController(this._currentUserId);

  final String? _currentUserId;

  @override
  AsyncValue<AuthUserEntity?> build() {
    final currentUserId = _currentUserId;
    return AsyncData(
      currentUserId == null
          ? null
          : AuthUserEntity(
              id: currentUserId,
              email: '$currentUserId@example.com',
              username: currentUserId,
              role: 'listener',
              isVerified: true,
            ),
    );
  }
}
