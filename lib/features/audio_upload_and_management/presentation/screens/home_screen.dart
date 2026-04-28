import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/utils/adaptive_breakpoints.dart';
import '../../../followers_and_social_graph/presentation/providers/network_lists_notifier.dart';
import '../../../messaging_track_sharing/presentation/state/conversations_controller.dart';
import '../../../notifications/presentation/state/notifications_controller.dart';
import '../../../playback_streaming_engine/presentation/providers/listening_history_provider.dart';
import '../controllers/upload_flow_controller.dart';
import '../providers/home_tracks_provider.dart';
import '../providers/library_uploads_provider.dart';
import '../providers/upload_provider.dart';
import '../utils/upload_error_snackbar.dart';
import '../utils/upload_player_launcher.dart';
import '../widgets/home/home_discovery_sections.dart';
import '../widgets/home/home_recent_section.dart';
import '../widgets/home/home_track_highlights.dart';
import '../widgets/home/home_top_bar.dart';
import 'artist_home_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showAllTracks = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(uploadProvider, (_, next) {
      if (next.error != null && context.mounted) {
        showUploadErrorSnackBar(context, next.error!);
      }
    });

    if (_showAllTracks) {
      return HomeAllTracksView(
        onBack: () => setState(() => _showAllTracks = false),
        onOpenTrack: (item, queue) async {
          await openUploadItemPlayer(context, ref, item, queueItems: queue);
        },
      );
    }

    final libraryState = ref.watch(libraryUploadsProvider);
    final uploadState = ref.watch(uploadProvider);
    final historyAsync = ref.watch(listeningHistoryProvider);
    final hasUnreadMessages = ref.watch(
      conversationsControllerProvider.select((state) => state.totalUnread > 0),
    );
    final hasUnreadNotifications = ref.watch(
      notificationsControllerProvider.select((state) => state.unreadCount > 0),
    );
    final hasUnreadActivity = hasUnreadMessages || hasUnreadNotifications;
    final historyTracks = historyAsync.asData?.value.tracks ?? const [];
    final latestTrack = historyTracks.isNotEmpty
        ? null
        : (libraryState.items.isNotEmpty ? libraryState.items.first : null);
    final isDesktop = AdaptiveBreakpoints.isExpanded(context);
    final greeting = _homeGreeting(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: Colors.white,
        onRefresh: () async {
          await ref.read(libraryUploadsProvider.notifier).refresh();
          await ref.read(listeningHistoryProvider.notifier).refresh();
          await ref.read(networkListsProvider.notifier).loadSuggestedUsers();
          await ref.read(networkListsProvider.notifier).loadSuggestedArtists();
          ref.invalidate(homeTracksProvider);
          await ref.read(homeTracksProvider.future);
        },
        child: CustomScrollView(
          key: const PageStorageKey('home-scroll-v2'),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeader(
                isDesktop: isDesktop,
                isBusy: uploadState.isBusy,
                hasUnreadActivity: hasUnreadActivity,
                greeting: greeting,
                trackCount: libraryState.totalCount,
                recentCount: historyTracks.length,
                onOpenArtistHome: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ArtistHomeScreen(),
                    ),
                  );
                },
                onStartUpload: () => startUploadFlow(context, ref),
                onOpenMessaging: () {
                  Navigator.of(context).pushNamed(Routes.messagingActivity);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: AdaptiveCenter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 28 : 18,
                    isDesktop ? 18 : 6,
                    isDesktop ? 28 : 18,
                    12,
                  ),
                  child: const Text(
                    'Recently played',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AdaptiveCenter(
                child: CustomScrollView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  slivers: [
                    HomeRecentSection(
                      latestTrack: latestTrack,
                      historyTracks: historyTracks,
                      onOpenTrack: (item) async {
                        await openUploadItemPlayer(context, ref, item);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AdaptiveCenter(
                child: HomeTrackHighlights(
                  onSeeAll: () => setState(() => _showAllTracks = true),
                  onOpenTrack: (item, queue) async {
                    await openUploadItemPlayer(
                      context,
                      ref,
                      item,
                      queueItems: queue,
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AdaptiveCenter(
                child: CustomScrollView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  slivers: const [HomeDiscoverySections()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.isDesktop,
    required this.isBusy,
    required this.hasUnreadActivity,
    required this.greeting,
    required this.trackCount,
    required this.recentCount,
    required this.onOpenArtistHome,
    required this.onStartUpload,
    required this.onOpenMessaging,
  });

  final bool isDesktop;
  final bool isBusy;
  final bool hasUnreadActivity;
  final String greeting;
  final int trackCount;
  final int recentCount;
  final VoidCallback onOpenArtistHome;
  final VoidCallback onStartUpload;
  final VoidCallback onOpenMessaging;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: isDesktop ? 26 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        minimum: const EdgeInsets.only(top: 10),
        child: AdaptiveCenter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeTopBar(
                isBusy: isBusy,
                hasUnreadMessages: hasUnreadActivity,
                onOpenArtistHome: onOpenArtistHome,
                onStartUpload: onStartUpload,
                onOpenMessaging: onOpenMessaging,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 28 : 18,
                  isDesktop ? 20 : 14,
                  isDesktop ? 28 : 18,
                  4,
                ),
                child: isDesktop
                    ? _DesktopWelcome(
                        greeting: greeting,
                        trackCount: trackCount,
                        recentCount: recentCount,
                        onStartUpload: onStartUpload,
                      )
                    : Text(
                        greeting,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopWelcome extends StatelessWidget {
  const _DesktopWelcome({
    required this.greeting,
    required this.trackCount,
    required this.recentCount,
    required this.onStartUpload,
  });

  final String greeting;
  final int trackCount;
  final int recentCount;
  final VoidCallback onStartUpload;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Jump back into playback, manage uploads, and keep an eye on your activity.',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        _DesktopStatCard(
          label: 'Uploads',
          value: trackCount.toString(),
          icon: Icons.library_music_outlined,
        ),
        const SizedBox(width: 12),
        _DesktopStatCard(
          label: 'Recent plays',
          value: recentCount.toString(),
          icon: Icons.history_rounded,
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: onStartUpload,
          icon: const Icon(Icons.cloud_upload_outlined),
          label: const Text('Upload'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF5500),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

String _homeGreeting(DateTime now) {
  final hour = now.hour;
  if (hour < 5) return 'Good night';
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  if (hour < 22) return 'Good evening';
  return 'Good night';
}

class _DesktopStatCard extends StatelessWidget {
  const _DesktopStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF8A3D), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
