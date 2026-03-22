// Upload Feature Guide:
// Purpose: Home screen variant that exposes upload entry points and discovery sections.
// Used by: Opened from routing or parent navigation flows.
// Concerns: Supporting UI and infrastructure for upload and track management.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/upload_flow_controller.dart';
import '../providers/library_uploads_provider.dart';
import '../providers/upload_provider.dart';
import '../utils/upload_error_snackbar.dart';
import '../widgets/home/home_discovery_sections.dart';
import '../widgets/home/home_recent_section.dart';
import '../widgets/home/home_top_bar.dart';
import 'artist_home_screen.dart';
import 'track_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => loadArtistDashboardData(ref));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(uploadProvider, (_, next) {
      if (next.error != null && mounted) {
        showUploadErrorSnackBar(context, next.error!);
      }
    });
    ref.listen(libraryUploadsProvider, (_, next) {
      if (next.error != null && mounted) {
        showUploadErrorSnackBar(context, next.error!);
      }
    });

    final uploadState = ref.watch(uploadProvider);
    final libraryState = ref.watch(libraryUploadsProvider);
    final latestTrack = libraryState.items.isEmpty
        ? null
        : libraryState.items.first;
    final isBusy = uploadState.isBusy;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: HomeTopBar(
                isBusy: isBusy,
                onOpenArtistHome: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ArtistHomeScreen()),
                  );
                },
                onStartUpload: () => startUploadFlow(context, ref),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Get back to it',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            HomeRecentSection(
              latestTrack: latestTrack,
              onOpenTrack: (item) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TrackDetailScreen(item: item),
                  ),
                );
              },
            ),
            const HomeDiscoverySections(),
          ],
        ),
      ),
    );
  }
}
