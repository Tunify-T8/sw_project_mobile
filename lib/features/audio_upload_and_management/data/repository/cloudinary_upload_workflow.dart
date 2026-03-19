import '../../domain/entities/picked_upload_file.dart';
import '../../domain/entities/track_metadata.dart';
import '../../domain/entities/upload_cancellation_token.dart';
import '../../domain/entities/upload_item.dart';
import '../../domain/entities/upload_quota.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/uploaded_track.dart';
import '../../shared/upload_error_helpers.dart';
import '../services/cloudinary_media_service.dart';
import '../services/global_track_store.dart';
import 'cloudinary_pending_track.dart';
import 'cloudinary_upload_artwork_resolver.dart';
import 'cloudinary_upload_mapper.dart';

class CloudinaryUploadWorkflow {
  CloudinaryUploadWorkflow(this._mediaService);

  final CloudinaryMediaService _mediaService;
  final Map<String, PendingCloudinaryTrack> _drafts = {};

  Future<UploadQuota> getUploadQuota(String userId) async {
    return const UploadQuota(
      tier: 'free',
      uploadMinutesLimit: 180,
      uploadMinutesUsed: 8,
      uploadMinutesRemaining: 172,
      canReplaceFiles: false,
      canScheduleRelease: false,
      canAccessAdvancedTab: false,
    );
  }

  Future<UploadedTrack> createTrack(String userId) async {
    final trackId = 'track_${DateTime.now().millisecondsSinceEpoch}';
    _drafts[trackId] = PendingCloudinaryTrack(
      trackId: trackId,
      createdAt: DateTime.now(),
    );
    return UploadedTrack(trackId: trackId, status: UploadStatus.idle);
  }

  Future<UploadedTrack> uploadAudio({
    required String trackId,
    required PickedUploadFile file,
    required void Function(double progress) onProgress,
    UploadCancellationToken? cancellationToken,
  }) async {
    final uploadedAudio = await _mediaService.uploadAudio(
      filePath: file.path,
      fileName: file.name,
      cancellationToken: cancellationToken,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress(sent / total);
      },
    );

    final current =
        _drafts[trackId] ??
        PendingCloudinaryTrack(trackId: trackId, createdAt: DateTime.now());
    final updated = current.copyWith(
      audioUrl: uploadedAudio.secureUrl,
      audioPublicId: uploadedAudio.publicId,
      waveformUrl: _mediaService.buildWaveformImageUrl(
        audioPublicId: uploadedAudio.publicId,
      ),
      durationSeconds: uploadedAudio.durationSeconds ?? 0,
      localFilePath: file.path,
    );
    _drafts[trackId] = updated;

    return mapPendingTrackToUploadedTrack(updated, UploadStatus.processing);
  }

  Future<UploadedTrack> finalizeMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    final current = _drafts[trackId];
    if (current == null || current.audioUrl == null) {
      throw const UploadFlowException(
        'Finish uploading the audio file before saving track details.',
      );
    }

    final artwork = await resolveCloudinaryArtwork(
      mediaService: _mediaService,
      artworkPath: metadata.artworkPath,
      currentArtworkUrl: current.artworkUrl,
      currentLocalArtworkPath: current.localArtworkPath,
    );
    final updated = applyCloudinaryTrackMetadata(current, metadata, artwork);
    _drafts[trackId] = updated;
    savePendingTrackToGlobalStore(
      updated,
      status: UploadProcessingStatus.processing,
    );

    return mapPendingTrackToUploadedTrack(updated, UploadStatus.processing);
  }

  Future<UploadedTrack> waitUntilProcessed(String trackId) async {
    final current = _drafts[trackId];
    if (current == null) {
      throw const UploadFlowException(
        'We could not find that upload draft anymore. Please start again.',
      );
    }

    await Future.delayed(const Duration(milliseconds: 900));
    savePendingTrackToGlobalStore(
      current,
      status: UploadProcessingStatus.finished,
    );
    return mapPendingTrackToUploadedTrack(current, UploadStatus.finished);
  }

  Future<UploadedTrack> getTrackDetails(String trackId) async {
    final item = GlobalTrackStore.instance.find(trackId);
    if (item == null) {
      throw const UploadFlowException(
        'We could not find that track anymore. Please refresh and try again.',
      );
    }

    return UploadedTrack(
      trackId: item.id,
      status: mapUploadProcessingStatus(item.status),
      audioUrl: item.audioUrl,
      waveformUrl: item.waveformUrl,
      title: item.title,
      description: item.description,
      privacy: item.visibility == UploadVisibility.public
          ? 'public'
          : 'private',
      artworkUrl: item.artworkUrl,
      durationSeconds: item.durationSeconds,
    );
  }

  Future<UploadedTrack> updateTrackMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    final existing = GlobalTrackStore.instance.find(trackId);
    final current =
        _drafts[trackId] ??
        PendingCloudinaryTrack.maybeFromUploadItem(existing);
    if (current == null) {
      throw const UploadFlowException(
        'We could not find that track anymore. Please refresh and try again.',
      );
    }

    final artwork = await resolveCloudinaryArtwork(
      mediaService: _mediaService,
      artworkPath: metadata.artworkPath,
      currentArtworkUrl: current.artworkUrl,
      currentLocalArtworkPath: current.localArtworkPath,
    );
    final updated = applyCloudinaryTrackMetadata(current, metadata, artwork);
    _drafts[trackId] = updated;
    savePendingTrackToGlobalStore(
      updated,
      status: UploadProcessingStatus.finished,
    );

    return mapPendingTrackToUploadedTrack(updated, UploadStatus.finished);
  }

  Future<void> deleteTrack(String trackId) async {
    final existing = GlobalTrackStore.instance.find(trackId);
    final current =
        _drafts[trackId] ??
        PendingCloudinaryTrack.maybeFromUploadItem(existing);

    if (current != null) {
      try {
        await _mediaService.deleteTrackAssets(
          audioUrl: current.audioUrl,
          artworkUrl: current.artworkUrl,
        );
      } catch (error, stackTrace) {
        logUploadError('delete cloud track assets', error, stackTrace);
        throw UploadFlowException(
          'We could not delete that track right now. Please try again.',
          cause: error,
        );
      }
    }
    GlobalTrackStore.instance.remove(trackId);
    _drafts.remove(trackId);
  }
}
