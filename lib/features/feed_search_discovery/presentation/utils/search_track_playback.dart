// Search Feature Guide:
// Purpose: Utility that bridges a [TrackResultEntity] (search/discovery domain)
//          to the shared audio player used across the app.
// Used by: search_result_tabs.dart, search_see_all_screen.dart,
//          genre_detail_screen.dart
// Concerns: Track playback from search/discovery surfaces; Recently Played recording.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../audio_upload_and_management/presentation/utils/upload_player_launcher.dart';
import '../../domain/entities/track_result_entity.dart';
import '../providers/search_provider.dart';

/// Plays a [TrackResultEntity] from any search or discovery surface and
/// records it as Recently Played once the player has started.
///
/// ── WHY THIS FUNCTION EXISTS ─────────────────────────────────────────────────
/// The audio player operates on [UploadItem] domain objects, but search and
/// genre-detail screens hold [TrackResultEntity] objects. This function is the
/// single conversion point so the mapping logic is not duplicated across every
/// tile and card in the search UI.
///
/// ── RECENTLY PLAYED RECORDING ────────────────────────────────────────────────
/// [recordTrackPlayed] is called AFTER [openUploadItemPlayer] returns.
/// This ensures the "Recently Played" row in the search All tab is only
/// populated when a track has actually been played, not just searched.
/// (Fixes M8-019 — previously items were added on every query submission.)
///
/// ── PARAMETERS ───────────────────────────────────────────────────────────────
/// [context]     — required for [openUploadItemPlayer]'s bottom sheet / route.
/// [ref]         — Riverpod ref for reading [searchProvider] and player.
/// [track]       — the track to play.
/// [queueTracks] — optional ordered list that becomes the player queue,
///                 allowing the user to skip forward/backward within the same
///                 search result list or genre section.
Future<void> playSearchTrack(
  BuildContext context,
  WidgetRef ref,
  TrackResultEntity track, {
  List<TrackResultEntity>? queueTracks,
}) async {
  if (track.isUnavailable) return;

  final selected = _toUploadItem(track);
  final queue = queueTracks
      ?.where((t) => !t.isUnavailable)
      .map(_toUploadItem)
      .toList(growable: false);

  await openUploadItemPlayer(context, ref, selected, queueItems: queue);

  // Guard: openUploadItemPlayer may push a route — check mounted before
  // interacting with providers that read BuildContext.
  if (!context.mounted) return;

  // Record as Recently Played now that playback has been initiated.
  ref.read(searchProvider.notifier).recordTrackPlayed(track);
}

// ── Private helpers ───────────────────────────────────────────────────────────

/// Converts a [TrackResultEntity] to an [UploadItem] that the player accepts.
///
/// Fields not available in [TrackResultEntity] (e.g. [UploadVisibility],
/// [UploadProcessingStatus]) are given safe defaults. The player uses
/// [UploadItem.id] to fetch the real streaming URL, so these defaults do not
/// affect playback quality.
UploadItem _toUploadItem(TrackResultEntity t) {
  return UploadItem(
    id: t.id,
    title: t.title,
    artistDisplay: t.artistName,
    durationLabel: _formatDuration(t.durationSeconds),
    durationSeconds: t.durationSeconds,
    artworkUrl: t.artworkUrl,
    visibility: UploadVisibility.public,
    status: UploadProcessingStatus.finished,
    isExplicit: false,
    createdAt: DateTime.now(),
  );
}

/// Formats seconds as `m:ss` (e.g. 180 → "3:00").
String _formatDuration(int totalSeconds) {
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final m = safe ~/ 60;
  final s = (safe % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
