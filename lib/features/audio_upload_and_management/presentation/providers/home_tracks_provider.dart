import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed_search_discovery/domain/entities/discovery_item_entity.dart';
import '../../../feed_search_discovery/domain/entities/feed_item_entity.dart';
import '../../../feed_search_discovery/presentation/providers/feed_provider.dart';
import '../../../playback_streaming_engine/domain/entities/history_track.dart';
import '../../../playback_streaming_engine/presentation/providers/listening_history_provider.dart';
import '../../data/services/global_track_store.dart';
import '../../domain/entities/upload_item.dart';
import 'library_uploads_provider.dart';

class HomeTrackItem {
  const HomeTrackItem({required this.track, this.likesCount});

  final UploadItem track;
  final int? likesCount;

  HomeTrackItem copyWith({int? likesCount}) {
    return HomeTrackItem(
      track: track,
      likesCount: likesCount ?? this.likesCount,
    );
  }
}

final homeTracksProvider = FutureProvider<List<HomeTrackItem>>((ref) async {
  final libraryItems = ref.watch(
    libraryUploadsProvider.select((state) => state.items),
  );
  // Playback updates listening history optimistically. This section only uses
  // history as a fallback source, so take a snapshot instead of subscribing and
  // forcing recommendations back into a loading skeleton on every play.
  final historyTracks =
      ref.read(listeningHistoryProvider).asData?.value.tracks ??
      const <HistoryTrack>[];
  final store = ref.read(globalTrackStoreProvider);

  final merged = <String, HomeTrackItem>{};

  void addTrack(UploadItem item, {int? likesCount}) {
    if (item.id.trim().isEmpty || !item.isPlayable || item.isDeleted) return;
    final existing = merged[item.id];
    if (existing != null && existing.likesCount != null) return;
    merged[item.id] = HomeTrackItem(track: item, likesCount: likesCount);
  }

  try {
    final repository = ref.read(feedRepositoryProvider);
    const pageSize = 50;
    const maxPages = 8;

    for (var page = 1; page <= maxPages; page++) {
      final feedItems = await repository.getFollowingFeed(
        page: page,
        limit: pageSize,
      );

      for (final item in feedItems) {
        addTrack(item.toUploadItem(), likesCount: item.track.likesCount);
      }

      if (feedItems.length < pageSize) break;
    }
  } catch (_) {
    // Fall through to discovery/history/local sources.
  }

  try {
    final repository = ref.read(feedRepositoryProvider);
    const pageSize = 50;
    const maxPages = 8;

    for (var page = 1; page <= maxPages; page++) {
      final discoverItems = await repository.getDiscover(
        page: page,
        limit: pageSize,
      );

      for (final item in discoverItems) {
        final track = item.toUploadItem();
        if (track != null) {
          addTrack(track, likesCount: item.track?.likesCount);
        }
      }

      if (discoverItems.length < pageSize) break;
    }
  } catch (_) {
    // The global/library stores below keep Home useful while discovery is
    // offline or still being wired to a backend.
  }

  for (final item in historyTracks) {
    addTrack(item.toUploadItem());
  }
  for (final item in store.all) {
    addTrack(item);
  }
  for (final item in libraryItems) {
    addTrack(item);
  }

  final tracks = merged.values.toList(growable: false);
  return _shuffleForDay(tracks, DateTime.now());
});

extension on FeedItemEntity {
  UploadItem toUploadItem() {
    final source = track;
    final artistName = source.artistName.trim().isEmpty
        ? 'SoundCloud'
        : source.artistName.trim();

    return UploadItem(
      id: source.trackId,
      title: source.title,
      artistDisplay: artistName,
      durationLabel: _formatDuration(source.duration),
      durationSeconds: source.duration,
      artworkUrl: source.coverUrl,
      visibility: UploadVisibility.public,
      status: UploadProcessingStatus.finished,
      isExplicit: false,
      createdAt: DateTime.now(),
    );
  }
}

extension on DiscoveryItemEntity {
  UploadItem? toUploadItem() {
    final source = track;
    if (source == null) return null;

    final artistName = source.artistName.trim().isEmpty
        ? 'SoundCloud'
        : source.artistName.trim();

    return UploadItem(
      id: source.trackId,
      title: source.title,
      artistDisplay: artistName,
      durationLabel: _formatDuration(source.duration),
      durationSeconds: source.duration,
      artworkUrl: source.coverUrl,
      visibility: UploadVisibility.public,
      status: UploadProcessingStatus.finished,
      isExplicit: false,
      createdAt: DateTime.tryParse(source.createdAt) ?? DateTime.now(),
    );
  }
}

extension on HistoryTrack {
  UploadItem toUploadItem() {
    return UploadItem(
      id: trackId,
      title: title,
      artistDisplay: artist.name.trim().isEmpty ? 'SoundCloud' : artist.name,
      durationLabel: _formatDuration(durationSeconds),
      durationSeconds: durationSeconds,
      artworkUrl: coverUrl,
      visibility: UploadVisibility.public,
      status: UploadProcessingStatus.finished,
      isExplicit: false,
      createdAt: playedAt,
    );
  }
}

List<HomeTrackItem> _shuffleForDay(List<HomeTrackItem> tracks, DateTime now) {
  final seed = now.year * 10000 + now.month * 100 + now.day;
  final shuffled = [...tracks];
  shuffled.sort(
    (a, b) => _rank(a.track.id, seed).compareTo(_rank(b.track.id, seed)),
  );
  return shuffled;
}

int _rank(String value, int seed) {
  var hash = seed & 0x3fffffff;
  for (final unit in value.codeUnits) {
    hash = ((hash * 31) + unit) & 0x3fffffff;
  }
  return hash;
}

String _formatDuration(int totalSeconds) {
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final minutes = safe ~/ 60;
  final seconds = (safe % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
