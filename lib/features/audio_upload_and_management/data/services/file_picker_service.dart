import 'package:file_picker/file_picker.dart';

class FilePickerService {
  Future<PlatformFile?> pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'flac'],  //check docs for extensions
        withData: false,   //ask what that means
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;   
      }
    } catch (e) {
      // Handle any errors that occur during file picking
      print('Error picking file: $e');
    }
    return null; // Return null if no file was selected or an error occurred
  }
}
