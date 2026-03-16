import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_item.dart';
import '../providers/library_uploads_provider.dart';
import '../providers/upload_dependencies_provider.dart';
import '../providers/upload_provider.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/upload_state.dart';
import '../utils/upload_auth_guard.dart';
import 'track_metadata_screen.dart';
import 'your_uploads_screen.dart';

/// Artist Home screen — opened by tapping the "Artist Home" pill on the main Home tab.
/// Matches SoundCloud screenshot exactly:
///  ← back arrow   "Artist Home" title (centered)   (no top-right icons here)
///  Purple "Upload a track" full-width button
///  Insights / Uploads 2-column grid
///  "Latest upload" section with track tile + ···
///  "Your remaining credits" 3-card row (Amplify, Upload time, Replace file)
class ArtistHomeScreen extends ConsumerStatefulWidget {
  const ArtistHomeScreen({super.key});
  @override
  ConsumerState<ArtistHomeScreen> createState() => _ArtistHomeScreenState();
}

class _ArtistHomeScreenState extends ConsumerState<ArtistHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = ref.read(currentUploadUserIdProvider);
      ref.read(uploadProvider.notifier).loadQuota(userId);
      ref.read(libraryUploadsProvider.notifier).load();
    });
  }

  bool _isBusy(UploadState s) => s.isPreparingUpload || s.isUploading;

Future<void> _startUpload() async {
  final canUpload = await ensureUploadAuthenticated(context, ref);
  if (!canUpload) return;

  final userId = ref.read(currentUploadUserIdProvider);
  final track = await ref
      .read(uploadProvider.notifier)
      .pickAudioCreateDraftAndStartUpload(userId);

  if (!mounted || track == null) return;

  final name = ref.read(uploadProvider).selectedAudio?.name ?? 'Audio file';

  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => TrackMetadataScreen(
        trackId: track.trackId,
        fileName: name,
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
    final isBusy = _isBusy(uploadState);
    final latest = libraryState.items.isEmpty ? null : libraryState.items.first;
    final remaining = uploadState.quota?.uploadMinutesRemaining ?? 172;
    final limit = uploadState.quota?.uploadMinutesLimit ?? 180;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Artist Home',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 48), // balance for back button
                ],
              ),
            ),
            const SizedBox(height: 6),

            // ── Upload a track button ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: isBusy ? null : _startUpload,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3D1466), Color(0xFF6B1FA3)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isBusy)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: Colors.white),
                        )
                      else
                        const Icon(Icons.cloud_upload_outlined,
                            color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        isBusy ? 'Uploading...' : 'Upload a track',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Insights / Uploads ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _DarkCard(
                      icon: Icons.show_chart,
                      label: 'Insights',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DarkCard(
                      icon: Icons.graphic_eq,
                      label: 'Uploads',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => YourUploadsScreen(
                            onStartUpload: _startUpload,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Latest upload ─────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Latest upload',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: latest == null
                  ? _EmptyLatest()
                  : _LatestTile(item: latest),
            ),
            const SizedBox(height: 28),

            // ── Your remaining credits ────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Your remaining credits',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _CreditCard(
                      icon: Icons.bolt,
                      iconColor: const Color(0xFFBB86FC),
                      label: 'Amplify',
                      subText: 'TRY IT',
                      isLink: true,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CreditCard(
                      icon: Icons.cloud_upload,
                      iconColor: const Color(0xFF4FC3F7),
                      label: 'Upload time',
                      subText: '$remaining/$limit mins left',
                      isLink: false,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CreditCard(
                      icon: Icons.swap_horiz,
                      iconColor: const Color(0xFF4FC3F7),
                      label: 'Replace file',
                      subText: 'TRY IT',
                      isLink: true,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _DarkCard extends StatelessWidget {
  const _DarkCard({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _LatestTile extends StatelessWidget {
  const _LatestTile({required this.item});
  final UploadItem item;

  @override
  Widget build(BuildContext context) {
    final hasLocal = item.localArtworkPath != null &&
        File(item.localArtworkPath!).existsSync();
    final hasRemote = item.artworkUrl != null && item.artworkUrl!.startsWith('http');
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 48,
              height: 48,
              color: const Color(0xFF3A4A5A),
              child: hasLocal
                  ? Image.file(File(item.localArtworkPath!),
                      fit: BoxFit.cover, width: 48, height: 48)
                  : hasRemote
                      ? Image.network(
                          item.artworkUrl!,
                          fit: BoxFit.cover,
                          width: 48,
                          height: 48,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.account_circle_rounded,
                            color: Color(0xFF4872D7),
                            size: 38,
                          ),
                        )
                      : const Icon(Icons.account_circle_rounded,
                          color: Color(0xFF4872D7), size: 38),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Text(item.durationLabel,
                    style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.more_horiz, color: Colors.white54, size: 22),
        ],
      ),
    );
  }
}

class _EmptyLatest extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            const Text('No uploads yet', style: TextStyle(color: Colors.white54)),
      );
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subText,
    required this.isLink,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subText;
  final bool isLink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              subText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                decoration: isLink ? TextDecoration.underline : null,
                decorationColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
