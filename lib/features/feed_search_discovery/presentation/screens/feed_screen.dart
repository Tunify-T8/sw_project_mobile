import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/feed_notifier.dart';
import '../widgets/feed_tab_bar.dart';
import '../widgets/feed_track_card.dart';
import '../../domain/entities/feed_tab_type.dart';
import '../../domain/entities/feed_item_entity.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(_handleTabChange);

    Future.microtask(() {
      ref
          .read(feedNotifierProvider.notifier)
          .loadFeed(tab: FeedType.discover);
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    final notifier = ref.read(feedNotifierProvider.notifier);
    final state = ref.read(feedNotifierProvider);

    final discoverNeedsLoad =
        !state.hasLoadedDiscover && !state.isDiscoverLoading;
    final followingNeedsLoad =
        !state.hasLoadedFollowing && !state.isFollowingLoading;

    if (_tabController.index == 0 && discoverNeedsLoad) {
      notifier.loadFeed(tab: FeedType.discover);
    } else if (_tabController.index == 1 && followingNeedsLoad) {
      notifier.loadFeed(tab: FeedType.following);
    }
  }

  Widget _buildTabContent({
    required bool isLoading,
    required bool hasLoaded,
    required String? error,
    required List<FeedItemEntity> items,
    required String emptyMessage,
   required FeedType tabType, 
  }) {
    if (isLoading || !hasLoaded) {
      return Center(child: CircularProgressIndicator());
    } else if (error != null) {
      return Center(
        child: Text(error, style: TextStyle(color: Colors.white)),
      );
    } else if (items.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(color: Colors.white54),
        ),
      );
    } else {
      return PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: items.length,
        itemBuilder: (context, index) => FeedTrackCard(item: items[index], tabType: tabType,),
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedNotifierProvider);

    final discoverContent = _buildTabContent(
      isLoading: state.isDiscoverLoading,
      hasLoaded: state.hasLoadedDiscover,
      error: state.discoverError,
      items: state.discoverItems,
      emptyMessage: 'Nothing to discover yet',
      tabType: FeedType.discover,
    );

    final followingContent = _buildTabContent(
      isLoading: state.isFollowingLoading,
      hasLoaded: state.hasLoadedFollowing,
      error: state.followingError,
      items: state.followingItems,
      emptyMessage: 'Follow artists to see their tracks',
      tabType: FeedType.following
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [discoverContent, followingContent],
          ),
          Positioned(
            top: 65.0,
            left: 0.0,
            right: 0.0,
            child: Center(
              child: SizedBox(
                width: 220,
                child: FeedTabBar(controller: _tabController),
              ),
            ),
          ),
          Positioned(
            top: 65.0,
            left: 16.0,
            child: IconButton(
              onPressed: () {
                if (_tabController.index == 0) {
                  ref
                      .read(feedNotifierProvider.notifier)
                      .refreshFeed(tab: FeedType.discover);
                } else {
                  ref
                      .read(feedNotifierProvider.notifier)
                      .refreshFeed(tab: FeedType.following);
                }
              },
              icon: const Icon(Icons.refresh, color: Colors.white, size: 25),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
