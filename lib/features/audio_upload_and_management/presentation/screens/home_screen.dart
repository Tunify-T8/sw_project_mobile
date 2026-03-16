import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_item.dart';
import '../providers/library_uploads_provider.dart';
import '../providers/upload_dependencies_provider.dart';
import '../providers/upload_provider.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/upload_state.dart';
import 'track_detail_screen.dart';
import 'track_metadata_screen.dart';
import 'artist_home_screen.dart';

/// Main SoundCloud Home tab.
/// Top-left: "Artist Home" pill button → pushes ArtistHomeScreen.
/// Top-right: cloud-upload icon — when tapped, spinner rings it while picking/uploading,
///            then navigates to TrackMetadataScreen.
/// Sections: Get back to it (2×2 grid), Made for you, Liked By.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = ref.read(currentUploadUserIdProvider);
      ref.read(uploadProvider.notifier).loadQuota(userId);
      ref.read(libraryUploadsProvider.notifier).load();
    });
  }

  bool _isUploadBusy(UploadState uploadState) =>
      uploadState.isPreparingUpload || uploadState.isUploading;

 Future<void> _startUpload() async {
  final userId = ref.read(currentUploadUserIdProvider);
  final track = await ref
      .read(uploadProvider.notifier)
      .pickAudioCreateDraftAndStartUpload(userId);

  if (!mounted || track == null) return;

  final audioName =
      ref.read(uploadProvider).selectedAudio?.name ?? 'Audio file';

  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => TrackMetadataScreen(
        trackId: track.trackId,
        fileName: audioName,
      ),
    ),
  );

  if (result == true && mounted) {
    await ref.read(libraryUploadsProvider.notifier).refresh();
  }
}

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);
    final libraryState = ref.watch(libraryUploadsProvider);
    final isBusy = _isUploadBusy(uploadState);
    final latestTrack =
        libraryState.items.isEmpty ? null : libraryState.items.first;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top bar ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Artist Home pill button
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ArtistHomeScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.graphic_eq,
                                color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text('Artist Home',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Cloud upload icon with thin spinner ring when busy
                    GestureDetector(
                      onTap: isBusy ? null : _startUpload,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isBusy)
                              const SizedBox(
                                width: 38,
                                height: 38,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.white,
                                ),
                              ),
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: isBusy ? Colors.white54 : Colors.white,
                              size: 26,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Messages icon
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(Icons.chat_bubble_outline,
                          color: Colors.white, size: 26),
                    ),
                  ],
                ),
              ),
            ),

            // ── Get back to it ────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text('Get back to it',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3.2,
                ),
                delegate: SliverChildListDelegate([
                  if (latestTrack != null) ...[
                    _RecentCard(
                      item: latestTrack,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => TrackDetailScreen(item: latestTrack))),
                    ),
                    _PlaceholderCard(label: 'stateside + z...', sub: '⚙ ·=·♦'),
                    _PlaceholderCard(
                        label: 'Pop Fit Workout', sub: 'Discovery Playl...'),
                    _PlaceholderCard(label: 'Your Side Again', sub: 'Yungex 69'),
                  ] else ...[
                    _PlaceholderCard(label: 'Ocean Eyes', sub: 'Billie Eilish'),
                    _PlaceholderCard(label: 'stateside + z...', sub: '⚙ ·=·♦'),
                    _PlaceholderCard(
                        label: 'Pop Fit Workout', sub: 'Discovery Playl...'),
                    _PlaceholderCard(label: 'Your Side Again', sub: 'Yungex 69'),
                  ],
                ]),
              ),
            ),

            // ── Made for you ─────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text('Made for you',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  children: [
                    _MadeForYouCard(
                      color: const Color(0xFF1A2A5A),
                      label: 'DAILY',
                      labelBold: 'DROPS',
                      sub: 'New releases based on your taste. Updated every day',
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    _MadeForYouCard(
                      color: const Color(0xFF5A1A2A),
                      label: 'WEEKLY',
                      labelBold: 'WAVE',
                      sub:
                          'The best of SoundCloud just for you. Updated every Monday',
                      onTap: () {},
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),

            // ── Liked by ──────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text('Liked By',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  children: [
                    _LikedByCard(label: 'Billie Eilish', onTap: () {}),
                    const SizedBox(width: 12),
                    _LikedByCard(label: 'Ice Spice', onTap: () {}),
                    const SizedBox(width: 12),
                    _LikedByCard(label: 'MWB Chico', onTap: () {}),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

// ── Recent track card (matches SoundCloud 2-column grid style) ─────────────

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.item, required this.onTap});
  final UploadItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasFile = item.localArtworkPath != null &&
        File(item.localArtworkPath!).existsSync();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(6)),
              child: Container(
                width: 48,
                color: const Color(0xFF3A4A5A),
                child: hasFile
                    ? Image.file(File(item.localArtworkPath!),
                        fit: BoxFit.cover, height: double.infinity)
                    : const Icon(Icons.person,
                        color: Color(0xFF6A8AAA), size: 28),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text(item.artistDisplay,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.label, required this.sub});
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF2A3A4A),
              borderRadius:
                  BorderRadius.horizontal(left: Radius.circular(6)),
            ),
            child: const Icon(Icons.music_note,
                color: Color(0xFF4A6A8A), size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MadeForYouCard extends StatelessWidget {
  const _MadeForYouCard(
      {required this.color,
      required this.label,
      required this.labelBold,
      required this.sub,
      required this.onTap});
  final Color color;
  final String label;
  final String labelBold;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: color.withOpacity(0.7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic)),
                    const SizedBox(width: 4),
                    Text(labelBold,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(sub,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _LikedByCard extends StatelessWidget {
  const _LikedByCard({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          children: [
            Container(
              height: 110,
              width: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF1C2A3A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      children: [
                        const Text('LIKED BY',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 9,
                                letterSpacing: 0.5)),
                        const SizedBox(width: 4),
                        const Icon(Icons.cloud,
                            color: Colors.white38, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            const Text('Liked by',
                style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
