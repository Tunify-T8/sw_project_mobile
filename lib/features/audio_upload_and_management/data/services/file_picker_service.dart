import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/picked_upload_file.dart';

// ask is the right thing to split file/image to separate services? maybe not worth it, but it does make the code cleaner and more focused. we can always merge them back if it becomes too much boilerplate
class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<PickedUploadFile?> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'flac', 'm4a', 'aac'],
      withData: false, //do not load full file bytes into memory immediately ; audio files can be large.
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
// is the image an entity ,
  Future<String?> pickArtworkImage({bool fromCamera = false}) // why false
  async {
    final pickedImage = await _imagePicker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2000,
    );

    return pickedImage?.path;
  }
}
