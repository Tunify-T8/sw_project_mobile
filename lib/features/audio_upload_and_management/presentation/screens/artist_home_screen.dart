import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/upload_flow_controller.dart';
import '../providers/library_uploads_provider.dart';
import '../providers/upload_provider.dart';
import '../widgets/artist_home/artist_home_app_bar.dart';
import '../widgets/artist_home/artist_home_credits_section.dart';
import '../widgets/artist_home/artist_home_dashboard_section.dart';
import '../widgets/artist_home/artist_home_latest_upload_section.dart';
import 'your_uploads_screen.dart';

class ArtistHomeScreen extends ConsumerStatefulWidget {
  const ArtistHomeScreen({super.key});

  @override
  ConsumerState<ArtistHomeScreen> createState() => _ArtistHomeScreenState();
}

class _ArtistHomeScreenState extends ConsumerState<ArtistHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => loadArtistDashboardData(ref));
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);
    final libraryState = ref.watch(libraryUploadsProvider);
    final latest = libraryState.items.isEmpty ? null : libraryState.items.first;
    final isBusy = uploadState.isPreparingUpload || uploadState.isUploading;
    final remainingMinutes = uploadState.quota?.uploadMinutesRemaining ?? 172;
    final totalMinutes = uploadState.quota?.uploadMinutesLimit ?? 180;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ArtistHomeAppBar(onBack: () => Navigator.of(context).pop()),
            const SizedBox(height: 6),
            ArtistHomeDashboardSection(
              isBusy: isBusy,
              onUpload: () => startUploadFlow(context, ref),
              onOpenUploads: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const YourUploadsScreen()),
                );
              },
            ),
            const SizedBox(height: 28),
            ArtistHomeLatestUploadSection(latest: latest),
            const SizedBox(height: 28),
            ArtistHomeCreditsSection(
              remainingMinutes: remainingMinutes,
              totalMinutes: totalMinutes,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
