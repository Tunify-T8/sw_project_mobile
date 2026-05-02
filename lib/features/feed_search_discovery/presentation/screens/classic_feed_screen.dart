import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/shared/ui/patterns/error_retry_view.dart';

import '../../domain/entities/feed_tab_type.dart';
import '../../domain/entities/feed_item_entity.dart';
import '../../domain/entities/feed_view_mode.dart';
import '../providers/feed_notifier.dart';
import '../providers/feed_view_provider.dart';
import '../widgets/classic_feed_card.dart';

class ClassicFeedScreen extends ConsumerStatefulWidget {
  const ClassicFeedScreen({super.key});

  @override
  ConsumerState<ClassicFeedScreen> createState() => _ClassicFeedScreenState();
}

class _ClassicFeedScreenState extends ConsumerState<ClassicFeedScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final state = ref.read(feedNotifierProvider);
      if (!state.hasLoadedFollowing && !state.isFollowingLoading) {
        ref
            .read(feedNotifierProvider.notifier)
            .loadFeed(tab: FeedType.following);
      }
    });
  }

  Widget _buildContent({
    required bool isLoading,
    required bool hasLoaded,
    required String? error,
    required List<FeedItemEntity> items,
  }) {
    if (isLoading || !hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return ErrorRetryView(
        onRetry: () => ref
            .read(feedNotifierProvider.notifier)
            .loadFeed(tab: FeedType.following),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(feedNotifierProvider.notifier)
            .refreshFeed(tab: FeedType.following);
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
        itemCount: items.isEmpty ? 2 : items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: GestureDetector(
                onTap: () => ref
                    .read(feedViewModeProvider.notifier)
                    .setMode(FeedViewMode.discover),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Discover music in a whole new way',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to activate the new feed',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 36),
                    ],
                  ),
                ),
              ),
            );
          }

          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(24, 80, 24, 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.people, size: 50, color: Colors.grey),
                    SizedBox(height: 25),
                    Text(
                      "Your feed is empty.\nFollow artists to see their latest tracks and reposts.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ClassicFeedCard(item: items[index - 1]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: _buildContent(
          isLoading: state.isFollowingLoading,
          hasLoaded: state.hasLoadedFollowing,
          error: state.followingError,
          items: state.followingItems,
        ),
      ),
    );
  }
}
