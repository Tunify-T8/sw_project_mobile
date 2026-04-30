part of 'player_provider.dart';

extension _PlayerNotifierSources on PlayerNotifier {
  Future<TrackPlaybackBundle> _resolveBundle(
    String trackId, {
    String? privateToken,
    PlayerSeedTrack? seedTrack,
  }) async {
    final mode = ref.read(playerBackendModeProvider);

    if (mode == PlayerBackendMode.mock && seedTrack != null) {
      return seedTrack.toPlaybackBundle();
    }

    // Skip the network call immediately when offline and we have local metadata.
    // This avoids waiting for a connection timeout before showing the player.
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity.any((r) => r != ConnectivityResult.none);
    if (!isOnline && seedTrack != null) {
      return seedTrack.toPlaybackBundle();
    }

    try {
      return await _getBundle(trackId, privateToken: privateToken);
    } catch (error) {
      // M5-011B / M5-001 fix: previously ANY error fell back to the seed track,
      // whose toPlaybackBundle() hardcodes PlaybackStatus.playable. That let
      // owners play their own deleted/blocked tracks (M5-011B) and bypassed
      // "processing"/"blocked" states coming from the backend (M5-001).
      //
      // A 4xx response is the backend DELIBERATELY refusing (deleted, blocked,
      // private-no-token, not-found) — we must let it propagate so canPlay
      // evaluates to false. Only fall back for genuine transport errors
      // (timeout, connection error, etc.) where the user has local seed data.
      final refusalStatusCode = _clientRefusalStatusCode(error);
      if (refusalStatusCode != null) {
        if (refusalStatusCode == 404 && _hasSeedAudioFallback(seedTrack)) {
          return seedTrack!.toPlaybackBundle();
        }
        rethrow;
      }
      if (seedTrack != null) {
        return seedTrack.toPlaybackBundle();
      }
      rethrow;
    }
  }

  // A 4xx DioException means the server made a deliberate decision — don't mask it.
  int? _clientRefusalStatusCode(Object error) {
    if (error is just_audio.PlayerException) return null;
    // Uses duck-typing on the dynamic to avoid importing Dio here just for the type.
    // Dio errors expose `.response?.statusCode` as an int.
    try {
      final dynamic d = error;
      final int? code = d.response?.statusCode as int?;
      if (code != null && code >= 400 && code < 500) return code;
    } catch (_) {
      // Not a Dio-shaped error; treat as transport error.
    }
    return null;
  }

  bool _hasSeedAudioFallback(PlayerSeedTrack? seedTrack) {
    if (seedTrack == null) return false;
    if (existingPlaybackLocalFile(seedTrack.localFilePath) != null) {
      return true;
    }
    return seedTrack.toDirectStreamUrl() != null;
  }

  Future<_ResolvedPlaybackSource> _resolvePlaybackSource(
    String trackId, {
    PlayerSeedTrack? seedTrack,
    String? privateToken,
  }) async {
    final mode = ref.read(playerBackendModeProvider);

    if (mode == PlayerBackendMode.mock && seedTrack != null) {
      final localFilePath = existingPlaybackLocalFile(seedTrack.localFilePath);
      final directStream = seedTrack.toDirectStreamUrl();

      return _ResolvedPlaybackSource(
        streamUrl: localFilePath == null ? directStream : null,
        streamExpiresAt: localFilePath != null || directStream == null
            ? null
            : DateTime.now().add(
                Duration(seconds: directStream.expiresInSeconds),
              ),
        localFilePath: localFilePath,
      );
    }

    // A locally cached audio file — plays fully offline, no server call needed.
    final localFilePath = existingPlaybackLocalFile(seedTrack?.localFilePath);
    if (localFilePath != null) {
      return _ResolvedPlaybackSource(
        streamUrl: null,
        streamExpiresAt: null,
        localFilePath: localFilePath,
      );
    }

    // No local file.  Fail fast when offline instead of waiting for the
    // connection timeout (which can be up to 60 s).
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.every((r) => r == ConnectivityResult.none)) {
      throw Exception(
        'No internet connection and no local audio source available.',
      );
    }

    // Request a signed streaming URL from the server. Some owner-upload rows
    // can exist in the upload library before the playback service knows them;
    // in that 404-only case, fall back to the upload's direct audio URL.
    final StreamUrl streamUrl;
    try {
      streamUrl = await _requestStream(trackId, privateToken: privateToken);
    } catch (error) {
      final directStream = seedTrack?.toDirectStreamUrl();
      if (_clientRefusalStatusCode(error) == 404 && directStream != null) {
        return _ResolvedPlaybackSource(
          streamUrl: directStream,
          streamExpiresAt: DateTime.now().add(
            Duration(seconds: directStream.expiresInSeconds),
          ),
          localFilePath: null,
        );
      }
      rethrow;
    }

    return _ResolvedPlaybackSource(
      streamUrl: streamUrl,
      streamExpiresAt: DateTime.now().add(
        Duration(seconds: streamUrl.expiresInSeconds),
      ),
      localFilePath: null,
    );
  }

  Future<PlayerState?> _ensureFreshPlaybackSource(PlayerState current) async {
    if (current.bundle == null) return null;

    final expiresAt = current.streamExpiresAt;
    final localFilePath = existingPlaybackLocalFile(current.localFilePath);
    final hasExpiredStream =
        current.streamUrl == null ||
        (expiresAt != null &&
            DateTime.now().isAfter(
              expiresAt.subtract(const Duration(seconds: 10)),
            ));
    final mustRefresh = localFilePath == null && hasExpiredStream;

    if (!mustRefresh) {
      final prepared = current.copyWith(localFilePath: localFilePath);
      await _prepareAudioSource(prepared);
      if (!identical(prepared, current) &&
          prepared.localFilePath != current.localFilePath) {
        _setPlayerState(prepared);
      }
      return prepared;
    }

    final resolved = await _resolvePlaybackSource(
      current.bundle!.trackId,
      privateToken: current.privateToken,
    );

    final updated = current.copyWith(
      streamUrl: resolved.streamUrl,
      streamExpiresAt: resolved.streamExpiresAt,
      localFilePath: resolved.localFilePath,
      isBuffering: false,
    );

    await _prepareAudioSource(updated, force: true);

    if (updated.positionSeconds > 0) {
      await _audioPlayer.seek(
        Duration(milliseconds: (updated.positionSeconds * 1000).round()),
      );
    }

    _setPlayerState(updated);
    return updated;
  }

  Future<void> _prepareAudioSource(
    PlayerState playerState, {
    bool force = false,
  }) async {
    final activeBundle = playerState.bundle;
    if (activeBundle == null) return;

    final localFilePath = existingPlaybackLocalFile(playerState.localFilePath);
    final sourceKey = localFilePath ?? playerState.streamUrl?.url;

    if (!force &&
        _loadedTrackId == activeBundle.trackId &&
        _loadedSourceKey == sourceKey) {
      return;
    }

    // just_audio throws PlayerInterruptedException when a pending load is
    // superseded by another setAudioSource / setFilePath / stop call (rapid
    // next/prev taps, a refresh racing a restore, etc.). That is a benign
    // signal, not a playback failure — swallow it so the newer load wins.
    try {
      if (localFilePath != null) {
        await _audioPlayer.setFilePath(localFilePath);
      } else if (playerState.streamUrl?.url.trim().isNotEmpty == true) {
        await _audioPlayer.setAudioSource(
          just_audio.AudioSource.uri(Uri.parse(playerState.streamUrl!.url)),
          preload: true,
        );
      }
    } on just_audio.PlayerInterruptedException {
      debugPrint(
        "[M5 Player] audio source load was interrupted by a newer command",
      );
      return;
    } catch (error) {
      debugPrint("[M5 Player] audio source failed safely: $error");
      return;
    }

    if (playerState.streamUrl?.url.trim().isNotEmpty == true &&
        localFilePath == null) {
      // Download audio + artwork to device storage in the background so
      // subsequent plays work fully offline without requesting a new stream URL.
      // HLS manifests (.m3u8) are not cacheable as single files — skip them.
      final streamUrl = playerState.streamUrl;
      if (streamUrl != null && !streamUrl.isHls) {
        _audioCache.cacheAudioInBackground(
          activeBundle.trackId,
          streamUrl.url,
          streamUrl.format,
        );
      }
      if (activeBundle.coverUrl.isNotEmpty) {
        _audioCache.cacheArtworkInBackground(
          activeBundle.trackId,
          activeBundle.coverUrl,
        );
      }
    }

    _loadedTrackId = activeBundle.trackId;
    _loadedSourceKey = sourceKey;
  }

  Future<void> _applyVolume(PlayerState playerState) async {
    final targetVolume = playerState.isMuted ? 0.0 : playerState.volume;
    try {
      await _audioPlayer.setVolume(targetVolume.clamp(0.0, 1.0).toDouble());
    } on just_audio.PlayerInterruptedException {
      debugPrint(
        "[M5 Player] volume change ignored because loading was interrupted",
      );
    } catch (error) {
      debugPrint("[M5 Player] volume change failed safely: $error");
    }
  }

  int _initialPositionFor(TrackPlaybackBundle bundle) {
    if (bundle.playability.isPreviewOnly && bundle.preview.enabled) {
      return bundle.preview.previewStartSeconds;
    }
    return 0;
  }

  double _clampPosition(TrackPlaybackBundle bundle, double positionSeconds) {
    final maxPosition =
        bundle.playability.isPreviewOnly && bundle.preview.enabled
        ? bundle.preview.previewStartSeconds +
              bundle.preview.previewDurationSeconds
        : bundle.durationSeconds;

    final minPosition =
        bundle.playability.isPreviewOnly && bundle.preview.enabled
        ? bundle.preview.previewStartSeconds
        : 0;

    return positionSeconds
        .clamp(minPosition.toDouble(), maxPosition.toDouble())
        .toDouble();
  }

  Future<void> _safeReportEvent(PlaybackEvent event) async {
    try {
      await _reportEvent(event);
    } catch (_) {
      // Keep playback working even if reporting is unsupported or fails.
    }
  }

  /// Called when the user reaches 90 % of a track naturally.
  ///
  /// Online  → POST /tracks/{trackId}/played (server records the completion).
  /// Offline → marks the pending [OfflinePlayRecord] as completed so it is
  ///           sent with the batch when the device comes back online.
  Future<void> _safeReportTrackCompleted(String trackId) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity.any((r) => r != ConnectivityResult.none);

      if (isOnline) {
        await _reportTrackCompleted(trackId);
      } else {
        // Update the offline record so it carries completed: true when flushed.
        await _repository.markOfflinePlayCompleted(trackId);
      }
    } catch (_) {
      // Never interrupt playback because of a reporting failure.
    }
  }
}
