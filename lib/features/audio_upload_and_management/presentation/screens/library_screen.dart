import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/network_list_type.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/screens/network_lists_screen.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/listening_history_provider.dart';

import '../../../../core/design_system/colors.dart';
import '../../../playback_streaming_engine/domain/entities/history_track.dart';
import '../../../playback_streaming_engine/domain/entities/playback_status.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../../playback_streaming_engine/presentation/screens/listening_history_screen.dart';
import '../../data/services/global_track_store.dart';
import '../../domain/entities/upload_item.dart';
import '../utils/playback_surface_item_mapper.dart';
import '../utils/upload_player_launcher.dart';
import 'your_uploads_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({
    super.key,
    this.onOpenSettings,
    this.onOpenProfile,
    this.onStartUpload,
    this.onOpenSubscription,
    this.onOpenYourUploads,
  });

  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onStartUpload;
  final VoidCallback? onOpenSubscription;
  final VoidCallback? onOpenYourUploads;

  static const _menuItems = [
    'Your likes',
    'Playlists',
    'Albums',
    'Following',
    'Stations',
    'Your insights',
    'Your uploads',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(listeningHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'Library',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onOpenSettings,
                      icon: const Icon(Icons.settings_outlined),
                      color: Colors.white,
                    ),
                    GestureDetector(
                      onTap: onOpenProfile,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE7E7E7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final label = _menuItems[index];
                return InkWell(
                  onTap: () => _handleTap(context, label),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white70,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Listening history',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ListeningHistoryScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'See all',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            historyAsync.when(
              data: (state) {
                final tracks = state.tracks.take(4).toList();
                if (tracks.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(18, 0, 18, 120),
                      child: Text(
                        'Nothing played yet',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return _LibraryHistoryTile(
                      track: track,
                      queueTracks: state.tracks,
                    );
                  },
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 0, 18, 120),
                  child: Text(
                    'Could not load listening history',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, String label) {
    if (label == 'Following') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const NetworkListsScreen(
            userId: 'u2',
            listType: NetworkListType.following,
          ),
        ),
      );
      return;
    }

    if (label == 'Your uploads') {
      if (onOpenYourUploads != null) {
        onOpenYourUploads!();
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => YourUploadsScreen(
            onStartUpload: onStartUpload,
            onOpenSubscription: onOpenSubscription,
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1C1C1E),
        content: Text('$label coming soon'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _LibraryHistoryTile extends ConsumerWidget {
  const _LibraryHistoryTile({
    required this.track,
    required this.queueTracks,
  });

  final HistoryTrack track;
  final List<HistoryTrack> queueTracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(globalTrackStoreProvider);
    final stored = storedUploadItemForTrack(store, track.trackId);
    final isBlocked = track.status == PlaybackStatus.blocked;

    return InkWell(
      onTap: isBlocked
          ? null
          : () async {
              final trackIds =
                  queueTracks.map((item) => item.trackId).toList(growable: false);
              final currentIndex = trackIds.indexOf(track.trackId);

              if (stored != null) {
                final queueItems = queueTracks
                    .map((item) => storedUploadItemForTrack(store, item.trackId))
                    .whereType<UploadItem>()
                    .toList(growable: false);
                await openUploadItemPlayer(
                  context,
                  ref,
                  stored,
                  queueItems: queueItems.isEmpty ? null : queueItems,
                  openScreen: true,
                );
                return;
              }

              await ref.read(playerProvider.notifier).loadTrackWithQueue(
                    trackId: track.trackId,
                    trackIds: trackIds,
                    currentIndex: currentIndex < 0 ? 0 : currentIndex,
                    autoPlay: true,
                  );
              if (!context.mounted) return;
              await openCurrentPlaybackTrackSurface(context, ref);
            },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 58,
                height: 58,
                color: const Color(0xFF202020),
                child: (track.coverUrl?.isNotEmpty == true)
                    ? Image.network(
                        track.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(isBlocked),
                      )
                    : _placeholder(isBlocked),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isBlocked ? Colors.white38 : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '▶ ${_formatPlayCount(track.playCount)} · ${_fmt(track.durationSeconds)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.more_horiz, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(bool isBlocked) {
    return Center(
      child: Icon(
        isBlocked ? Icons.lock : Icons.music_note,
        color: isBlocked ? Colors.redAccent.withOpacity(0.6) : Colors.white24,
      ),
    );
  }

  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  String _formatPlayCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }
}
