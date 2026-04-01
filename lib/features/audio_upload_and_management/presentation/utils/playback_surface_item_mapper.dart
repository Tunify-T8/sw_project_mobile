import '../../data/services/global_track_store.dart';
import '../../domain/entities/upload_item.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';

UploadItem? storedUploadItemForTrack(GlobalTrackStore store, String trackId) {
  return store.find(trackId);
}

UploadItem uploadItemFromPlayerState(
  PlayerState state,
  GlobalTrackStore store,
) {
  final bundle = state.bundle!;
  final stored = store.find(bundle.trackId);
  if (stored != null) {
    return stored;
  }

  return UploadItem(
    id: bundle.trackId,
    title: bundle.title,
    artistDisplay: bundle.artist.name,
    durationLabel: _formatDuration(bundle.durationSeconds),
    durationSeconds: bundle.durationSeconds,
    audioUrl: state.streamUrl?.url,
    waveformUrl: bundle.waveformUrl.isEmpty ? null : bundle.waveformUrl,
    artworkUrl: bundle.coverUrl.isEmpty ? null : bundle.coverUrl,
    localFilePath: state.localFilePath,
    description: '',
    visibility: UploadVisibility.public,
    status: UploadProcessingStatus.finished,
    isExplicit: false,
    createdAt: DateTime.now(),
  );
}

String _formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final remainder = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$remainder';
}
