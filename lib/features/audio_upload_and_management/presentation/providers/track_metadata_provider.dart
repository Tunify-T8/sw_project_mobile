import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_genre.dart';
import '../../domain/entities/upload_item.dart';
import '../../domain/entities/upload_status.dart';
import 'track_metadata_mapper.dart';
import 'track_metadata_state.dart';
import 'track_metadata_validator.dart';
import 'upload_dependencies_provider.dart';
import 'upload_repository_provider.dart';

class TrackMetadataNotifier extends Notifier<TrackMetadataState> {
  @override
  TrackMetadataState build() {
    return TrackMetadataState(artists: [_primaryArtist]);
  }

  String get _primaryArtist => ref.read(currentArtistNameProvider);

  void prepareForNewUpload(String fileName) {
    state = TrackMetadataState(
      title: fileName,
      artists: [_primaryArtist],
    );
  }

  void prepareForEdit(UploadItem item) {
    final artists = item.artistDisplay
        .split(', ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    state = TrackMetadataState(
      title: item.title,
      genreCategory: item.genreCategory,
      genreSubGenre: item.genreSubGenre,
      tagsText: item.tags.join(', '),
      description: item.description ?? '',
      privacy: item.visibility == UploadVisibility.public ? 'public' : 'private',
      artists: artists.isEmpty ? [_primaryArtist] : artists,
      artworkPath: item.localArtworkPath,
      recordLabel: item.recordLabel,
      publisher: item.publisher,
      isrc: item.isrc,
      pLine: item.pLine,
      hasScheduledRelease: item.scheduledReleaseDate != null,
      scheduledReleaseDate: item.scheduledReleaseDate,
      contentWarning: item.isExplicit,
      allowDownloads: item.allowDownloads,
      offlineListening: item.offlineListening,
      includeInRss: item.includeInRss,
      displayEmbedCode: item.displayEmbedCode,
      appPlaybackEnabled: item.appPlaybackEnabled,
      availabilityType: item.availabilityType,
      availabilityRegionsText: item.availabilityRegions.join(', '),
      licensing: item.licensing,
    );
  }

  void setTitle(String value) => state = state.copyWith(title: value, error: null);

  void setGenreCategory(String value) =>
      state = state.copyWith(genreCategory: value, error: null);

  void setGenreSubGenre(String value) =>
      state = state.copyWith(genreSubGenre: value, error: null);

  void setGenre(UploadGenre genre) {
    state = state.copyWith(
      genreCategory: genre.isNone ? '' : genre.categoryValue,
      genreSubGenre: genre.isNone ? '' : genre.subGenre,
      error: null,
    );
  }

  void setTagsText(String value) =>
      state = state.copyWith(tagsText: value, error: null);

  void setDescription(String value) =>
      state = state.copyWith(description: value, error: null);

  void setPrivacy(String value) =>
      state = state.copyWith(privacy: value, error: null);

  void addArtist(String value) {
    final t = value.trim();
    if (t.isEmpty) return;
    if (state.artists.any((a) => a.toLowerCase() == t.toLowerCase())) return;
    state = state.copyWith(artists: [...state.artists, t], error: null);
  }

  void removeArtist(String artist) {
    if (state.artists.length == 1) return;
    state = state.copyWith(
      artists: state.artists.where((a) => a != artist).toList(),
      error: null,
    );
  }

  Future<void> pickArtwork({bool fromCamera = false}) async {
    try {
      final picker = ref.read(filePickerServiceProvider);
      final path = await picker.pickArtworkImage(fromCamera: fromCamera);
      if (path == null) return;
      state = state.copyWith(artworkPath: path, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setRecordLabel(String v) => state = state.copyWith(recordLabel: v, error: null);
  void setPublisher(String v) => state = state.copyWith(publisher: v, error: null);
  void setIsrc(String v) => state = state.copyWith(isrc: v, error: null);
  void setPLine(String v) => state = state.copyWith(pLine: v, error: null);

  void setHasScheduledRelease(bool v) {
    state = state.copyWith(
      hasScheduledRelease: v,
      scheduledReleaseDate:
          v ? (state.scheduledReleaseDate ?? DateTime.now()) : state.scheduledReleaseDate,
      error: null,
    );
  }

  void setScheduledReleaseDate(DateTime v) {
    state = state.copyWith(
      scheduledReleaseDate: v,
      hasScheduledRelease: true,
      error: null,
    );
  }

  void setContentWarning(bool v) => state = state.copyWith(contentWarning: v, error: null);
  void setAllowDownloads(bool v) => state = state.copyWith(allowDownloads: v, error: null);
  void setOfflineListening(bool v) => state = state.copyWith(offlineListening: v, error: null);
  void setIncludeInRss(bool v) => state = state.copyWith(includeInRss: v, error: null);
  void setDisplayEmbedCode(bool v) => state = state.copyWith(displayEmbedCode: v, error: null);
  void setAppPlaybackEnabled(bool v) => state = state.copyWith(appPlaybackEnabled: v, error: null);

  void setAvailabilityType(String v) {
    state = state.copyWith(
      availabilityType: v,
      availabilityRegionsText: v == 'worldwide' ? '' : state.availabilityRegionsText,
      error: null,
    );
  }

  void setAvailabilityRegionsText(String v) =>
      state = state.copyWith(availabilityRegionsText: v, error: null);

  void setLicensing(String v) => state = state.copyWith(licensing: v, error: null);

  Future<bool> saveForNewUpload(String trackId) async {
    final err = TrackMetadataValidator.validateForSave(state);
    if (err != null) {
      state = state.copyWith(error: err);
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      isPolling: false,
      processingStatus: UploadStatus.idle,
      finalTrack: null,
      error: null,
    );

    try {
      final repository = ref.read(uploadRepositoryProvider);
      final metadata = TrackMetadataMapper.toEntity(state);

      final processing = await repository.finalizeMetadata(
        trackId: trackId,
        metadata: metadata,
      );

      state = state.copyWith(
        isSaving: false,
        isPolling: true,
        processingStatus: processing.status,
        error: null,
      );

      final finalTrack = await repository.waitUntilProcessed(trackId);

      state = state.copyWith(
        isPolling: false,
        processingStatus: finalTrack.status,
        finalTrack: finalTrack,
        error: null,
      );

      return finalTrack.status == UploadStatus.finished;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        isPolling: false,
        processingStatus: UploadStatus.failed,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> saveForEdit(String trackId) async {
    final err = TrackMetadataValidator.validateForSave(state);
    if (err != null) {
      state = state.copyWith(error: err);
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      isPolling: false,
      processingStatus: UploadStatus.idle,
      finalTrack: null,
      error: null,
    );

    try {
      final repository = ref.read(uploadRepositoryProvider);
      final metadata = TrackMetadataMapper.toEntity(state);

      final updated = await repository.updateTrackMetadata(
        trackId: trackId,
        metadata: metadata,
      );

      state = state.copyWith(
        isSaving: false,
        isPolling: false,
        processingStatus: updated.status,
        finalTrack: updated,
        error: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        isPolling: false,
        processingStatus: UploadStatus.failed,
        error: e.toString(),
      );
      return false;
    }
  }
}

final trackMetadataProvider =
    NotifierProvider<TrackMetadataNotifier, TrackMetadataState>(
  TrackMetadataNotifier.new,
);