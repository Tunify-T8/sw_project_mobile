import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' hide RepeatMode;
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

  final notifier = ref.read(playerProvider.notifier);
  final current = ref.read(playerProvider).asData?.value;
  final isSameTrack = current?.bundle?.trackId == item.id;
  final store = ref.read(globalTrackStoreProvider);
  // Include listening history so same-artist siblings are surfaced in the
  // "Next up" queue even when the artist isn't the signed-in user (the store
  // only holds own uploads). This is how queue-building works offline without
  // any backend call.
  final historyTracks =
      ref.read(listeningHistoryProvider).asData?.value.tracks ??
      const <HistoryTrack>[];
  final queue = _resolveArtistQueue(item, queueItems, store, historyTracks);
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

  await notifier.loadTrack(item.id, autoPlay: autoPlay, seedTrack: seedTrack);
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

// Resolves the "Next up" queue for a track launch.
//
// In real-world offline apps like SoundCloud, the queue is built from
// whatever track data is already cached locally — not from a dedicated
// backend call. We gather same-artist tracks from three sources:
//
//   1. An explicit queueItems list when the caller provides one (playlist,
//      profile, search result — those contexts already know their neighbours).
//   2. The GlobalTrackStore — only contains the current user's own uploads,
//      so this covers "play my track" launches.
//   3. Listening history — this is the key one for OTHER users' tracks
//      (the screenshot issue): if the user has played Joe's tracks before,
//      those entries are in history and we can surface them as "Next up"
//      siblings when Joe's current track starts.
//
// Deduped by trackId, current track always included, current track's
// position in the returned list is wherever it naturally sorts.
List<UploadItem> _resolveArtistQueue(
  UploadItem item,
  List<UploadItem>? queueItems,
  GlobalTrackStore store,
  List<HistoryTrack> historyTracks,
) {
  // (1) Explicit queue passed by the caller — trust it as-is.
  final explicitQueue = (queueItems ?? const <UploadItem>[])
      .where((track) => track.isPlayable)
      .toList();
  if (explicitQueue.isNotEmpty) {
    return explicitQueue;
  }

  final normalizedArtist = item.artistDisplay.trim().toLowerCase();

  // (2) Same-artist tracks already in GlobalTrackStore (own uploads mostly).
  final fromStore = store.all
      .where(
        (track) =>
            track.isPlayable &&
            track.artistDisplay.trim().toLowerCase() == normalizedArtist,
      )
      .toList();

  // (3) Same-artist tracks in listening history.  Map each history entry to
  //     a minimal UploadItem so the downstream queue loader can consume them.
  //     We only use history entries whose artist matches; duration, cover,
  //     title come straight from the history record.
  final fromHistory = historyTracks
      .where(
        (h) => h.artist.name.trim().toLowerCase() == normalizedArtist,
      )
      .map((h) => _historyTrackToUploadItemShell(h))
      .toList();

  // Merge and dedupe (store entries win over history shells because they
  // carry more metadata — audioUrl, waveformUrl, etc. — used by the player).
  final seen = <String>{};
  final merged = <UploadItem>[];

  void addIfNew(UploadItem u) {
    if (seen.add(u.id)) merged.add(u);
  }

  for (final u in fromStore) {
    addIfNew(u);
  }
  for (final u in fromHistory) {
    addIfNew(u);
  }

  // Ensure the currently-launched track is present even if neither source
  // contained it (e.g. deep link to an unknown track whose owner has no
  // siblings in either cache).
  addIfNew(item);

  // Sort by createdAt desc for store entries. History shells have createdAt =
  // epoch (no real value), so they end up after store entries; that's fine
  // and keeps the user's own tracks first when playing one of them.
  merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return merged;
}

// Minimal UploadItem constructed from a HistoryTrack so it can flow through
// the existing queue-building code path. Fields the player doesn't need for
// queue display (tags, genre, permissions, etc.) are safe defaults.
UploadItem _historyTrackToUploadItemShell(HistoryTrack h) {
  return UploadItem(
    id: h.trackId,
    title: h.title,
    artistDisplay: h.artist.name,
    durationLabel: '',
    durationSeconds: h.durationSeconds,
    audioUrl: null,
    waveformUrl: null,
    waveformBars: null,
    artworkUrl: h.coverUrl,
    localArtworkPath: null,
    localFilePath: null,
    description: null,
    tags: const [],
    genreCategory: h.genre ?? '',
    genreSubGenre: '',
    visibility: UploadVisibility.public,
    status: UploadProcessingStatus.finished,
    isExplicit: false,
    // HistoryTrack doesn't carry createdAt — use epoch so these sort after
    // real store entries (which have real createdAt values).
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
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