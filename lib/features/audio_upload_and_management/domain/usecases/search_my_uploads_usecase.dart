// Upload Feature Guide:
// Purpose: Use-case wrapper that exposes a single upload-related action to providers or controllers.
// Used by: library_uploads_repository_provider
// Concerns: Multi-format support.
import '../entities/upload_item.dart';

class SearchMyUploadsUsecase {
  const SearchMyUploadsUsecase();

  List<UploadItem> call({
    required List<UploadItem> uploads,
    required String query,
  }) {
    final normalized = query.trim().toLowerCase();

    if (normalized.isEmpty) {
      return uploads;
    }

    return uploads.where((upload) {
      final title = upload.title.toLowerCase();
      final artist = upload.artistDisplay.toLowerCase();

      return title.contains(normalized) || artist.contains(normalized);
    }).toList();
  }
}
