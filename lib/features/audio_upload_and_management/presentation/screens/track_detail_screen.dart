import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router.dart';
import '../../../../core/design_system/colors.dart';
import '../../data/services/global_track_store.dart';
import '../../domain/entities/upload_item.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../../playback_streaming_engine/presentation/screens/queue_screen.dart';
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
  const TrackDetailScreen({
    super.key,
    required this.item,
  });

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
    final isBuffering = isCurrentTrack && (activePlayer?.isBuffering ?? false);
    final currentUser = ref.watch(authControllerProvider).asData?.value;
    final showFollowAction = !_isOwnTrack(
      resolvedItem,
      activePlayer,
      store,
      currentUserId: currentUser?.id,
      currentUsername: currentUser?.username,
    );
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
            onArtistTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.profile),
            onTrackInfoTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TrackInfoScreen(item: resolvedItem),
                ),
              );
            },
            showFollowAction: showFollowAction,
          ),
          TrackDetailWaveformPanel(
            item: resolvedItem,
            state: waveformState,
            onMoreTap: () {
              final bundle =
                  ref.read(playerProvider).asData?.value.bundle;
              final artistId =
                  (bundle?.trackId == resolvedItem.id &&
                          bundle!.artist.id.trim().isNotEmpty)
                      ? bundle.artist.id
                      : null;
              showTrackOptionsSheet(
                context,
                info: TrackOptionInfo.fromTrackId(
                  resolvedItem.id,
                  ref,
                  fallbackTitle: resolvedItem.title,
                  fallbackArtist: resolvedItem.artistDisplay,
                  fallbackCoverUrl: resolvedItem.artworkUrl,
                  fallbackLocalArtworkPath: resolvedItem.localArtworkPath,
                  fallbackArtistId: artistId,
                ),
                ref: ref,
              );
            },
            onQueueTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const QueueScreen()),
            ),
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
          if (isBuffering)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.8,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                ),
              ),
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

  bool _isOwnTrack(
    UploadItem item,
    PlayerState? playerState,
    GlobalTrackStore store, {
    required String? currentUserId,
    required String? currentUsername,
  }) {
    final trimmedCurrentUserId = currentUserId?.trim();
    final normalizedCurrentUsername = currentUsername?.trim().toLowerCase();
    if (trimmedCurrentUserId == null || trimmedCurrentUserId.isEmpty) {
      return false;
    }

    final bundle = playerState?.bundle;
    if (bundle != null && bundle.trackId == item.id) {
      final bundleArtistId = bundle.artist.id.trim();
      if (bundleArtistId.isNotEmpty && bundleArtistId == trimmedCurrentUserId) {
        return true;
      }

      final bundleUsername = bundle.artist.username?.trim().toLowerCase();
      if (normalizedCurrentUsername != null &&
          normalizedCurrentUsername.isNotEmpty &&
          bundleUsername != null &&
          bundleUsername.isNotEmpty &&
          bundleUsername == normalizedCurrentUsername) {
        return true;
      }
    }

    final storeOwner = store.ownerUserIdForTrack(item.id)?.trim();
    if (storeOwner != null &&
        storeOwner.isNotEmpty &&
        storeOwner != '__global__' &&
        storeOwner == trimmedCurrentUserId) {
      return true;
    }

    return false;
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
