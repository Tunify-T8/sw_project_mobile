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

part 'listening_history_screen_actions.dart';
part 'listening_history_screen_widgets.dart';

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
}
