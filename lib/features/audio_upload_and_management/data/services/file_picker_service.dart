import 'package:file_picker/file_picker.dart';
import '../../domain/entities/picked_upload_file.dart';

class FilePickerService {
  Future<PickedUploadFile?> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'flac', 'm4a', 'aac'],
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;

    if (file.path == null) {
      return null;
    }

    return PickedUploadFile(
      name: file.name,
      path: file.path!,
      sizeBytes: file.size,
    );
  }

  Future<String?> pickArtworkImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    return result.files.first.path;
  }
}