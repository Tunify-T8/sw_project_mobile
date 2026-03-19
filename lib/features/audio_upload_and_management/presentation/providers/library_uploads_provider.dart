import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  LibraryUploadsState build() => const LibraryUploadsState();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final uploads = await ref.read(getMyUploadsUsecaseProvider).call();
      final quota = await ref.read(getArtistToolsQuotaUsecaseProvider).call();
      state = state.copyWith(
        isLoading: false,
        items: uploads,
        filteredItems: _filtered(source: uploads),
        quota: quota,
      );
    } catch (error, stackTrace) {
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
      state = state.copyWith(
        isRefreshing: false,
        items: uploads,
        filteredItems: _filtered(source: uploads),
        quota: quota,
      );
    } catch (error, stackTrace) {
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
}
