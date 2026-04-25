import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_tab_type.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/feed_interaction_buttons.dart';

void main() {
  Widget buildButtons({
    required FeedType feedType,
    required bool fallbackIsLiked,
    bool fallbackIsReposted = false,
    int fallbackRepostsCount = 0,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Material(
          color: Colors.black,
          child: FeedInteractionButtons(
            trackId: 'test-track-id',
            fallbackLikesCount: 320,
            fallbackCommentsCount: 45,
            fallbackIsLiked: fallbackIsLiked,
            fallbackIsReposted: fallbackIsReposted,
            fallbackRepostsCount: fallbackRepostsCount,
            feedType: feedType,
          ),
        ),
      ),
    );
  }

  testWidgets('renders like and comment buttons', (tester) async {
    await tester.pumpWidget(
      buildButtons(
        feedType: FeedType.discover,
        fallbackIsLiked: false,
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.comment), findsOneWidget);
  });

  testWidgets('shows filled heart when liked', (tester) async {
    await tester.pumpWidget(
      buildButtons(
        feedType: FeedType.classic,
        fallbackIsLiked: true,
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
