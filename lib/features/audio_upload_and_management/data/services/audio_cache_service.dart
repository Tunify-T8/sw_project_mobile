import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/cache/cache_directories.dart';
import '../../../../core/storage/safe_secure_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/storage/token_storage.dart';
import '../dto/upload_item_dto.dart';
import '../services/global_track_store.dart';

/// Downloads audio and artwork files to persistent device storage so tracks can
/// be played again when the device is offline.
///
/// Important idea:
/// - Streaming/buffering is handled by just_audio while the user is online.
/// - This service creates our own persistent copy under app storage.
/// - A track is considered available offline only when a completed cached file
///   exists. Partial downloads are never treated as valid cached audio.
///
/// All background caching methods are best-effort. They should never break
/// normal playback if caching fails.
class AudioCacheService {
  AudioCacheService(this._store);

  final GlobalTrackStore _store;

  static const _tokenStorage = TokenStorage();

  /// Resolves the per-user uploads cache key at call time so it always matches
  /// the currently signed-in user, even if the service was constructed before
  /// the user was written to storage (e.g. right after a provider invalidation).
  Future<String> _resolveUploadsKey() async {
    final userId = (await _tokenStorage.getUser())?.id.trim() ?? '';
    return userId.isEmpty
        ? StorageKeys.cachedLibraryUploads
        : '${StorageKeys.cachedLibraryUploads}_$userId';
  }

  /// File extensions we check when we do not know the original audio format.
  static const List<String> _knownAudioExtensions = <String>[
    'mp3',
    'wav',
    'flac',
    'aac',
    'ogg',
    'm4a',
  ];

  /// Very small files are normally failed/partial downloads, not real songs.
  /// This avoids treating a broken leftover file as an offline-ready track.
  static const int _minimumUsableAudioBytes = 8 * 1024;

  // ── Audio lookup ─────────────────────────────────────────────────────────

  /// Returns a usable cached audio path for [trackId], or null when the track
  /// is not available offline yet.
  ///
  /// This checks both:
  /// 1. The path stored in GlobalTrackStore / cached uploads.
  /// 2. The standard cache directory using common audio extensions.
  Future<String?> cachedAudioPathForTrack(String trackId) async {
    final storedPath = _store.find(trackId)?.localFilePath;
    if (await _isUsableAudioPath(storedPath)) {
      debugPrint('[M5 Cache] HIT track=$trackId path=$storedPath');
      return storedPath;
    }

    for (final ext in _knownAudioExtensions) {
      final file = await CacheDirectories.audioFile(trackId, ext);
      if (await _isUsableAudioFile(file)) {
        await _persistLocalFilePath(trackId, file.path);

        final existing = _store.find(trackId);
        if (existing != null) {
          _store.update(existing.copyWith(localFilePath: file.path));
        }

        debugPrint('[M5 Cache] HIT track=$trackId path=${file.path}');
        return file.path;
      }
    }

    debugPrint('[M5 Cache] MISS track=$trackId');
    return null;
  }

  /// True when [trackId] has a completed local audio file.
  Future<bool> isAudioCached(String trackId) async {
    return (await cachedAudioPathForTrack(trackId)) != null;
  }

  Future<bool> _isUsableAudioPath(String? path) async {
    if (path == null || path.trim().isEmpty) return false;
    return _isUsableAudioFile(File(path));
  }

  Future<bool> _isUsableAudioFile(File file) async {
    try {
      if (!await file.exists()) return false;
      return await file.length() >= _minimumUsableAudioBytes;
    } catch (_) {
      return false;
    }
  }

  // ── Audio caching ────────────────────────────────────────────────────────

  /// Starts a background download of [streamUrl] for [trackId].
  ///
  /// If the file is already cached, this does nothing.
  /// On success, it updates GlobalTrackStore and secure-storage metadata so the
  /// next player launch can find the local file while offline.
  void cacheAudioInBackground(
    String trackId,
    String streamUrl,
    String format,
  ) {
    debugPrint(
      '[M5 Cache] START track=$trackId format=$format url=${_shortUrl(streamUrl)}',
    );
    _downloadAudio(trackId, streamUrl, format);
  }

  Future<String?> _downloadAudio(
    String trackId,
    String streamUrl,
    String format,
  ) async {
    final safeFormat = _normalAudioExtension(format, streamUrl);

    // HLS streams are playlists, not one simple audio file. Downloading only
    // the .m3u8 text file would not make the song playable offline.
    if (safeFormat == 'hls' || safeFormat == 'm3u8') {
      debugPrint(
        '[M5 Cache] SKIP track=$trackId reason=HLS playlist cannot be saved as one offline file',
      );
      return null;
    }

    try {
      final existingPath = await cachedAudioPathForTrack(trackId);
      if (existingPath != null) {
        debugPrint('[M5 Cache] ALREADY_CACHED track=$trackId path=$existingPath');
        return existingPath;
      }

      final file = await CacheDirectories.audioFile(trackId, safeFormat);
      final tempFile = File('${file.path}.download');

      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      await Dio().download(
        streamUrl,
        tempFile.path,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          final percent = ((received / total) * 100).clamp(0, 100).round();
          if (percent == 25 || percent == 50 || percent == 75) {
            debugPrint('[M5 Cache] PROGRESS track=$trackId $percent%');
          }
        },
      );

      if (!await _isUsableAudioFile(tempFile)) {
        final exists = await tempFile.exists();
        final bytes = exists ? await tempFile.length() : 0;
        debugPrint(
          '[M5 Cache] FAILED track=$trackId reason=downloaded file too small bytes=$bytes',
        );
        if (exists) {
          await tempFile.delete();
        }
        return null;
      }

      if (await file.exists()) {
        await file.delete();
      }
      await tempFile.rename(file.path);

      final existing = _store.find(trackId);
      if (existing != null) {
        _store.update(existing.copyWith(localFilePath: file.path));
      }

      await _persistLocalFilePath(trackId, file.path);
      final bytes = await file.length();
      debugPrint('[M5 Cache] COMPLETE track=$trackId bytes=$bytes path=${file.path}');
      return file.path;
    } catch (error) {
      debugPrint('[M5 Cache] FAILED track=$trackId error=$error');
      // Caching is opportunistic. Normal online playback should continue even
      // if the cache download fails or internet disconnects midway.
      try {
        final file = await CacheDirectories.audioFile(trackId, safeFormat);
        final tempFile = File('${file.path}.download');
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}
      return null;
    }
  }

  String _normalAudioExtension(String format, String url) {
    final lowerFormat = format.trim().toLowerCase();
    final lowerUrl = url.toLowerCase().split('?').first;

    // Only treat the stream as HLS when the URL itself is an .m3u8 playlist.
    // Some backends omit format and our DTO used to default to 'hls', even
    // when the URL was actually an MP3. In that case we infer from the URL so
    // caching still works.
    if ((lowerFormat == 'hls' || lowerFormat == 'm3u8') &&
        lowerUrl.endsWith('.m3u8')) {
      return 'm3u8';
    }

    if (_knownAudioExtensions.contains(lowerFormat)) {
      return lowerFormat;
    }

    for (final ext in _knownAudioExtensions) {
      if (lowerUrl.endsWith('.$ext')) return ext;
    }
    if (lowerUrl.endsWith('.m3u8')) return 'm3u8';

    return 'mp3';
  }

  String _shortUrl(String url) {
    if (url.length <= 90) return url;
    return '${url.substring(0, 60)}...${url.substring(url.length - 20)}';
  }

  // ── Artwork ──────────────────────────────────────────────────────────────

  /// Starts a background download of [artworkUrl] for [trackId].
  ///
  /// Does nothing if the artwork is already cached locally.
  /// On success, it updates GlobalTrackStore and persists the path.
  void cacheArtworkInBackground(String trackId, String artworkUrl) {
    _downloadArtwork(trackId, artworkUrl);
  }

  Future<void> _downloadArtwork(String trackId, String artworkUrl) async {
    try {
      final file = await CacheDirectories.artworkFile(trackId);
      if (await file.exists() && await file.length() > 0) return;

      final tempFile = File('${file.path}.download');
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      await Dio().download(artworkUrl, tempFile.path);

      if (!await tempFile.exists() || await tempFile.length() == 0) {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        return;
      }

      if (await file.exists()) {
        await file.delete();
      }
      await tempFile.rename(file.path);

      final existing = _store.find(trackId);
      if (existing != null) {
        _store.update(existing.copyWith(localArtworkPath: file.path));
      }

      await _persistLocalArtworkPath(trackId, file.path);
    } catch (_) {
      // Silently discard artwork-cache failures.
    }
  }

  // ── Persistence helpers ──────────────────────────────────────────────────

  Future<void> _persistLocalFilePath(String trackId, String path) async {
    await _updateCachedUploads(
      trackId,
      (dto) => dto.copyWith(localFilePath: path),
    );
  }

  Future<void> _persistLocalArtworkPath(String trackId, String path) async {
    await _updateCachedUploads(
      trackId,
      (dto) => dto.copyWith(localArtworkPath: path),
    );
  }

  Future<void> _updateCachedUploads(
    String trackId,
    UploadItemDto Function(UploadItemDto) updater,
  ) async {
    try {
      final key = await _resolveUploadsKey();
      final raw = await SafeSecureStorage.read(key);
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw) as List<dynamic>;
      final updated = decoded.map((e) {
        if (e is! Map<String, dynamic>) return e;
        final dto = UploadItemDto.fromJson(e);
        return dto.id == trackId ? updater(dto).toJson() : e;
      }).toList();

      await SafeSecureStorage.write(key: key, value: jsonEncode(updated));
    } catch (_) {
      // Cache metadata is an optimization. Do not fail audio caching because
      // secure-storage metadata failed.
    }
  }
}
