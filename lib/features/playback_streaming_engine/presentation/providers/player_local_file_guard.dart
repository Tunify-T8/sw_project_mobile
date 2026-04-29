import 'player_local_file_guard_stub.dart'
    if (dart.library.io) 'player_local_file_guard_io.dart';

String? existingPlaybackLocalFile(String? path) {
  return resolveExistingPlaybackLocalFile(path);
}
