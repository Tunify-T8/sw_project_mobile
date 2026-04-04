import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/cache/cache_directories.dart';
import '../../../../core/storage/storage_keys.dart';
import '../dto/upload_item_dto.dart';
import '../services/global_track_store.dart';

/// Downloads audio and artwork files to persistent device storage so that
/// tracks can be played fully offline on subsequent sessions.
///
/// All operations are fire-and-forget — they never throw and never block
/// playback.
class AudioCacheService {
  AudioCacheService(this._store);

  final GlobalTrackStore _store;

  static const _storage = FlutterSecureStorage();

  // ── Audio ────────────────────────────────────────────────────────────────

  /// Starts a background download of [streamUrl] for [trackId].
  ///
  /// Does nothing if the file is already cached locally.
  /// On success: updates [GlobalTrackStore] and persists the path to
  /// [StorageKeys.cachedLibraryUploads] so the next cold-start finds it.
  void cacheAudioInBackground(
    String trackId,
    String streamUrl,
    String format,
  ) {
    _downloadAudio(trackId, streamUrl, format);
  }

  Future<void> _downloadAudio(
    String trackId,
    String streamUrl,
    String format,
  ) async {
    try {
      final file = await CacheDirectories.audioFile(trackId, format);
      if (file.existsSync()) return; // already cached

      await Dio().download(streamUrl, file.path);

      // Update in-memory store so the running session uses the local file.
      final existing = _store.find(trackId);
      if (existing != null) {
        _store.update(existing.copyWith(localFilePath: file.path));
      }

      // Persist the updated path so it survives app restarts.
      await _persistLocalFilePath(trackId, file.path);
    } catch (_) {
      // Silently discard any error — caching is opportunistic.
      // The partial file (if any) will be overwritten on the next attempt.
    }
  }

  // ── Artwork ──────────────────────────────────────────────────────────────

  /// Starts a background download of [artworkUrl] for [trackId].
  ///
  /// Does nothing if the artwork is already cached locally.
  /// On success: updates [GlobalTrackStore] and persists the path.
  void cacheArtworkInBackground(String trackId, String artworkUrl) {
    _downloadArtwork(trackId, artworkUrl);
  }

  Future<void> _downloadArtwork(String trackId, String artworkUrl) async {
    try {
      final file = await CacheDirectories.artworkFile(trackId);
      if (file.existsSync()) return; // already cached

      await Dio().download(artworkUrl, file.path);

      final existing = _store.find(trackId);
      if (existing != null) {
        _store.update(existing.copyWith(localArtworkPath: file.path));
      }

      await _persistLocalArtworkPath(trackId, file.path);
    } catch (_) {
      // Silently discard.
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
      final raw = await _storage.read(key: StorageKeys.cachedLibraryUploads);
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw) as List<dynamic>;
      final updated = decoded.map((e) {
        if (e is! Map<String, dynamic>) return e;
        final dto = UploadItemDto.fromJson(e);
        return dto.id == trackId ? updater(dto).toJson() : e;
      }).toList();

      await _storage.write(
        key: StorageKeys.cachedLibraryUploads,
        value: jsonEncode(updated),
      );
    } catch (_) {
      // If persistence fails, the in-memory store still has the update.
    }
  }
}
