import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/navigation_utils.dart';
import '../../data/services/global_track_store.dart';
import '../../domain/entities/upload_item.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../../playback_streaming_engine/presentation/screens/queue_screen.dart';
import '../../../playback_streaming_engine/presentation/utils/track_artist_resolver.dart';
import '../providers/track_detail_item_provider.dart';
import '../providers/track_detail_waveform_provider.dart';
import '../utils/playback_surface_item_mapper.dart';
import '../utils/upload_player_launcher.dart';
import '../../../playback_streaming_engine/presentation/widgets/track_options_sheet.dart';
import '../widgets/track_detail/track_detail_background.dart';
import '../widgets/track_detail/track_detail_header.dart';
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
  bool _allowPlayerTrackSwitchSync = false;

  @override
  void initState() {
    super.initState();
    _surfaceItem = widget.item;
  }

  @override
  void didUpdateWidget(covariant TrackDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _surfaceItem = widget.item;
      _allowPlayerTrackSwitchSync = false;
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
          _allowPlayerTrackSwitchSync = false;
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
                  _allowPlayerTrackSwitchSync = true;
                  await ref.read(playerProvider.notifier).next();
                } else if (velocity > 220) {
                  _allowPlayerTrackSwitchSync = true;
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
            onArtistTap: () async {
              final artistId = await resolveArtistIdForTrack(
                ref,
                resolvedItem.id,
              );
              if (artistId == null || artistId.isEmpty) return;

              final currentUserId = ref.read(authControllerProvider).value?.id;
              if (!mounted) return;
              navigateToProfile(
                context,
                artistId,
                currentUserId: currentUserId,
              );
            },
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
            onMoreTap: () {
              showTrackOptionsSheet(
                context,
                info: _trackOptionInfoFor(resolvedItem),
                ref: ref,
              );
            },
            onShareTap: () {
              showTrackShareSheet(
                context,
                info: _trackOptionInfoFor(resolvedItem),
                ref: ref,
              );
            },
            onQueueTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const QueueScreen())),
            onPlayPauseTap: () => toggleUploadItemPlayback(ref, resolvedItem),
            onPreviousTap: () async {
              _allowPlayerTrackSwitchSync = true;
              await ref.read(playerProvider.notifier).previous();
            },
            onNextTap: () async {
              _allowPlayerTrackSwitchSync = true;
              await ref.read(playerProvider.notifier).next();
            },
            onSeekFraction: (fraction) =>
                _seekToFraction(resolvedItem, fraction),
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

    final currentTrackId = playerState!.bundle!.trackId;
    if (currentTrackId != _surfaceItem.id && !_allowPlayerTrackSwitchSync) {
      return null;
    }

    return uploadItemFromPlayerState(playerState, store);
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

  TrackOptionInfo _trackOptionInfoFor(UploadItem item) {
    final bundle = ref.read(playerProvider).asData?.value.bundle;
    final artistId =
        (bundle?.trackId == item.id && bundle!.artist.id.trim().isNotEmpty)
        ? bundle.artist.id
        : null;

    return TrackOptionInfo.fromTrackId(
      item.id,
      ref,
      fallbackTitle: item.title,
      fallbackArtist: item.artistDisplay,
      fallbackCoverUrl: item.artworkUrl,
      fallbackLocalArtworkPath: item.localArtworkPath,
      fallbackArtistId: artistId,
      fallbackPrivateToken: item.privateToken,
    );
  }
}
