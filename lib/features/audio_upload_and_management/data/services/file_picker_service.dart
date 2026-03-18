import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/picked_upload_file.dart';
import '../../shared/upload_error_helpers.dart';

// ask is the right thing to split file/image to separate services? maybe not worth it, but it does make the code cleaner and more focused. we can always merge them back if it becomes too much boilerplate
class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<PickedUploadFile?> pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'flac', 'm4a', 'aac'],
        withData:
            false, //do not load full file bytes into memory immediately ; audio files can be large.
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      final path = file.path;
      if (path == null || path.trim().isEmpty) {
        throw const UploadFlowException(
          'That audio file could not be read. Please pick a different one.',
        );
      }

      return PickedUploadFile(
        name: file.name,
        path: path,
        sizeBytes: file.size,
      );
    } catch (error, stackTrace) {
      logUploadError('pick audio file', error, stackTrace);
      if (error is UploadFlowException) rethrow;
      throw const UploadFlowException(
        'We could not open your audio files. Please try again.',
      );
    }
  }

  // is the image an entity ,
  Future<String?> pickArtworkImage({bool fromCamera = false}) // why false
  async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2000,
      );

      return pickedImage?.path;
    } catch (error, stackTrace) {
      logUploadError('pick artwork image', error, stackTrace);
      throw UploadFlowException(
        fromCamera
            ? 'We could not open the camera right now. Please try again.'
            : 'We could not open your photo library right now. Please try again.',
        cause: error,
      );
    }
  }
}
