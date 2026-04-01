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
    final latestTrack = libraryState.items.isNotEmpty ? libraryState.items.first : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: Colors.white,
        onRefresh: () => ref.read(libraryUploadsProvider.notifier).refresh(),
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
                        onOpenArtistHome: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ArtistHomeScreen(),
                            ),
                          );
                        },
                        onStartUpload: () => startUploadFlow(context, ref),
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
                  'Picked for you',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            HomeRecentSection(
              latestTrack: latestTrack,
              onOpenTrack: (item) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TrackDetailScreen(item: item)),
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
