import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Resolves consistent persistent-storage paths for cached media files.
///
/// All files live under [getApplicationDocumentsDirectory] which survives
/// app restarts and OS image-cache sweeps.
class CacheDirectories {
  CacheDirectories._();

  /// Cached audio file for [trackId] with the given [ext] (e.g. `"mp3"`).
  static Future<File> audioFile(String trackId, String ext) async {
    final dir = await _subdir('audio');
    return File('${dir.path}/$trackId.$ext');
  }

  /// Cached waveform JSON file for [trackId].
  static Future<File> waveformFile(String trackId) async {
    final dir = await _subdir('waveforms');
    return File('${dir.path}/$trackId.json');
  }

  /// Cached artwork JPEG file for [trackId].
  static Future<File> artworkFile(String trackId) async {
    final dir = await _subdir('artwork');
    return File('${dir.path}/$trackId.jpg');
  }

  static Future<Directory> _subdir(String name) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/soundclone_cache/$name');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
