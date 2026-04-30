import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_upload_and_management/data/services/global_track_store.dart';
import '../providers/listening_history_provider.dart';
import '../providers/player_provider.dart';
import '../providers/player_repository_provider.dart';

String? resolveArtistIdForTrackLocally(
  WidgetRef ref,
  String trackId, {
  String? fallbackArtistId,
}) {
  final seededArtistId = fallbackArtistId?.trim();
  if (seededArtistId != null && seededArtistId.isNotEmpty) {
    return seededArtistId;
  }

  final storeOwner =
      ref.read(globalTrackStoreProvider).ownerUserIdForTrack(trackId)?.trim();
  if (storeOwner != null &&
      storeOwner.isNotEmpty &&
      storeOwner != '__global__') {
    return storeOwner;
  }

  final historyTracks =
      ref.read(listeningHistoryProvider).asData?.value.tracks ?? const [];
  for (final track in historyTracks) {
    if (track.trackId != trackId) continue;
    final artistId = track.artist.id.trim();
    if (artistId.isNotEmpty) {
      return artistId;
    }
  }

  final playingBundle = ref.read(playerProvider).asData?.value.bundle;
  if (playingBundle != null && playingBundle.trackId == trackId) {
    final artistId = playingBundle.artist.id.trim();
    if (artistId.isNotEmpty) {
      return artistId;
    }
  }

  return null;
}

Future<String?> resolveArtistIdForTrack(
  WidgetRef ref,
  String trackId, {
  String? fallbackArtistId,
}) async {
  final localArtistId = resolveArtistIdForTrackLocally(
    ref,
    trackId,
    fallbackArtistId: fallbackArtistId,
  );
  if (localArtistId != null && localArtistId.isNotEmpty) {
    return localArtistId;
  }

  try {
    final bundle = await ref.read(playerRepositoryProvider).getPlaybackBundle(
          trackId,
        );
    final artistId = bundle.artist.id.trim();
    if (artistId.isNotEmpty) {
      return artistId;
    }
  } catch (_) {
    // Fall through to null so callers can keep their current behavior.
  }

  return null;
}
