import '../../domain/entities/artist_tools_quota.dart';
import '../../domain/entities/upload_item.dart';

enum UploadSortOrder { recentlyAdded, firstAdded, trackName }

enum UploadVisibilityFilter { all, public, private }

class LibraryUploadsState {
  final bool isLoading;
  final bool isRefreshing;
  final List<UploadItem> items;
  final List<UploadItem> filteredItems;
  final ArtistToolsQuota? quota;
  final String query;
  final String? busyTrackId;
  final String? error;
  final UploadSortOrder sortOrder;
  final UploadVisibilityFilter visibilityFilter;

  const LibraryUploadsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.items = const [],
    this.filteredItems = const [],
    this.quota,
    this.query = '',
    this.busyTrackId,
    this.error,
    this.sortOrder = UploadSortOrder.recentlyAdded,
    this.visibilityFilter = UploadVisibilityFilter.all,
  });

  bool get isEmpty => !isLoading && filteredItems.isEmpty;
  int get totalCount => items.length;

  LibraryUploadsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<UploadItem>? items,
    List<UploadItem>? filteredItems,
    ArtistToolsQuota? quota,
    String? query,
    String? busyTrackId,
    String? error,
    bool clearBusyTrackId = false,
    bool clearError = false,
    UploadSortOrder? sortOrder,
    UploadVisibilityFilter? visibilityFilter,
  }) {
    return LibraryUploadsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      quota: quota ?? this.quota,
      query: query ?? this.query,
      busyTrackId:
          clearBusyTrackId ? null : (busyTrackId ?? this.busyTrackId),
      error: clearError ? null : (error ?? this.error),
      sortOrder: sortOrder ?? this.sortOrder,
      visibilityFilter: visibilityFilter ?? this.visibilityFilter,
    );
  }
}
