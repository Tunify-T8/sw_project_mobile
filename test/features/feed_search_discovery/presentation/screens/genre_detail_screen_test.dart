import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/album_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/genre_detail_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/playlist_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/profile_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/search_provider.dart';
import 'package:software_project/features/feed_search_discovery/presentation/screens/genre_detail_screen.dart';

import '../providers/search_provider_test.mocks.dart';
import '../../../../test_utils/mock_network_images.dart';

void main() {
  late MockGetGenreDetailUseCase mockGetGenreDetailUseCase;
  late ProviderContainer container;

  const trendingTrack = TrackResultEntity(
    id: 'track-1',
    title: 'Midnight Echo',
    artistName: 'Luna Waves',
    durationSeconds: 180,
  );
  const introducingTrack = TrackResultEntity(
    id: 'track-2',
    title: 'Neon Dreams',
    artistName: 'Skyline',
    durationSeconds: 210,
  );
  const playlist = PlaylistResultEntity(
    id: 'playlist-1',
    title: 'Drive Home',
    creatorName: 'Curator',
    trackCount: 8,
  );
  const playlistWithArtwork = PlaylistResultEntity(
    id: 'playlist-2',
    title: 'Afterparty',
    creatorName: 'Curator',
    trackCount: 9,
  );
  const profile = ProfileResultEntity(
    id: 'profile-1',
    username: 'Nova Sky',
    followersCount: 1200,
    isFollowing: false,
  );
  const followedProfile = ProfileResultEntity(
    id: 'profile-2',
    username: 'Luna Waves',
    followersCount: 3200,
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
    trendingTracks: [trendingTrack],
    introducingTracks: [introducingTrack],
    playlists: [playlist, playlistWithArtwork],
    profiles: [profile, followedProfile],
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
      ],
    );
  }

  Widget buildApp({
    required ProviderContainer container,
    required Widget child,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: child),
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
    expect(find.text('Neon Dreams'), findsOneWidget);
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
    expect(find.text('Follow'), findsWidgets);
    expect(find.text('Following'), findsOneWidget);

    await tester.tap(find.text('Trending').last);
    await settleShort(tester);
    expect(find.text('Midnight Echo'), findsWidgets);

    await tester.tap(find.text('Playlists').last);
    await settleShort(tester);
    expect(find.text('Drive Home'), findsWidgets);

    await tester.tap(find.text('Albums'));
    await settleShort(tester);
    expect(find.text('Blue Lights'), findsWidgets);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await settleShort(tester);
    expect(find.text('Open'), findsOneWidget);
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

    await tester.tap(find.text('Trending').last);
    await settleShort(tester);
    expect(find.text('No trending tracks yet.'), findsOneWidget);

    await tester.tap(find.text('Playlists').last);
    await settleShort(tester);
    expect(find.text('No playlists yet.'), findsOneWidget);

    await tester.tap(find.text('Albums'));
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
