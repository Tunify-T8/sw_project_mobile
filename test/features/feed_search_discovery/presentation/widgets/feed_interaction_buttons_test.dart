import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_tab_type.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/feed_interaction_buttons.dart';

void main() {
  Widget buildButtons({
    required FeedType feedType,
    required bool isLiked,
    bool? isReposted,
    int? repostsCount,
  }) {
    return MaterialApp(
      home: Material(
        color: Colors.black,
        child: FeedInteractionButtons(
          isLiked: isLiked,
          isReposted: isReposted,
          likesCount: 320,
          repostsCount: repostsCount,
          commentsCount: 45,
          feedType: feedType,
        ),
      ),
    );
  }

  testWidgets('renders non-classic vertical layout with like, comment, and more buttons', (tester) async {
    await tester.pumpWidget(
      buildButtons(
        feedType: FeedType.discover,
        isLiked: false,
      ),
    );

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.comment), findsOneWidget);
    expect(find.byIcon(Icons.more), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsNothing);
    expect(find.text('320'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.comment));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.more));
    await tester.pump();
  });

  testWidgets('renders classic layout with repost button and highlighted repost color', (tester) async {
    await tester.pumpWidget(
      buildButtons(
        feedType: FeedType.classic,
        isLiked: true,
        isReposted: true,
        repostsCount: 28,
      ),
    );

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.comment), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
    expect(find.byIcon(Icons.more), findsNothing);
    expect(find.text('320'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
    expect(find.text('28'), findsOneWidget);

    final repeatIcon = tester.widget<Icon>(find.byIcon(Icons.repeat));
    expect(repeatIcon.color, Colors.orange);

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.comment));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.repeat));
    await tester.pump();
  });

  testWidgets('uses default repost values when classic repost data is null', (tester) async {
    await tester.pumpWidget(
      buildButtons(
        feedType: FeedType.classic,
        isLiked: false,
        isReposted: null,
        repostsCount: null,
      ),
    );

    final repeatIcon = tester.widget<Icon>(find.byIcon(Icons.repeat));
    expect(repeatIcon.color, isNull);
    expect(find.text('0'), findsOneWidget);
  });
}
