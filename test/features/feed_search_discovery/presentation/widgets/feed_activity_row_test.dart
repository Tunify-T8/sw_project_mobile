import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_item_source.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_tab_type.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_view_mode.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/feed_activity_row.dart';

void main() {
  Widget buildRow({
    String? avatarUrl,
    required FeedType feedType,
    required FeedItemSource source,
    String? createdAt = '5:20',
  }) {
    return MaterialApp(
      home: Material(
        color: Colors.black,
        child: FeedActivityRow(
          avatarUrl: avatarUrl,
          timeAgo: '2h',
          createdAt: createdAt,
          feedViewMode: feedType == FeedType.discover
              ? FeedViewMode.discover
              : FeedViewMode.classic,
          feedType: feedType,
          source: source,
          actorName: 'Drake',
          trackName: 'Midnight Drive',
        ),
      ),
    );
  }

  testWidgets('renders classic post activity without createdAt text', (tester) async {
    await tester.pumpWidget(
      buildRow(
        feedType: FeedType.following,
        source: FeedItemSource.post,
        createdAt: '5:20',
      ),
    );

    expect(find.textContaining('Drake posted a track'), findsOneWidget);
    expect(find.textContaining('5:20'), findsNothing);
    expect(find.textContaining('2h'), findsOneWidget);
  });

  testWidgets('renders repost and discover timestamps when not classic', (tester) async {
    await tester.pumpWidget(
      buildRow(
        feedType: FeedType.discover,
        source: FeedItemSource.repost,
      ),
    );

    expect(find.textContaining('Drake reposted a track'), findsOneWidget);
    expect(find.textContaining('5:20'), findsOneWidget);
    expect(find.textContaining('2h'), findsOneWidget);
  });

  testWidgets('covers discover reason text branches', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          color: Colors.black,
          child: Column(
            children: [
              FeedActivityRow(
                avatarUrl: null,
                timeAgo: '1h',
                createdAt: '4:10',
                feedViewMode: FeedViewMode.discover,
                feedType: FeedType.discover,
                source: null,
                actorName: 'Billie',
                discoverReason: 'New release by Billie',
                trackName: 'Ocean Lights',
              ),
              FeedActivityRow(
                avatarUrl: null,
                timeAgo: '3h',
                createdAt: '7:30',
                feedViewMode: FeedViewMode.discover,
                feedType: FeedType.following,
                source: null,
                actorName: 'Drake',
                discoverReason: 'Because you liked Midnight Drive by Drake',
                trackName: 'Midnight Drive',
              ),
              FeedActivityRow(
                avatarUrl: null,
                timeAgo: '4h',
                createdAt: null,
                feedViewMode: FeedViewMode.classic,
                feedType: FeedType.following,
                source: null,
                actorName: 'Drake',
                discoverReason: 'Because you follow Drake',
                trackName: 'Ignored',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('New release by Billie'), findsOneWidget);
    expect(
      find.text('Because you liked Midnight Drive by Drake'),
      findsOneWidget,
    );
    expect(find.text('Because you follow Drake'), findsOneWidget);
  });
}
