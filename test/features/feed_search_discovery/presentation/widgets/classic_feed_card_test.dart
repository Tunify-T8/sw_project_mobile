import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_actor_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_item_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_item_source.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_interaction_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_preview_entity.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/classic_feed_card.dart';

import '../../../../test_utils/mock_network_images.dart';

void main() {
  FeedItemEntity buildItem({String? coverUrl}) {
    return FeedItemEntity(
      source: FeedItemSource.post,
      timeAgo: '2h',
      actor: const FeedActorEntity(id: 'user-1', username: 'Drake'),
      track: TrackPreviewEntity(
        trackId: 'track-1',
        title: 'Midnight Drive',
        artistId: 'artist-1',
        artistName: 'Drake',
        artistVerified: true,
        coverUrl: coverUrl,
        duration: 215,
        listensCount: 12400,
        likesCount: 320,
        repostsCount: 28,
        commentsCount: 45,
        createdAt: '5:20',
        interaction: TrackInteractionEntity(
          isLiked: true,
          isReposted: false,
        ),
      ),
    );
  }

  testWidgets('renders track and artist info with placeholder when cover is missing', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Material(
            color: Colors.black,
            child: ClassicFeedCard(item: buildItem()),
          ),
        ),
      ),
    );

    expect(find.text('Midnight Drive'), findsOneWidget);
    expect(find.text('Drake'), findsWidgets);
    expect(find.byIcon(Icons.music_note), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz), findsOneWidget);
  });

  testWidgets('renders cover image branch when cover url is present', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Material(
              color: Colors.black,
              child: ClassicFeedCard(item: buildItem(coverUrl: 'https://example.com/cover.png')),
            ),
          ),
        ),
      );
      await tester.pump();
    });

    expect(find.byIcon(Icons.music_note), findsNothing);
    expect(find.byIcon(Icons.more_horiz), findsOneWidget);
  });
}
