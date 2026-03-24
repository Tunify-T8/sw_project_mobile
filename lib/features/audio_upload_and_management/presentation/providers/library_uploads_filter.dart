// Upload Feature Guide:
// Purpose: Filtering and sorting helpers used by the uploads-library state to produce the visible list.
// Used by: library_uploads_provider
// Concerns: Multi-format support; Track visibility.
import '../../domain/entities/upload_item.dart';
import 'library_uploads_state.dart';

List<UploadItem> applyLibraryUploadsFilter({
  required List<UploadItem> source,
  required String query,
  required UploadSortOrder sort,
  required UploadVisibilityFilter visibility,
}) {
  var result = List<UploadItem>.from(source);

  if (visibility == UploadVisibilityFilter.public) {
    result = result
        .where((item) => item.visibility == UploadVisibility.public)
        .toList();
  } else if (visibility == UploadVisibilityFilter.private) {
    result = result
        .where((item) => item.visibility == UploadVisibility.private)
        .toList();
  }

  final trimmedQuery = query.trim().toLowerCase();
  if (trimmedQuery.isNotEmpty) {
    result = result
        .where(
          (item) =>
              item.title.toLowerCase().contains(trimmedQuery) ||
              item.artistDisplay.toLowerCase().contains(trimmedQuery),
        )
        .toList();
  }

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
