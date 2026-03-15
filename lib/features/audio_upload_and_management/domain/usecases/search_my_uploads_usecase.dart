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