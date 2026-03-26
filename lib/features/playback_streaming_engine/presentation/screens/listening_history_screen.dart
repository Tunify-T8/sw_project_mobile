import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/history_track.dart';
import '../providers/listening_history_provider.dart';
import '../providers/player_provider.dart';
import '../../domain/entities/playback_context_request.dart';
import '../../domain/entities/playback_status.dart';

class ListeningHistoryScreen extends ConsumerWidget {
  const ListeningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(listeningHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Listening History',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () =>
                ref.read(listeningHistoryProvider.notifier).refresh(),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.orange)),
        error: (e, _) => Center(
          child: Text(
            'Failed to load history\n$e',
            style: const TextStyle(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ),
        data: (state) {
          if (state.tracks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, color: Colors.white24, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'No listening history yet',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification &&
                  notification.metrics.extentAfter < 200) {
                ref.read(listeningHistoryProvider.notifier).loadMore();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: state.tracks.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.tracks.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    ),
                  );
                }
                return _HistoryTrackTile(
                  track: state.tracks[index],
                  onTap: () => _playTrack(context, ref, state.tracks[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _playTrack(
    BuildContext context,
    WidgetRef ref,
    HistoryTrack track,
  ) async {
    if (track.status == PlaybackStatus.blocked) return;
    await ref.read(playerProvider.notifier).loadTrack(track.trackId);
  }
}

// ---------------------------------------------------------------------------
// Tile widget
// ---------------------------------------------------------------------------

class _HistoryTrackTile extends StatelessWidget {
  const _HistoryTrackTile({required this.track, required this.onTap});

  final HistoryTrack track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBlocked = track.status == PlaybackStatus.blocked;

    return ListTile(
      onTap: isBlocked ? null : onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 48,
          height: 48,
          color: Colors.grey[850],
          child: Icon(
            isBlocked ? Icons.lock : Icons.music_note,
            color: isBlocked ? Colors.red[300] : Colors.white38,
          ),
        ),
      ),
      title: Text(
        track.title,
        style: TextStyle(
          color: isBlocked ? Colors.white38 : Colors.white,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${track.artist.name} · ${_formatDuration(track.durationSeconds)}',
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: Text(
        _timeAgo(track.playedAt),
        style: const TextStyle(color: Colors.white38, fontSize: 11),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _timeAgo(DateTime playedAt) {
    final diff = DateTime.now().difference(playedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
