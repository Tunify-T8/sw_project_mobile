import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../followers_and_social_graph/presentation/providers/network_lists_notifier.dart';
import '../../../playback_streaming_engine/presentation/providers/listening_history_provider.dart';
import '../../../messaging_track_sharing/presentation/state/conversations_controller.dart';
import '../controllers/upload_flow_controller.dart';
import '../providers/library_uploads_provider.dart';
import '../providers/upload_provider.dart';
import '../utils/upload_error_snackbar.dart';
import '../utils/upload_player_launcher.dart';
import '../widgets/home/home_discovery_sections.dart';
import '../widgets/home/home_recent_section.dart';
import '../../../../core/routing/routes.dart';
import '../widgets/home/home_top_bar.dart';
import 'artist_home_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(uploadProvider, (_, next) {
      if (next.error != null && context.mounted) {
        showUploadErrorSnackBar(context, next.error!);
      }
    });

    final libraryState = ref.watch(libraryUploadsProvider);
    final uploadState = ref.watch(uploadProvider);
    final historyAsync = ref.watch(listeningHistoryProvider);
    final hasUnreadMessages = ref.watch(
      conversationsControllerProvider.select((state) => state.totalUnread > 0),
    );

    // Prefer the most recently played track for the "Picked for you" hero card.
    // Fall back to the most recent upload if history is empty/loading.
    final historyTracks =
        historyAsync.asData?.value.tracks ?? const [];
    final latestTrack = historyTracks.isNotEmpty
        ? null // history-based: handled inside HomeRecentSection
        : (libraryState.items.isNotEmpty ? libraryState.items.first : null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: Colors.white,
        onRefresh: () async {
          await ref.read(libraryUploadsProvider.notifier).refresh();
          await ref.read(listeningHistoryProvider.notifier).refresh();
          await ref.read(networkListsProvider.notifier).loadSuggestedUsers();
          await ref.read(networkListsProvider.notifier).loadSuggestedArtists();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeTopBar(
                        isBusy: uploadState.isBusy,
                        hasUnreadMessages: hasUnreadMessages,
                        onOpenArtistHome: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ArtistHomeScreen(),
                            ),
                          );
                        },
                        onStartUpload: () => startUploadFlow(context, ref),
                        onOpenMessaging: () {
                          Navigator.of(context)
                              .pushNamed(Routes.messagingActivity);
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(18, 8, 18, 4),
                        child: Text(
                          'Good evening',
                          style: TextStyle(
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
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 6, 18, 12),
                child: Text(
                  'Recently played',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            // Use history tracks for the recently-played grid when available.
            HomeRecentSection(
              latestTrack: latestTrack,
              historyTracks: historyTracks,
              onOpenTrack: (item) async {
                // Open the track playing — not just navigating to the screen.
                await openUploadItemPlayer(context, ref, item);
              },
            ),
            const HomeDiscoverySections(),
          ],
        ),
      ),
    );
  }
}