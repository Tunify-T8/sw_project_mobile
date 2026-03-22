// Upload Feature Guide:
// Purpose: Device file-picker wrapper for selecting audio and artwork files before upload or replacement.
// Used by: upload_dependencies_provider
// Concerns: Multi-format support.
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';

import '../../domain/entities/picked_upload_file.dart';
import '../../shared/upload_error_helpers.dart';

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<PickedUploadFile?> pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'flac', 'm4a', 'aac'],
        withData: false,
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

      final durationSeconds = await _readAudioDurationSeconds(path);

      return PickedUploadFile(
        name: file.name,
        path: path,
        sizeBytes: file.size,
        durationSeconds: durationSeconds,
      );
    } catch (error, stackTrace) {
      logUploadError('pick audio file', error, stackTrace);
      if (error is UploadFlowException) rethrow;
      throw const UploadFlowException(
        'We could not open your audio files. Please try again.',
      );
    }
  }

  Future<int?> _readAudioDurationSeconds(String filePath) async {
    final player = AudioPlayer();

    try {
      final duration = await player.setFilePath(filePath);
      return duration?.inSeconds;
    } catch (error, stackTrace) {
      logUploadError('read audio duration', error, stackTrace);
      return null;
    } finally {
      await player.dispose();
    }
  }

  Future<String?> pickArtworkImage({bool fromCamera = false}) async {
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
