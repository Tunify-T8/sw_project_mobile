import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router.dart';
import '../../data/services/global_track_store.dart';
import '../../domain/entities/upload_item.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../providers/track_detail_item_provider.dart';
import '../providers/track_detail_waveform_provider.dart';
import '../utils/playback_surface_item_mapper.dart';
import '../utils/upload_player_launcher.dart';
import '../widgets/track_detail/track_detail_background.dart';
import '../widgets/track_detail/track_detail_header.dart';
import '../widgets/track_detail/track_detail_more_sheet.dart';
import '../widgets/track_detail/track_detail_waveform_panel.dart';
import 'track_info_screen.dart';

class TrackDetailScreen extends ConsumerStatefulWidget {
  const TrackDetailScreen({super.key, required this.item});

  final UploadItem item;

  @override
  ConsumerState<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends ConsumerState<TrackDetailScreen> {
  late UploadItem _surfaceItem;
  bool _initializedPlayback = false;

  @override
  void initState() {
    super.initState();
    _surfaceItem = widget.item;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _initializedPlayback) return;
      _initializedPlayback = true;

      final playerState = ref.read(playerProvider).asData?.value;
      final alreadyHandlingThisTrack =
          playerState?.bundle?.trackId == _surfaceItem.id;

      if (!alreadyHandlingThisTrack) {
        await ensureUploadItemPlayback(ref, _surfaceItem, autoPlay: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant TrackDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _surfaceItem = widget.item;
      _initializedPlayback = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider).asData?.value;
    final store = ref.watch(globalTrackStoreProvider);
    final syncedItem = _resolveSyncedSurfaceItem(playerState, store);

    if (syncedItem != null && syncedItem.id != _surfaceItem.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _surfaceItem = syncedItem;
        });
      });
    }

    final baseItem = syncedItem ?? _surfaceItem;
    final resolvedItemAsync = ref.watch(trackDetailItemProvider(baseItem));
    final resolvedItem = resolvedItemAsync.asData?.value ?? baseItem;
    final waveformState = ref.watch(trackDetailWaveformProvider(resolvedItem));

    final activePlayer = playerState;
    final isCurrentTrack = activePlayer?.bundle?.trackId == resolvedItem.id;
    final isPlaying = isCurrentTrack && activePlayer?.isPlaying == true;
    final activeDurationSeconds = isCurrentTrack
        ? (activePlayer?.visualDurationSeconds ?? resolvedItem.durationSeconds)
        : resolvedItem.durationSeconds;
    final progress = isCurrentTrack
        ? (activePlayer?.normalizedProgress ?? 0.0)
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => toggleUploadItemPlayback(ref, resolvedItem),
              onHorizontalDragEnd: (details) async {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -220) {
                  await ref.read(playerProvider.notifier).next();
                } else if (velocity > 220) {
                  await ref.read(playerProvider.notifier).previous();
                }
              },
              child: TrackDetailBackground(
                item: resolvedItem,
                fallbackColor: const Color(0xFF4A4A76),
                progress: progress,
                isPlaying: isPlaying,
              ),
            ),
          ),
          TrackDetailHeader(
            item: resolvedItem,
            onDismiss: () => Navigator.of(context).pop(),
            onArtistTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.profile),
            onTrackInfoTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TrackInfoScreen(item: resolvedItem),
                ),
              );
            },
          ),
          TrackDetailWaveformPanel(
            item: resolvedItem,
            state: waveformState,
            onMoreTap: () =>
                showTrackDetailMoreSheet(context, ref, resolvedItem),
            onPlayPauseTap: () => toggleUploadItemPlayback(ref, resolvedItem),
            onSeekFraction: (fraction) => _seekToFraction(resolvedItem, fraction),
          ),
        ],
      ),
    );
  }

  UploadItem? _resolveSyncedSurfaceItem(
    PlayerState? playerState,
    GlobalTrackStore store,
  ) {
    if (playerState?.bundle == null) return null;

    return uploadItemFromPlayerState(playerState!, store);
  }

  Future<void> _seekToFraction(UploadItem item, double fraction) async {
    final playerState = ref.read(playerProvider).asData?.value;
    final duration = playerState?.bundle?.trackId == item.id
        ? playerState?.visualDurationSeconds ?? item.durationSeconds
        : item.durationSeconds;
    if (duration <= 0) return;
    final seconds = (duration * fraction.clamp(0.0, 1.0)).round();
    await ref.read(playerProvider.notifier).seek(seconds);
  }
}
