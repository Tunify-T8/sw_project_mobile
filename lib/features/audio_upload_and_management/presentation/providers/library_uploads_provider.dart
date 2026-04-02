// Upload Feature Guide:
// Purpose: Riverpod notifier for loading, filtering, refreshing, deleting, replacing, and updating the user's uploaded tracks.
// Used by: upload_flow_controller, upload_provider, artist_home_screen, and 6 more upload files.
// Concerns: Multi-format support; Track visibility.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/storage/storage_keys.dart';
import '../../data/dto/upload_item_dto.dart';
import '../../data/services/global_track_store.dart';
import '../../domain/entities/upload_item.dart';
import '../../shared/upload_error_helpers.dart';
import 'library_uploads_filter.dart';
import 'library_uploads_repository_provider.dart';
import 'library_uploads_state.dart';

final libraryUploadsProvider =
    NotifierProvider<LibraryUploadsNotifier, LibraryUploadsState>(
      LibraryUploadsNotifier.new,
    );

class LibraryUploadsNotifier extends Notifier<LibraryUploadsState> {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  LibraryUploadsState build() => const LibraryUploadsState();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final uploads = await ref.read(getMyUploadsUsecaseProvider).call();
      final quota = await ref.read(getArtistToolsQuotaUsecaseProvider).call();

      await _persistCachedUploads(uploads);
      _syncGlobalTrackStore(uploads);

      state = state.copyWith(
        isLoading: false,
        items: uploads,
        filteredItems: _filtered(source: uploads),
        quota: quota,
      );
    } catch (error, stackTrace) {
      final cachedUploads = await _readCachedUploads();
      if (cachedUploads.isNotEmpty) {
        _syncGlobalTrackStore(cachedUploads);
        state = state.copyWith(
          isLoading: false,
          items: cachedUploads,
          filteredItems: _filtered(source: cachedUploads),
          clearError: true,
        );
        return;
      }

      _setError(
        error,
        stackTrace,
        context: 'load your uploads',
        fallback: 'We could not load your uploads right now.',
        updateState: (message) =>
            state = state.copyWith(isLoading: false, error: message),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final uploads = await ref.read(getMyUploadsUsecaseProvider).call();
      final quota = await ref.read(getArtistToolsQuotaUsecaseProvider).call();

      await _persistCachedUploads(uploads);
      _syncGlobalTrackStore(uploads);

      state = state.copyWith(
        isRefreshing: false,
        items: uploads,
        filteredItems: _filtered(source: uploads),
        quota: quota,
      );
    } catch (error, stackTrace) {
      final cachedUploads = await _readCachedUploads();
      if (cachedUploads.isNotEmpty) {
        _syncGlobalTrackStore(cachedUploads);
        state = state.copyWith(
          isRefreshing: false,
          items: cachedUploads,
          filteredItems: _filtered(source: cachedUploads),
          clearError: true,
        );
        return;
      }

      _setError(
        error,
        stackTrace,
        context: 'refresh your uploads',
        fallback: 'We could not refresh your uploads right now.',
        updateState: (message) =>
            state = state.copyWith(isRefreshing: false, error: message),
      );
    }
  }

  void setQuery(String value) {
    state = state.copyWith(
      query: value,
      filteredItems: _filtered(query: value),
    );
  }

  void setSortOrder(UploadSortOrder order) {
    state = state.copyWith(
      sortOrder: order,
      filteredItems: _filtered(sort: order),
    );
  }

  void setVisibilityFilter(UploadVisibilityFilter filter) {
    state = state.copyWith(
      visibilityFilter: filter,
      filteredItems: _filtered(visibility: filter),
    );
  }

  Future<void> deleteTrack(String trackId) async {
    state = state.copyWith(busyTrackId: trackId, clearError: true);
    try {
      await ref.read(deleteUploadUsecaseProvider).call(trackId);
      final updated = state.items.where((item) => item.id != trackId).toList();

      await _persistCachedUploads(updated);
      _syncGlobalTrackStore(updated);

      state = state.copyWith(
        items: updated,
        filteredItems: _filtered(source: updated),
        clearBusyTrackId: true,
      );
    } catch (error, stackTrace) {
      _setBusyActionError(
        error,
        stackTrace,
        context: 'delete track from uploads',
        fallback: 'We could not delete that track. Please try again.',
      );
    }
  }

  Future<void> replaceFile({
    required String trackId,
    required String filePath,
  }) async {
    state = state.copyWith(busyTrackId: trackId, clearError: true);
    try {
      await ref
          .read(replaceFileUsecaseProvider)
          .call(trackId: trackId, filePath: filePath);
      await refresh();
      state = state.copyWith(clearBusyTrackId: true);
    } catch (error, stackTrace) {
      _setBusyActionError(
        error,
        stackTrace,
        context: 'replace upload file',
        fallback: 'We could not replace that file. Please try again.',
      );
    }
  }

  Future<void> updateTrack({
    required String trackId,
    required String title,
    required String description,
    required String privacy,
    String? localArtworkPath,
  }) async {
    state = state.copyWith(busyTrackId: trackId, clearError: true);
    try {
      await ref
          .read(updateUploadUsecaseProvider)
          .call(
            trackId: trackId,
            title: title,
            description: description,
            privacy: privacy,
            localArtworkPath: localArtworkPath,
          );
      await refresh();
      state = state.copyWith(clearBusyTrackId: true);
    } catch (error, stackTrace) {
      _setBusyActionError(
        error,
        stackTrace,
        context: 'update upload metadata',
        fallback: 'We could not save those track changes. Please try again.',
      );
    }
  }

  List<UploadItem> _filtered({
    List<UploadItem>? source,
    String? query,
    UploadSortOrder? sort,
    UploadVisibilityFilter? visibility,
  }) => applyLibraryUploadsFilter(
    source: source ?? state.items,
    query: query ?? state.query,
    sort: sort ?? state.sortOrder,
    visibility: visibility ?? state.visibilityFilter,
  );

  Future<void> _persistCachedUploads(List<UploadItem> uploads) async {
    final payload = uploads
        .map(
          (item) => UploadItemDto(
            id: item.id,
            title: item.title,
            artists: item.artistDisplay
                .split(',')
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toList(),
            durationSeconds: item.durationSeconds,
            audioUrl: item.audioUrl,
            waveformUrl: item.waveformUrl,
            waveformBars: item.waveformBars,
            artworkUrl: item.artworkUrl,
            localArtworkPath: item.localArtworkPath,
            localFilePath: item.localFilePath,
            description: item.description,
            tags: item.tags,
            genreCategory: item.genreCategory,
            genreSubGenre: item.genreSubGenre,
            privacy: item.visibility == UploadVisibility.public
                ? 'public'
                : 'private',
            status: _statusToString(item.status),
            contentWarning: item.isExplicit,
            recordLabel: item.recordLabel,
            publisher: item.publisher,
            isrc: item.isrc,
            pLine: item.pLine,
            scheduledReleaseDate: item.scheduledReleaseDate?.toIso8601String(),
            allowDownloads: item.allowDownloads,
            offlineListening: item.offlineListening,
            includeInRss: item.includeInRss,
            displayEmbedCode: item.displayEmbedCode,
            appPlaybackEnabled: item.appPlaybackEnabled,
            availabilityType: item.availabilityType,
            availabilityRegions: item.availabilityRegions,
            licensing: item.licensing,
            createdAt: item.createdAt.toIso8601String(),
          ).toJson(),
        )
        .toList(growable: false);

    await _storage.write(
      key: StorageKeys.cachedLibraryUploads,
      value: jsonEncode(payload),
    );
  }

  Future<List<UploadItem>> _readCachedUploads() async {
    final raw = await _storage.read(key: StorageKeys.cachedLibraryUploads);
    if (raw == null || raw.isEmpty) {
      return const <UploadItem>[];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(UploadItemDto.fromJson)
          .map(_uploadItemFromDto)
          .toList(growable: false);
    } catch (_) {
      await _storage.delete(key: StorageKeys.cachedLibraryUploads);
      return const <UploadItem>[];
    }
  }

  void _syncGlobalTrackStore(List<UploadItem> uploads) {
    final store = ref.read(globalTrackStoreProvider);
    for (final item in uploads) {
      store.update(item);
    }
  }

  void _setBusyActionError(
    Object error,
    StackTrace stackTrace, {
    required String context,
    required String fallback,
  }) {
    _setError(
      error,
      stackTrace,
      context: context,
      fallback: fallback,
      updateState: (message) =>
          state = state.copyWith(error: message, clearBusyTrackId: true),
    );
  }

  void _setError(
    Object error,
    StackTrace stackTrace, {
    required String context,
    required String fallback,
    required void Function(String message) updateState,
  }) {
    logUploadError(context, error, stackTrace);
    updateState(userFriendlyUploadError(error, fallback: fallback));
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

  String _statusToString(UploadProcessingStatus status) {
    switch (status) {
      case UploadProcessingStatus.finished:
        return 'finished';
      case UploadProcessingStatus.processing:
        return 'processing';
      case UploadProcessingStatus.failed:
        return 'failed';
      case UploadProcessingStatus.deleted:
        return 'deleted';
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
