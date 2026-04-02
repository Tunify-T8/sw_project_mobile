import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/storage/storage_keys.dart';
import '../../../playback_streaming_engine/domain/entities/history_track.dart';
import '../../../playback_streaming_engine/domain/entities/playback_status.dart';
import '../../../playback_streaming_engine/domain/entities/player_seed_track.dart';
import '../../../playback_streaming_engine/domain/entities/track_artist_summary.dart';
import '../../../playback_streaming_engine/presentation/providers/listening_history_provider.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../data/dto/upload_item_dto.dart';
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

  await _ensureCachedUploadsHydrated(ref);

  final preparedItem = await _prepareTrackSurfaceItemFast(ref, item);

  _optimisticallyPromoteHistory(ref, preparedItem);

  unawaited(
    ensureUploadItemPlayback(
      ref,
      preparedItem,
      queueItems: queueItems,
      autoPlay: true,
    ),
  );

  await _waitForTrackToBecomeCurrent(ref, preparedItem.id);

  if (!openScreen || !context.mounted) return;
  await Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => TrackDetailScreen(item: preparedItem),
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

  await _ensureCachedUploadsHydrated(ref);

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

  _optimisticallyPromoteHistory(ref, item);

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
  await _ensureCachedUploadsHydrated(ref);

  final current = ref.read(playerProvider).asData?.value;
  if (current?.bundle == null) return;
  if (current!.bundle!.playability.status == PlaybackStatus.blocked) return;

  final store = ref.read(globalTrackStoreProvider);
  final rawItem = uploadItemFromPlayerState(current, store);
  final hydratedItem = await _prepareTrackSurfaceItemFast(ref, rawItem);

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

Future<UploadItem> _prepareTrackSurfaceItemFast(
  WidgetRef ref,
  UploadItem item,
) async {
  try {
    return await prepareTrackSurfaceItem(ref, item).timeout(
      const Duration(milliseconds: 500),
      onTimeout: () => item,
    );
  } catch (_) {
    return item;
  }
}

Future<void> _waitForTrackToBecomeCurrent(
  WidgetRef ref,
  String trackId,
) async {
  final startedAt = DateTime.now();

  while (DateTime.now().difference(startedAt) < const Duration(milliseconds: 700)) {
    final current = ref.read(playerProvider).asData?.value;
    if (current?.bundle?.trackId == trackId) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 35));
  }
}

void _optimisticallyPromoteHistory(WidgetRef ref, UploadItem item) {
  try {
    unawaited(
      ref.read(listeningHistoryProvider.notifier).trackPlayed(
            HistoryTrack(
              trackId: item.id,
              title: item.title,
              artist: TrackArtistSummary(
                id: '',
                name: item.artistDisplay,
              ),
              playedAt: DateTime.now(),
              durationSeconds: item.durationSeconds,
              status: PlaybackStatus.playable,
              coverUrl: item.artworkUrl,
            ),
          ),
    );
  } catch (_) {
    // Never block playback/navigation because of optimistic history UI.
  }
}

Future<void> _ensureCachedUploadsHydrated(WidgetRef ref) async {
  final store = ref.read(globalTrackStoreProvider);
  if (store.all.isNotEmpty) return;

  const storage = FlutterSecureStorage();
  final raw = await storage.read(key: StorageKeys.cachedLibraryUploads);
  if (raw == null || raw.isEmpty) return;

  try {
    final decoded = jsonDecode(raw) as List<dynamic>;
    final uploads = decoded
        .whereType<Map<String, dynamic>>()
        .map(UploadItemDto.fromJson)
        .map(_uploadItemFromDto)
        .toList(growable: false);

    for (final item in uploads) {
      store.update(item);
    }
  } catch (_) {
    // Ignore corrupted cache here; the normal uploads provider can rebuild it.
  }
}

UploadItem _uploadItemFromDto(UploadItemDto dto) {
  return UploadItem(
    id: dto.id,
    title: dto.title,
    artistDisplay: dto.artists.join(', '),
    durationLabel: _formatDuration(dto.durationSeconds),
    durationSeconds: dto.durationSeconds,
    audioUrl: dto.audioUrl,
    waveformUrl: dto.waveformUrl,
    waveformBars: dto.waveformBars,
    artworkUrl: dto.artworkUrl,
    localArtworkPath: dto.localArtworkPath,
    localFilePath: dto.localFilePath,
    description: dto.description,
    tags: dto.tags,
    genreCategory: dto.genreCategory,
    genreSubGenre: dto.genreSubGenre,
    visibility: dto.privacy == 'public'
        ? UploadVisibility.public
        : UploadVisibility.private,
    status: _dtoStatusToEntityStatus(dto.status),
    isExplicit: dto.contentWarning,
    recordLabel: dto.recordLabel,
    publisher: dto.publisher,
    isrc: dto.isrc,
    pLine: dto.pLine,
    scheduledReleaseDate: dto.scheduledReleaseDate == null
        ? null
        : DateTime.tryParse(dto.scheduledReleaseDate!),
    allowDownloads: dto.allowDownloads,
    offlineListening: dto.offlineListening,
    includeInRss: dto.includeInRss,
    displayEmbedCode: dto.displayEmbedCode,
    appPlaybackEnabled: dto.appPlaybackEnabled,
    availabilityType: dto.availabilityType,
    availabilityRegions: dto.availabilityRegions,
    licensing: dto.licensing,
    createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
  );
}

UploadProcessingStatus _dtoStatusToEntityStatus(String value) {
  switch (value) {
    case 'processing':
    case 'uploading':
      return UploadProcessingStatus.processing;
    case 'failed':
      return UploadProcessingStatus.failed;
    case 'deleted':
      return UploadProcessingStatus.deleted;
    default:
      return UploadProcessingStatus.finished;
  }
}

String _formatDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
