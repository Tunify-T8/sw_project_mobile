import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../domain/entities/upload_item.dart';
import '../../shared/upload_error_helpers.dart';

bool supportsTrackDetailWaveformExtraction() {
  if (kIsWeb) {
    return false;
  }
  return Platform.isAndroid || Platform.isIOS;
}

Future<String?> resolveTrackDetailWaveformSource(UploadItem item) async {
  final localPath = _resolveExistingLocalPath(item.localFilePath);
  if (localPath != null) {
    return localPath;
  }
  return _downloadRemoteAudio(item);
}

String? _resolveExistingLocalPath(String? path) {
  if (path == null || path.trim().isEmpty) {
    return null;
  }
  return File(path).existsSync() ? path : null;
}

Future<String?> _downloadRemoteAudio(UploadItem item) async {
  final audioUrl = item.audioUrl?.trim();
  if (audioUrl == null || audioUrl.isEmpty) {
    return null;
  }

  final targetFile = await _cachedAudioFile(item.id, audioUrl);
  if (targetFile.existsSync() && await targetFile.length() > 0) {
    return targetFile.path;
  }

  final client = HttpClient();
  IOSink? sink;
  try {
    final request = await client.getUrl(Uri.parse(audioUrl));
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const UploadFlowException(
        'We could not download the audio to build its waveform.',
      );
    }

    sink = targetFile.openWrite();
    await response.forEach(sink.add);
    await sink.flush();
    return targetFile.path;
  } catch (error, stackTrace) {
    if (targetFile.existsSync()) {
      await targetFile.delete();
    }
    logUploadError('download waveform source audio', error, stackTrace);
    if (error is UploadFlowException) rethrow;
    throw const UploadFlowException(
      'We could not download the audio to build its waveform.',
    );
  } finally {
    await sink?.close();
    client.close(force: true);
  }
}

Future<File> _cachedAudioFile(String trackId, String audioUrl) async {
  final extension = _fileExtension(audioUrl);
  final cacheDirectory = Directory(
    '${Directory.systemTemp.path}/soundcloud_track_cache',
  );
  if (!cacheDirectory.existsSync()) {
    await cacheDirectory.create(recursive: true);
  }
  return File('${cacheDirectory.path}/$trackId$extension');
}

String _fileExtension(String url) {
  final uri = Uri.tryParse(url);
  final lastSegment = uri?.pathSegments.isNotEmpty == true
      ? uri!.pathSegments.last
      : url.split('/').last;
  final dotIndex = lastSegment.lastIndexOf('.');
  if (dotIndex <= 0) {
    return '.mp3';
  }
  return lastSegment.substring(dotIndex);
}
