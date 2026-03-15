import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_item.dart';
import 'library_uploads_repository_provider.dart';
import 'library_uploads_state.dart';

final libraryUploadsProvider =
    NotifierProvider<LibraryUploadsNotifier, LibraryUploadsState>(
  LibraryUploadsNotifier.new,
);

class LibraryUploadsNotifier extends Notifier<LibraryUploadsState> {
  @override
  LibraryUploadsState build() {
    return const LibraryUploadsState();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final uploads = await ref.read(getMyUploadsUsecaseProvider).call();
      final quota = await ref.read(getArtistToolsQuotaUsecaseProvider).call();
      final filtered = _applySearch(uploads, state.query);

      state = state.copyWith(
        isLoading: false,
        items: uploads,
        filteredItems: filtered,
        quota: quota,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
    );

    try {
      final uploads = await ref.read(getMyUploadsUsecaseProvider).call();
      final quota = await ref.read(getArtistToolsQuotaUsecaseProvider).call();
      final filtered = _applySearch(uploads, state.query);

      state = state.copyWith(
        isRefreshing: false,
        items: uploads,
        filteredItems: filtered,
        quota: quota,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  void setQuery(String value) {
    state = state.copyWith(
      query: value,
      filteredItems: _applySearch(state.items, value),
    );
  }

  Future<void> deleteTrack(String trackId) async {
    state = state.copyWith(
      busyTrackId: trackId,
      clearError: true,
    );

    try {
      await ref.read(deleteUploadUsecaseProvider).call(trackId);

      final updatedItems = state.items.where((item) => item.id != trackId).toList();
      final filtered = _applySearch(updatedItems, state.query);

      state = state.copyWith(
        items: updatedItems,
        filteredItems: filtered,
        clearBusyTrackId: true,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        clearBusyTrackId: true,
      );
    }
  }

  Future<void> replaceFile({
    required String trackId,
    required String filePath,
  }) async {
    state = state.copyWith(
      busyTrackId: trackId,
      clearError: true,
    );

    try {
      await ref.read(replaceFileUsecaseProvider).call(
            trackId: trackId,
            filePath: filePath,
          );

      await refresh();

      state = state.copyWith(
        clearBusyTrackId: true,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        clearBusyTrackId: true,
      );
    }
  }

  List<UploadItem> _applySearch(List<UploadItem> uploads, String query) {
    return ref.read(searchMyUploadsUsecaseProvider).call(
          uploads: uploads,
          query: query,
        );
  }
}