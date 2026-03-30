import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/feed_notifier.dart';
import '../widgets/feed_tab_bar.dart';
import '../widgets/feed_track_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(feedNotifierProvider.notifier).loadFollowingFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedNotifierProvider);

    Widget followingContent;

    if (state.isLoading) {
      followingContent = Center(child: CircularProgressIndicator());
    } else if (state.error != null) {
      followingContent = Center(
        child: Text(state.error!, style: TextStyle(color: Colors.white)),
      );
    } else {
      followingContent = PageView.builder(
        scrollDirection: Axis.vertical, 
        itemCount: state.feedItems.length,
        itemBuilder: (context, index) {
          return FeedTrackCard(item: state.feedItems[index]);
        },
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        body: Stack(
          children: [
            TabBarView(
              children: [
                const Center(
                  child: Text(
                    'Coming soon',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                followingContent,
              ],
            ),
            Positioned(
              top: 65.0,
              left: 0.0,
              right: 0.0,
              child: Center(child: SizedBox(width: 220, child: FeedTabBar())),
            ),
          ],
        ),
      ),
    );
  }
}
