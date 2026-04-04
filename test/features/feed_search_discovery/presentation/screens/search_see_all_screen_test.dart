import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/album_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/playlist_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/profile_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/presentation/screens/search_see_all_screen.dart';

void main() {
  const track = TrackResultEntity(
    id: 'track-1',
    title: 'Ocean Drive',
    artistName: 'Duke',
    durationSeconds: 120,
  );
  const playlist = PlaylistResultEntity(
    id: 'playlist-1',
    title: 'Party Mix',
    creatorName: 'DJ',
    trackCount: 5,
  );
  const profile = ProfileResultEntity(
    id: 'profile-1',
    username: 'Nova',
    followersCount: 1200,
  );
  const album = AlbumResultEntity(
    id: 'album-1',
    title: 'OCTANE',
    artistName: 'Don Toliver',
    trackCount: 10,
  );

  Widget buildScreen(Widget child) => MaterialApp(home: child);

  testWidgets('renders tracks list before other result types', (tester) async {
    await tester.pumpWidget(
      buildScreen(
        const SearchSeeAllScreen(
          title: 'Tracks',
          tracks: [track],
          playlists: [playlist],
        ),
      ),
    );

    expect(find.text('Tracks'), findsOneWidget);
    expect(find.text('Ocean Drive'), findsOneWidget);
    expect(find.text('Party Mix'), findsNothing);
  });

  testWidgets('renders playlists list when no tracks are provided', (tester) async {
    await tester.pumpWidget(
      buildScreen(
        const SearchSeeAllScreen(
          title: 'Playlists',
          playlists: [playlist],
        ),
      ),
    );

    expect(find.text('Party Mix'), findsOneWidget);
  });

  testWidgets('renders profiles list when only profiles are provided', (tester) async {
    await tester.pumpWidget(
      buildScreen(
        const SearchSeeAllScreen(
          title: 'Profiles',
          profiles: [profile],
        ),
      ),
    );

    expect(find.text('Nova'), findsOneWidget);
    expect(find.text('1K Followers'), findsOneWidget);
  });

  testWidgets('renders albums list when only albums are provided', (tester) async {
    await tester.pumpWidget(
      buildScreen(
        const SearchSeeAllScreen(
          title: 'Albums',
          albums: [album],
        ),
      ),
    );

    expect(find.text('OCTANE'), findsOneWidget);
  });

  testWidgets('shows empty message and back button pops the route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SearchSeeAllScreen(title: 'Empty'),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing to show.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });
}
