import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../playback_streaming_engine/domain/entities/playback_status.dart';
import '../../../playback_streaming_engine/domain/entities/player_seed_track.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../data/services/global_track_store.dart';
import '../../domain/entities/upload_item.dart';
import '../providers/track_detail_item_provider.dart';
import '../providers/track_detail_waveform_provider.dart';
import '../screens/track_detail_screen.dart';
import 'playback_surface_item_mapper.dart';

Future<void> openUploadItemPlayer(
  BuildContext context,
  WidgetRef ref,
  UploadItem item, {
  List<UploadItem>? queueItems,
  bool openScreen = true,
}) async {
  if (!item.isPlayable) return;

  final hydratedItem = await prepareTrackSurfaceItem(ref, item);

  await ensureUploadItemPlayback(
    ref,
    hydratedItem,
    queueItems: queueItems,
    autoPlay: true,
  );

  if (!openScreen || !context.mounted) return;
  await Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => TrackDetailScreen(item: hydratedItem),
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 340),
    ),
  );
}

Future<UploadItem> prepareTrackSurfaceItem(WidgetRef ref, UploadItem item) async {
  UploadItem resolvedItem = item;

  try {
    resolvedItem = await ref.read(trackDetailItemProvider(item).future);
  } catch (_) {
    resolvedItem = item;
  }

  try {
    final bars = await ref.read(trackDetailWaveformBarsProvider(resolvedItem).future);
    if (bars != null && bars.isNotEmpty) {
      resolvedItem = resolvedItem.copyWith(waveformBars: bars);
    }
  } catch (_) {
    // Keep the already-resolved metadata even if waveform preloading fails.
  }

  return resolvedItem;
}

Future<void> ensureUploadItemPlayback(
  WidgetRef ref,
  UploadItem item, {
  List<UploadItem>? queueItems,
  bool autoPlay = true,
}) async {
  if (!item.isPlayable) return;

  final notifier = ref.read(playerProvider.notifier);
  final current = ref.read(playerProvider).asData?.value;
  final isSameTrack = current?.bundle?.trackId == item.id;
  final store = ref.read(globalTrackStoreProvider);
  final queue = _resolveArtistQueue(item, queueItems, store);
  final queueIds = queue.map((track) => track.id).toList();
  final currentIndex = queueIds.indexOf(item.id);

  final seedTrack = PlayerSeedTrack(
    trackId: item.id,
    title: item.title,
    artistName: item.artistDisplay,
    durationSeconds: item.durationSeconds,
    coverUrl: item.artworkUrl,
    waveformUrl: item.waveformUrl,
    directAudioUrl: item.audioUrl,
    localFilePath: item.localFilePath,
  );

  if (isSameTrack) {
    final hasUsefulQueue = (current?.queue?.trackIds.length ?? 0) > 1;
    if (!hasUsefulQueue && currentIndex >= 0 && queueIds.length > 1) {
      await notifier.loadTrackWithQueue(
        trackId: item.id,
        trackIds: queueIds,
        currentIndex: currentIndex,
        repeat: RepeatMode.all,
        autoPlay: autoPlay || current?.isPlaying == true,
        seedTrack: seedTrack,
      );
      return;
    }

    if (autoPlay && current?.isPlaying != true) {
      await notifier.play();
    }
    return;
  }

  if (currentIndex >= 0 && queueIds.length > 1) {
    await notifier.loadTrackWithQueue(
      trackId: item.id,
      trackIds: queueIds,
      currentIndex: currentIndex,
      repeat: RepeatMode.all,
      autoPlay: autoPlay,
      seedTrack: seedTrack,
    );
    return;
  }

  await notifier.loadTrack(
    item.id,
    autoPlay: autoPlay,
    seedTrack: seedTrack,
  );
}

Future<void> toggleUploadItemPlayback(
  WidgetRef ref,
  UploadItem item, {
  List<UploadItem>? queueItems,
}) async {
  final current = ref.read(playerProvider).asData?.value;
  final notifier = ref.read(playerProvider.notifier);

  if (current?.bundle?.trackId == item.id) {
    if (current?.isPlaying == true) {
      await notifier.pause();
    } else {
      await notifier.play();
    }
    return;
  }

  await ensureUploadItemPlayback(
    ref,
    item,
    queueItems: queueItems,
    autoPlay: true,
  );
}

Future<void> openCurrentPlaybackTrackSurface(
  BuildContext context,
  WidgetRef ref,
) async {
  final current = ref.read(playerProvider).asData?.value;
  if (current?.bundle == null) return;
  if (current!.bundle!.playability.status == PlaybackStatus.blocked) return;

  final store = ref.read(globalTrackStoreProvider);
  final rawItem = uploadItemFromPlayerState(current, store);
  final hydratedItem = await prepareTrackSurfaceItem(ref, rawItem);

  if (!context.mounted) return;
  await Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => TrackDetailScreen(item: hydratedItem),
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 340),
    ),
  );
}

List<UploadItem> _resolveArtistQueue(
  UploadItem item,
  List<UploadItem>? queueItems,
  GlobalTrackStore store,
) {
  final explicitQueue = (queueItems ?? const <UploadItem>[])
      .where((track) => track.isPlayable)
      .toList();
  if (explicitQueue.isNotEmpty) {
    return explicitQueue;
  }

  final sameArtist = store.all
      .where(
        (track) =>
            track.isPlayable &&
            track.artistDisplay.trim().toLowerCase() ==
                item.artistDisplay.trim().toLowerCase(),
      )
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  if (sameArtist.any((track) => track.id == item.id)) {
    return sameArtist;
  }

  return <UploadItem>[item];
}
