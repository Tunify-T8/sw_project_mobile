import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/album_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/playlist_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/profile_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/search/search_result_tile_album.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/search/search_result_tile_playlist.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/search/search_result_tile_profile.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/search/search_result_tile_track.dart';

import '../../../../../test_utils/mock_network_images.dart';

void main() {
  Future<void> setLargeSurface(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: SizedBox(width: 900, child: child),
          ),
        ),
      );

  group('SearchResultTileTrack', () {
    testWidgets('renders unavailable state with placeholder artwork', (tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(
        wrap(
          const SearchResultTileTrack(
            track: TrackResultEntity(
              id: '1',
              title: 'Ocean Drive',
              artistName: 'Duke',
              durationSeconds: 185,
              isUnavailable: true,
            ),
          ),
        ),
      );

      expect(find.text('Ocean Drive'), findsOneWidget);
      expect(find.text('Duke'), findsOneWidget);
      expect(find.text('Not available in your country'), findsOneWidget);
    });

    testWidgets('renders play count duration and artwork branch', (tester) async {
      await setLargeSurface(tester);
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          wrap(
            const SearchResultTileTrack(
              track: TrackResultEntity(
                id: '2',
                title: 'Midnight Echo',
                artistName: 'Luna',
                artworkUrl: 'https://example.com/track.png',
                durationSeconds: 125,
                playCount: '4K',
              ),
            ),
          ),
        );
        await tester.pump();
      });

      expect(find.text('4K'), findsOneWidget);
      expect(find.text('2:05'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('SearchResultTileAlbum', () {
    testWidgets('renders album metadata and like count formatting', (tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(
        wrap(
          const SearchResultTileAlbum(
            album: AlbumResultEntity(
              id: '1',
              title: 'OCTANE',
              artistName: 'Don Toliver',
              trackCount: 18,
              likesCount: 2300,
            ),
          ),
        ),
      );

      expect(find.text('OCTANE'), findsOneWidget);
      expect(find.text('Don Toliver'), findsOneWidget);
      expect(find.text('2K'), findsOneWidget);
      expect(find.text('Album'), findsOneWidget);
      expect(find.text('18 Tracks'), findsOneWidget);
    });

    testWidgets('renders artwork and million formatting branch', (tester) async {
      await setLargeSurface(tester);
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          wrap(
            const SearchResultTileAlbum(
              album: AlbumResultEntity(
                id: '2',
                title: 'Blue Lights',
                artistName: 'Nova',
                artworkUrl: 'https://example.com/album.png',
                trackCount: 9,
                likesCount: 1200000,
              ),
            ),
          ),
        );
        await tester.pump();
      });

      expect(find.text('1.2M'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('SearchResultTilePlaylist', () {
    testWidgets('renders playlist metadata and like count formatting', (tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(
        wrap(
          const SearchResultTilePlaylist(
            playlist: PlaylistResultEntity(
              id: '1',
              title: 'Party Mix',
              creatorName: 'DJ',
              trackCount: 5,
              likesCount: 42,
            ),
          ),
        ),
      );

      expect(find.text('Party Mix'), findsOneWidget);
      expect(find.text('DJ'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Playlist'), findsOneWidget);
      expect(find.text('5 Tracks'), findsOneWidget);
    });

    testWidgets('renders artwork and million formatting branch', (tester) async {
      await setLargeSurface(tester);
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          wrap(
            const SearchResultTilePlaylist(
              playlist: PlaylistResultEntity(
                id: '2',
                title: 'Drive Home',
                creatorName: 'Curator',
                artworkUrl: 'https://example.com/playlist.png',
                trackCount: 11,
                likesCount: 1500000,
              ),
            ),
          ),
        );
        await tester.pump();
      });

      expect(find.text('1.5M'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('SearchResultTileProfile', () {
    testWidgets('renders verified fallback line and follow button', (tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(
        wrap(
          const SearchResultTileProfile(
            profile: ProfileResultEntity(
              id: '1',
              username: 'Don Toliver',
              followersCount: 1200,
              isVerified: true,
            ),
          ),
        ),
      );

      expect(find.text('Don Toliver'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('1K Followers'), findsOneWidget);
      expect(find.text('Follow'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders location avatar image and following state', (tester) async {
      await setLargeSurface(tester);
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          wrap(
            const SearchResultTileProfile(
              profile: ProfileResultEntity(
                id: '2',
                username: 'Nova',
                avatarUrl: 'https://example.com/avatar.png',
                location: 'Cairo',
                followersCount: 2500000,
                isFollowing: true,
              ),
            ),
          ),
        );
        await tester.pump();
      });

      expect(find.text('Cairo'), findsOneWidget);
      expect(find.text('2.5M Followers'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('renders plain follower count and follow button press', (tester) async {
      await setLargeSurface(tester);
      await tester.pumpWidget(
        wrap(
          const SearchResultTileProfile(
            profile: ProfileResultEntity(
              id: '3',
              username: 'Indie Artist',
              followersCount: 999,
              isVerified: false,
              isFollowing: false,
            ),
          ),
        ),
      );

      expect(find.text('999 Followers'), findsOneWidget);
      expect(find.text('Follow'), findsOneWidget);

      await tester.tap(find.text('Follow'));
      await tester.pump();
    });
  });
}
