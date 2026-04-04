import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/album_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/playlist_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/profile_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/search_all_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/search_genre_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/top_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/search_provider.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/search/search_result_tabs.dart';

void main() {
  const track = TrackResultEntity(
    id: 'track-1',
    title: 'Ocean Drive',
    artistName: 'Duke',
    durationSeconds: 180,
    isUnavailable: true,
  );
  const trackWithArtwork = TrackResultEntity(
    id: 'track-2',
    title: 'Coastal Run',
    artistName: 'Duke',
    durationSeconds: 210,
  );
  const extraTrack1 = TrackResultEntity(
    id: 'track-3',
    title: 'Late Waves',
    artistName: 'Duke',
    durationSeconds: 200,
  );
  const extraTrack2 = TrackResultEntity(
    id: 'track-4',
    title: 'Moonlight',
    artistName: 'Duke',
    durationSeconds: 220,
  );
  const extraTrack3 = TrackResultEntity(
    id: 'track-5',
    title: 'Sunrise',
    artistName: 'Duke',
    durationSeconds: 230,
  );
  const extraTrack4 = TrackResultEntity(
    id: 'track-6',
    title: 'Overflow Track',
    artistName: 'Duke',
    durationSeconds: 240,
  );
  const profile = ProfileResultEntity(
    id: 'profile-1',
    username: 'Don Toliver',
    followersCount: 500,
    isVerified: true,
  );
  const profileWithAvatar = ProfileResultEntity(
    id: 'profile-2',
    username: 'Skyline',
    followersCount: 3200,
  );
  const profileExtra1 = ProfileResultEntity(
    id: 'profile-3',
    username: 'Waveform',
    followersCount: 20,
  );
  const profileExtra2 = ProfileResultEntity(
    id: 'profile-4',
    username: 'Night Shift',
    followersCount: 30,
  );
  const profileExtra3 = ProfileResultEntity(
    id: 'profile-5',
    username: 'Overflow Profile',
    followersCount: 40,
  );
  const playlist = PlaylistResultEntity(
    id: 'playlist-1',
    title: 'Party Mix',
    creatorName: 'DJ',
    trackCount: 5,
  );
  const playlistWithArtwork = PlaylistResultEntity(
    id: 'playlist-2',
    title: 'Drive Home',
    creatorName: 'Curator',
    trackCount: 8,
  );
  const playlistExtra1 = PlaylistResultEntity(
    id: 'playlist-3',
    title: 'Afterparty',
    creatorName: 'DJ',
    trackCount: 7,
  );
  const playlistExtra2 = PlaylistResultEntity(
    id: 'playlist-4',
    title: 'Warmup',
    creatorName: 'DJ',
    trackCount: 4,
  );
  const playlistExtra3 = PlaylistResultEntity(
    id: 'playlist-5',
    title: 'Overflow Playlist',
    creatorName: 'DJ',
    trackCount: 6,
  );
  const album = AlbumResultEntity(
    id: 'album-1',
    title: 'OCTANE',
    artistName: 'Don Toliver',
    trackCount: 10,
  );
  const albumWithArtwork = AlbumResultEntity(
    id: 'album-2',
    title: 'Night Drive',
    artistName: 'Duke',
    trackCount: 11,
  );
  const albumExtra1 = AlbumResultEntity(
    id: 'album-3',
    title: 'Side Streets',
    artistName: 'Duke',
    trackCount: 9,
  );
  const albumExtra2 = AlbumResultEntity(
    id: 'album-4',
    title: 'Blue Lights',
    artistName: 'Duke',
    trackCount: 12,
  );
  const albumExtra3 = AlbumResultEntity(
    id: 'album-5',
    title: 'Overflow Album',
    artistName: 'Duke',
    trackCount: 13,
  );

  Widget buildWidget(
    SearchState state, {
    VoidCallback? onLoadMore,
    ValueChanged<SearchTab>? onTabChanged,
    ProviderContainer? container,
  }) {
    final scope = container == null
        ? ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                backgroundColor: Colors.black,
                body: SizedBox.expand(
                  child: SearchResultsTabs(
                    state: state,
                    onTabChanged: onTabChanged ?? (_) {},
                    onLoadMore: onLoadMore ?? () {},
                    onToggleLike: (_) {},
                  ),
                ),
              ),
            ),
          )
        : UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                backgroundColor: Colors.black,
                body: SizedBox.expand(
                  child: SearchResultsTabs(
                    state: state,
                    onTabChanged: onTabChanged ?? (_) {},
                    onLoadMore: onLoadMore ?? () {},
                    onToggleLike: (_) {},
                  ),
                ),
              ),
            ),
          );
    return scope;
  }

  Future<void> settleShort(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('shows loading and error states', (tester) async {
    await tester.pumpWidget(
      buildWidget(const SearchState(isLoading: true)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(
      buildWidget(const SearchState(error: 'Search failed')),
    );
    expect(find.text('Search failed'), findsOneWidget);
  });

  testWidgets('shows empty all-tab state when there are no results', (tester) async {
    await tester.pumpWidget(
      buildWidget(const SearchState(query: 'unknown')),
    );

    expect(find.text('No matches for "unknown"'), findsOneWidget);
  });

  testWidgets('renders all-tab sections for populated results', (tester) async {
    await tester.pumpWidget(
      buildWidget(
        const SearchState(
          query: 'don',
          allResult: SearchAllResultEntity(
            topResult: TopResultEntity(
              id: 'profile-1',
              type: TopResultType.profile,
              title: 'Don Toliver',
              subtitle: '500 Followers',
            ),
            tracks: [track],
            playlists: [playlist],
            profiles: [profile],
            albums: [album],
          ),
          recentResults: [
            RecentResultItem(
              kind: RecentResultKind.track,
              id: 'track-1',
              title: 'Ocean Drive',
              subtitle: 'Duke',
            ),
          ],
        ),
      ),
    );

    expect(find.text('Top Result'), findsOneWidget);
    expect(find.text('Recently Played'), findsOneWidget);
    expect(find.text('Tracks'), findsWidgets);
    expect(find.text('Playlists'), findsWidgets);
    expect(find.text('Profiles'), findsWidgets);
    expect(find.text('Albums'), findsWidgets);
    expect(find.text('Not available in your country'), findsWidgets);
    expect(find.text('Follow'), findsOneWidget);
  });

  testWidgets('records tapped top result and opens see-all routes for each section', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildWidget(
        const SearchState(
          query: 'don',
          allResult: SearchAllResultEntity(
            topResult: TopResultEntity(
              id: 'top-track',
              type: TopResultType.track,
              title: 'Top Track',
              subtitle: 'Duke',
            ),
            tracks: [
              track,
              trackWithArtwork,
              extraTrack1,
              extraTrack2,
              extraTrack3,
              extraTrack4,
            ],
            playlists: [
              playlist,
              playlistWithArtwork,
              playlistExtra1,
              playlistExtra2,
              playlistExtra3,
            ],
            profiles: [
              profile,
              profileWithAvatar,
              profileExtra1,
              profileExtra2,
              profileExtra3,
            ],
            albums: [
              album,
              albumWithArtwork,
              albumExtra1,
              albumExtra2,
              albumExtra3,
            ],
          ),
          recentResults: [
            RecentResultItem(
              kind: RecentResultKind.track,
              id: 'recent-track',
              title: 'Recent Track',
              subtitle: 'Artist',
            ),
            RecentResultItem(
              kind: RecentResultKind.album,
              id: 'recent-album',
              title: 'Recent Album',
              subtitle: 'Artist',
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Top Track'), findsOneWidget);

    final seeAll = find.text('See all');

    await tester.tap(seeAll.at(0));
    await tester.pump();
    expect(find.byType(Navigator), findsOneWidget);
  });

  testWidgets('shows empty state for non-all tabs and reacts to activeTab updates', (
    tester,
  ) async {
    SearchTab? changedTab;

    await tester.pumpWidget(
      buildWidget(
        const SearchState(
          query: 'don',
          activeTab: SearchTab.profiles,
        ),
        onTabChanged: (tab) => changedTab = tab,
      ),
    );
    await settleShort(tester);

    await tester.tap(find.text('Profiles'));
    await settleShort(tester);
    expect(find.text('No results found.'), findsOneWidget);

    await tester.tap(find.text('Playlists'));
    await settleShort(tester);
    expect(changedTab, SearchTab.playlists);
    expect(find.text('No results found.'), findsOneWidget);

    await tester.pumpWidget(
      buildWidget(
        const SearchState(
          query: 'don',
          activeTab: SearchTab.albums,
          albums: [album],
        ),
        onTabChanged: (tab) => changedTab = tab,
      ),
    );
    await settleShort(tester);

    await tester.tap(find.text('Albums'));
    await settleShort(tester);
    expect(find.text('OCTANE'), findsOneWidget);
  });

  testWidgets('renders loading-more indicator in tracks tab', (tester) async {
    await tester.pumpWidget(
      buildWidget(
        const SearchState(
          query: 'don',
          activeTab: SearchTab.tracks,
          tracks: [track],
          isLoadingMore: true,
        ),
      ),
    );
    await settleShort(tester);

    await tester.tap(find.text('Tracks'));
    await settleShort(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('calls onTabChanged and onLoadMore from the tracks tab', (tester) async {
    SearchTab? changedTab;
    var loadMoreCalls = 0;

    await tester.pumpWidget(
      buildWidget(
        const SearchState(
          query: 'don',
          tracks: [track, track, track, track, track],
          hasMore: true,
        ),
        onTabChanged: (tab) => changedTab = tab,
        onLoadMore: () => loadMoreCalls++,
      ),
    );

    await tester.tap(find.text('Tracks'));
    await settleShort(tester);

    expect(changedTab, SearchTab.tracks);

    await tester.drag(find.byType(TabBarView), const Offset(0, -1000));
    await settleShort(tester);

    expect(loadMoreCalls, greaterThanOrEqualTo(1));
  });
}
