import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../../audio_upload_and_management/data/services/global_track_store.dart';
import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../audio_upload_and_management/presentation/utils/playback_surface_item_mapper.dart';
import '../../../audio_upload_and_management/presentation/utils/upload_player_launcher.dart';
import '../../domain/entities/history_track.dart';
import '../../domain/entities/playback_status.dart';
import '../providers/listening_history_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/mini_player.dart';

class ListeningHistoryScreen extends ConsumerWidget {
  const ListeningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(listeningHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const MiniPlayer(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Listening history',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white38, size: 52),
              const SizedBox(height: 16),
              const Text(
                'Failed to load history',
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(listeningHistoryProvider.notifier).refresh(),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        data: (state) {
          if (state.tracks.isEmpty) return const _EmptyHistory();

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: const Color(0xFF1A1A1A),
            onRefresh: () =>
                ref.read(listeningHistoryProvider.notifier).refresh(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.extentAfter < 200) {
                  ref.read(listeningHistoryProvider.notifier).loadMore();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 22),
                itemCount: state.tracks.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.tracks.length) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }
                  return _HistoryTrackTile(
                    track: state.tracks[index],
                    onTap: () => _openTrack(
                      context,
                      ref,
                      state.tracks,
                      state.tracks[index],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openTrack(
    BuildContext context,
    WidgetRef ref,
    List<HistoryTrack> historyTracks,
    HistoryTrack track,
  ) async {
    if (track.status == PlaybackStatus.blocked) return;

    final trackIds = historyTracks.map((item) => item.trackId).toList(growable: false);
    final currentIndex = trackIds.indexOf(track.trackId);
    final store = ref.read(globalTrackStoreProvider);
    final stored = storedUploadItemForTrack(store, track.trackId);

    if (stored != null) {
      final queueItems = _storedQueueItems(store, historyTracks);
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
  }

  List<UploadItem> _storedQueueItems(
    GlobalTrackStore store,
    List<HistoryTrack> historyTracks,
  ) {
    return historyTracks
        .map((track) => storedUploadItemForTrack(store, track.trackId))
        .whereType<UploadItem>()
        .toList(growable: false);
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: Colors.white24, size: 72),
          SizedBox(height: 20),
          Text(
            'No listening history',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tracks you play will appear here',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _HistoryTrackTile extends StatelessWidget {
  const _HistoryTrackTile({required this.track, required this.onTap});

  final HistoryTrack track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBlocked = track.status == PlaybackStatus.blocked;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: isBlocked ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
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
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '▶ ${_formatPlayCount(track.playCount)} · ${_fmtDuration(track.durationSeconds)}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
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

  String _fmtDuration(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

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
