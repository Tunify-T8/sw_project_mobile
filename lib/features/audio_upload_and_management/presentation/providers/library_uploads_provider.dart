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
  LibraryUploadsState build() => const LibraryUploadsState();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final uploads = await ref.read(getMyUploadsUsecaseProvider).call();
      final quota = await ref.read(getArtistToolsQuotaUsecaseProvider).call();
      state = state.copyWith(
        isLoading: false,
        items: uploads,
        filteredItems: _apply(
          uploads,
          state.query,
          state.sortOrder,
          state.visibilityFilter,
        ),
        quota: quota,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
        filteredItems: _apply(
          uploads,
          state.query,
          state.sortOrder,
          state.visibilityFilter,
        ),
        quota: quota,
      );
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  void setQuery(String value) {
    state = state.copyWith(
      query: value,
      filteredItems: _apply(
        state.items,
        value,
        state.sortOrder,
        state.visibilityFilter,
      ),
    );
  }

  void setSortOrder(UploadSortOrder order) {
    state = state.copyWith(
      sortOrder: order,
      filteredItems: _apply(
        state.items,
        state.query,
        order,
        state.visibilityFilter,
      ),
    );
  }

  void setVisibilityFilter(UploadVisibilityFilter filter) {
    state = state.copyWith(
      visibilityFilter: filter,
      filteredItems: _apply(state.items, state.query, state.sortOrder, filter),
    );
  }

  Future<void> deleteTrack(String trackId) async {
    state = state.copyWith(busyTrackId: trackId, clearError: true);
    try {
      await ref.read(deleteUploadUsecaseProvider).call(trackId);
      final updated = state.items.where((i) => i.id != trackId).toList();
      state = state.copyWith(
        items: updated,
        filteredItems: _apply(
          updated,
          state.query,
          state.sortOrder,
          state.visibilityFilter,
        ),
        clearBusyTrackId: true,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), clearBusyTrackId: true);
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
    } catch (e) {
      state = state.copyWith(error: e.toString(), clearBusyTrackId: true);
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
    } catch (e) {
      state = state.copyWith(error: e.toString(), clearBusyTrackId: true);
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  List<UploadItem> _apply(
    List<UploadItem> source,
    String query,
    UploadSortOrder sort,
    UploadVisibilityFilter visibility,
  ) {
    var result = List<UploadItem>.from(source);

    // 1. Visibility filter
    if (visibility == UploadVisibilityFilter.public) {
      result = result
          .where((i) => i.visibility == UploadVisibility.public)
          .toList();
    } else if (visibility == UploadVisibilityFilter.private) {
      result = result
          .where((i) => i.visibility == UploadVisibility.private)
          .toList();
    }

    // 2. Search query
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where(
            (i) =>
                i.title.toLowerCase().contains(q) ||
                i.artistDisplay.toLowerCase().contains(q),
          )
          .toList();
    }

    // 3. Sort
    switch (sort) {
      case UploadSortOrder.recentlyAdded:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case UploadSortOrder.firstAdded:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case UploadSortOrder.trackName:
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }

    return result;
  }
}
