import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/storage/storage_keys.dart';
import '../../../playback_streaming_engine/domain/entities/history_track.dart';
import '../../../playback_streaming_engine/domain/entities/playback_queue.dart';
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
  _cacheUploadItems(ref, [preparedItem, ...?queueItems]);

  _optimisticallyPromoteHistory(ref, preparedItem);

  await ensureUploadItemPlayback(
    ref,
    preparedItem,
    queueItems: queueItems,
    autoPlay: true,
  );

  if (!openScreen || !context.mounted) return;
  await Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => TrackDetailScreen(item: preparedItem),
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 340),
    ),
  );
}

/// Variant of [openUploadItemPlayer] used when the track is being played
/// from the user's listening history. Builds the queue from the supplied
/// history tracks and tags it with [QueueSource.history] so the "next up"
/// list tracks the history, not "more by this artist".
Future<void> openHistorySourcedPlayer(
  BuildContext context,
  WidgetRef ref,
  UploadItem item, {
  required List<HistoryTrack> historyTracks,
  bool openScreen = true,
}) async {
  if (!item.isPlayable) return;

  await _ensureCachedUploadsHydrated(ref);

  final preparedItem = await _prepareTrackSurfaceItemFast(ref, item);

  _optimisticallyPromoteHistory(ref, preparedItem);

  final queueTrackIds = historyTracks
      .where((h) => h.status != PlaybackStatus.blocked)
      .map((h) => h.trackId)
      .toList(growable: false);
  final startIndex = queueTrackIds.indexOf(preparedItem.id);

  final seedTrack = PlayerSeedTrack(
    trackId: preparedItem.id,
    title: preparedItem.title,
    artistName: preparedItem.artistDisplay,
    durationSeconds: preparedItem.durationSeconds,
    coverUrl: preparedItem.artworkUrl,
    waveformUrl: preparedItem.waveformUrl,
    directAudioUrl: preparedItem.audioUrl,
    localFilePath: preparedItem.localFilePath,
  );

  final notifier = ref.read(playerProvider.notifier);

  if (startIndex >= 0 && queueTrackIds.length > 1) {
    unawaited(
      notifier.loadTrack(
        preparedItem.id,
        autoPlay: true,
        seedTrack: seedTrack,
        queue: PlaybackQueue(
          trackIds: queueTrackIds,
          currentIndex: startIndex,
          shuffle: false,
          repeat: RepeatMode.none,
          source: QueueSource.history,
        ),
      ),
    );
  } else {
    unawaited(
      notifier.loadTrack(preparedItem.id, autoPlay: true, seedTrack: seedTrack),
    );
  }

  await _waitForTrackToBecomeCurrent(ref, preparedItem.id);

  if (!openScreen || !context.mounted) return;
  await Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => TrackDetailScreen(item: preparedItem),
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 340),
    ),
  );
}

Future<UploadItem> prepareTrackSurfaceItem(
  WidgetRef ref,
  UploadItem item,
) async {
  UploadItem resolvedItem = item;

  try {
    resolvedItem = await ref.read(trackDetailItemProvider(item).future);
  } catch (_) {
    resolvedItem = item;
  }

  try {
    final bars = await ref.read(
      trackDetailWaveformBarsProvider(resolvedItem).future,
    );
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

  // Private tracks from the library list never include privateToken (the list
  // endpoint omits it). Fetch the full track detail here so we have the token
  // before we attempt the stream request. Without it the backend returns 403.
  UploadItem resolvedItem = item;
  if (item.visibility == UploadVisibility.private &&
      item.privateToken == null) {
    ref.invalidate(trackDetailItemProvider(item));
    try {
      resolvedItem = await ref
          .read(trackDetailItemProvider(item).future)
          .timeout(const Duration(seconds: 5));
    } catch (error) {
      debugPrint('Private track detail fetch failed for ${item.id}: $error');
      resolvedItem = item;
    }

    if (resolvedItem.privateToken == null ||
        resolvedItem.privateToken!.trim().isEmpty) {
      debugPrint('Private track ${item.id} has no privateToken after details.');
    }
  }

  // Rebind item to the resolved copy (may have privateToken now).
  // ignore: parameter_assignments
  item = resolvedItem;

  final notifier = ref.read(playerProvider.notifier);
  final current = ref.read(playerProvider).asData?.value;
  final isSameTrack = current?.bundle?.trackId == item.id;
  final store = ref.read(globalTrackStoreProvider);
  // Local pre-fetch: only same-artist tracks already in GlobalTrackStore
  // (own uploads).  Listening history is intentionally NOT used here — those
  // are tracks the user already played, not "more by this artist", and
  // surfacing them as the queue was confusing.  The real artist catalog is
  // fetched from the backend by enrichQueueWithArtistTracks (called from

  // inside loadTrack once the real bundle lands).
  _cacheUploadItems(ref, [item, ...?queueItems]);

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

  if (isSameTrack && current?.isBuffering != true) {
    final hasUsefulQueue = (current?.queue?.trackIds.length ?? 0) > 1;
    if (!hasUsefulQueue && currentIndex >= 0 && queueIds.length > 1) {
      await notifier.loadTrackWithQueue(
        trackId: item.id,
        trackIds: queueIds,
        currentIndex: currentIndex,
        repeat: RepeatMode.all,
        autoPlay: autoPlay || current?.isPlaying == true,
        seedTrack: seedTrack,
        privateToken: item.privateToken,
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
      privateToken: item.privateToken,
    );
    return;
  }

  await notifier.loadTrack(
    item.id,
    autoPlay: autoPlay,
    seedTrack: seedTrack,
    privateToken: item.privateToken,
  );
}

// Fire-and-forget background fetch: pull the playing artist's full track
// catalog from the backend and merge it into the live queue. Runs AFTER
// NOTE: the previous _enrichQueueAfterLaunch polling helper was removed.
// The "more by this artist" enrichment is now triggered from inside
// loadTrack() itself, as soon as the real backend bundle is in state.
// This is reliable — no timing race against the seed bundle — and removes
// the need for the launcher to know anything about it.

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
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 340),
    ),
  );
}

// Resolves the local same-artist queue used right at launch.
//
// Sources, in priority order:
//   1. An explicit queueItems list (e.g. playlist context) — trust as-is.
//   2. Same-artist tracks already in GlobalTrackStore — covers playing your
//      own tracks (the store only holds the signed-in user's uploads today).
//
// History is intentionally NOT consulted here.  Recent plays aren't a queue —
// they're a queue's *opposite* (tracks the user already heard).  The real
// "more by this artist" queue for ANY artist is fetched from the backend by
// enrichQueueWithArtistTracks, which fires from inside loadTrack as soon as
// the real bundle is in state.
//
// Dedupes by trackId, always includes the current track.
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

  final normalizedArtist = item.artistDisplay.trim().toLowerCase();

  final fromStore = store.all
      .where(
        (track) =>
            track.isPlayable &&
            track.artistDisplay.trim().toLowerCase() == normalizedArtist,
      )
      .toList();

  final seen = <String>{};
  final merged = <UploadItem>[];
  void addIfNew(UploadItem u) {
    if (seen.add(u.id)) merged.add(u);
  }

  for (final u in fromStore) {
    addIfNew(u);
  }
  // Always include the current track even if it isn't in the store
  // (e.g. another user's track launched from search/profile).
  addIfNew(item);

  merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return merged;
}

Future<UploadItem> _prepareTrackSurfaceItemFast(
  WidgetRef ref,
  UploadItem item,
) async {
  try {
    return await prepareTrackSurfaceItem(
      ref,
      item,
    ).timeout(const Duration(milliseconds: 500), onTimeout: () => item);
  } catch (_) {
    return item;
  }
}

Future<void> _waitForTrackToBecomeCurrent(WidgetRef ref, String trackId) async {
  final startedAt = DateTime.now();

  while (DateTime.now().difference(startedAt) <
      const Duration(milliseconds: 700)) {
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
      ref
          .read(listeningHistoryProvider.notifier)
          .trackPlayed(
            HistoryTrack(
              trackId: item.id,
              title: item.title,
              artist: TrackArtistSummary(id: '', name: item.artistDisplay),
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
    visibility: dto.privacy.trim().toLowerCase() == 'public'
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
    privateToken: dto.privateToken,
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

void _cacheUploadItems(WidgetRef ref, List<UploadItem> items) {
  final store = ref.read(globalTrackStoreProvider);
  for (final item in items) {
    if (item.id.trim().isEmpty) continue;
    store.update(item);
  }
}
