import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/feed_tab_type.dart';
import '../../domain/entities/feed_item_entity.dart';
import '../providers/feed_notifier.dart';
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
        ref.read(feedNotifierProvider.notifier).loadFeed(tab: FeedType.classic);
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
      return Center(
        child: Text(error, style: const TextStyle(color: Colors.white)),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(feedNotifierProvider.notifier)
            .refreshFeed(tab: FeedType.classic);
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
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
