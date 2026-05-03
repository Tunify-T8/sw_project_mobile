import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_view_mode.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/feed_interaction_buttons.dart';
import 'package:software_project/features/engagements_social_interactions/domain/entities/track_engagement_entity.dart';
import 'package:software_project/features/engagements_social_interactions/domain/repositories/engagement_repository.dart';
import 'package:software_project/features/engagements_social_interactions/presentation/provider/enagement_providers.dart';

class FakeEngagementRepository implements EngagementRepository {
  FakeEngagementRepository(this.engagement);

  TrackEngagementEntity engagement;
  var toggleLikeCalls = 0;
  var removeRepostCalls = 0;

  @override
  Future<TrackEngagementEntity> getTrackEngagement({required String trackId}) async {
    return engagement;
  }

  @override
  Future<TrackEngagementEntity> toggleLike({
    required String trackId,
    required String viewerId,
  }) async {
    toggleLikeCalls++;
    engagement = engagement.copyWith(
      isLiked: !engagement.isLiked,
      likeCount: engagement.isLiked ? engagement.likeCount - 1 : engagement.likeCount + 1,
    );
    return engagement;
  }

  @override
  Future<TrackEngagementEntity> removeRepost({
    required String trackId,
    required String viewerId,
  }) async {
    removeRepostCalls++;
    engagement = engagement.copyWith(
      isReposted: false,
      repostCount: engagement.repostCount - 1,
    );
    return engagement;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeEngagementRepository repository;

  Widget buildButtons({
    required FeedViewMode feedViewMode,
    required bool fallbackIsLiked,
    bool fallbackIsReposted = false,
    int fallbackRepostsCount = 0,
    String role = 'listener',
  }) {
    repository = FakeEngagementRepository(
      TrackEngagementEntity(
        trackId: 'test-track-id',
        likeCount: 320,
        commentCount: 45,
        repostCount: fallbackRepostsCount,
        isLiked: fallbackIsLiked,
        isReposted: fallbackIsReposted,
      ),
    );

    return ProviderScope(
      overrides: [
        engagementRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(
          () => _TestAuthController(role),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Material(
            color: Colors.black,
            child: FeedInteractionButtons(
              trackId: 'test-track-id',
              fallbackLikesCount: 320,
              fallbackCommentsCount: 45,
              fallbackIsLiked: fallbackIsLiked,
              fallbackIsReposted: fallbackIsReposted,
              fallbackRepostsCount: fallbackRepostsCount,
              feedViewMode: feedViewMode,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders like and comment buttons', (tester) async {
    await tester.pumpWidget(
      buildButtons(
        feedViewMode: FeedViewMode.discover,
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
        feedViewMode: FeedViewMode.classic,
        fallbackIsLiked: true,
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('toggles like and opens likes/comments routes', (tester) async {
    await tester.pumpWidget(
      buildButtons(
        feedViewMode: FeedViewMode.discover,
        fallbackIsLiked: false,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('feed_like_button')));
    await tester.pump();
    expect(repository.toggleLikeCalls, 1);

    await tester.tap(find.byKey(const Key('feed_likes_count')));
    await tester.pump();
    expect(find.byType(Navigator), findsOneWidget);
  });

  testWidgets('comment button pushes comments route', (tester) async {
    await tester.pumpWidget(
      buildButtons(
        feedViewMode: FeedViewMode.discover,
        fallbackIsLiked: false,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('feed_comment_button')));
    await tester.pump();

    expect(find.byType(Navigator), findsOneWidget);
  });

  testWidgets('discover album button blocks listeners with snackbar', (tester) async {
    await tester.pumpWidget(
      buildButtons(
        feedViewMode: FeedViewMode.discover,
        fallbackIsLiked: false,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('feed_album_add_button')));
    await tester.pump();

    expect(find.text('Only artists can add to albums'), findsOneWidget);
  });

  testWidgets('discover add buttons open selection surfaces for artists', (tester) async {
    await tester.pumpWidget(
      buildButtons(
        feedViewMode: FeedViewMode.discover,
        fallbackIsLiked: false,
        role: 'artist',
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('feed_playlist_add_button')));
    await tester.pump();
    expect(find.byType(Navigator), findsOneWidget);
    Navigator.of(tester.element(find.byType(Navigator))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('feed_album_add_button')));
    await tester.pump();
    expect(find.byType(Navigator), findsOneWidget);
  });

  testWidgets('classic mode removes existing repost and opens reposters', (tester) async {
    await tester.pumpWidget(
      buildButtons(
        feedViewMode: FeedViewMode.classic,
        fallbackIsLiked: false,
        fallbackIsReposted: true,
        fallbackRepostsCount: 3,
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.repeat_on), findsOneWidget);

    await tester.tap(find.byKey(const Key('feed_repost_button')));
    await tester.pump();
    expect(repository.removeRepostCalls, 1);

    await tester.tap(find.byKey(const Key('feed_reposts_count')));
    await tester.pump();
    expect(find.byType(Navigator), findsOneWidget);
  });

  testWidgets('classic mode opens repost caption sheet when not reposted', (tester) async {
    await tester.pumpWidget(
      buildButtons(
        feedViewMode: FeedViewMode.classic,
        fallbackIsLiked: false,
        fallbackIsReposted: false,
        fallbackRepostsCount: 2,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('feed_repost_button')));
    await tester.pump();

    expect(find.byType(BottomSheet), findsOneWidget);
  });
}

class _TestAuthController extends AuthController {
  _TestAuthController(this._role);

  final String _role;

  @override
  AsyncValue<AuthUserEntity?> build() {
    return AsyncData(
      AuthUserEntity(
        id: 'viewer-1',
        email: 'viewer@example.com',
        username: 'viewer',
        role: _role,
        isVerified: true,
      ),
    );
  }
}
