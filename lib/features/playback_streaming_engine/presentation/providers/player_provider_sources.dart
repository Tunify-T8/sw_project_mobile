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
      // A 4xx response is the backend deliberately refusing the track, so we
      // must not hide it behind seed data. Transport errors can fall back to
      // seed data so cached/offline playback can still open.
      if (_isClientRefusal(error)) {
        rethrow;
      }
      if (seedTrack != null) {
        return seedTrack.toPlaybackBundle();
      }
      rethrow;
    }
  }

  // A 4xx DioException means the server made a deliberate decision — don't mask it.
  bool _isClientRefusal(Object error) {
    if (error is just_audio.PlayerException) return false;
    // Uses duck-typing on the dynamic to avoid importing Dio here just for the type.
    // Dio errors expose `.response?.statusCode` as an int.
    try {
      final dynamic d = error;
      final int? code = d.response?.statusCode as int?;
      if (code != null && code >= 400 && code < 500) return true;
    } catch (_) {
      // Not a Dio-shaped error; treat as transport error.
    }
    return false;
  }

  Future<_ResolvedPlaybackSource> _resolvePlaybackSource(
    String trackId, {
    PlayerSeedTrack? seedTrack,
    String? privateToken,
  }) async {
    final mode = ref.read(playerBackendModeProvider);

    if (mode == PlayerBackendMode.mock && seedTrack != null) {
      final localPath = await _bestLocalAudioPath(trackId, seedTrack);
      if (localPath != null) {
        return _ResolvedPlaybackSource(localFilePath: localPath);
      }

      final directStream = seedTrack.toDirectStreamUrl();
      return _ResolvedPlaybackSource(
        streamUrl: directStream,
        streamExpiresAt: directStream == null
            ? null
            : DateTime.now().add(
                Duration(seconds: directStream.expiresInSeconds),
              ),
        localFilePath: null,
      );
    }

    // If a completed local audio file exists, prefer it. This is what makes a
    // previously cached track playable when Wi-Fi/mobile data is off.
    final cachedPath = await _bestLocalAudioPath(trackId, seedTrack);
    if (cachedPath != null) {
      debugPrint('[M5 Cache] USE_LOCAL_SOURCE track=$trackId path=$cachedPath');
      return _ResolvedPlaybackSource(
        streamUrl: null,
        streamExpiresAt: null,
        localFilePath: cachedPath,
      );
    }

    // No local file. Fail fast when offline instead of waiting for a network
    // timeout. The player screen will show this message.
    if (await _isOffline()) {
      debugPrint('[M5 Cache] OFFLINE_BLOCKED track=$trackId reason=no completed cache');
      throw Exception(
        'This track is not available offline yet. Play it online first and wait until it finishes caching.',
      );
    }

    // Online path: request a playable stream URL from the server.
    final streamUrl = await _requestStream(trackId, privateToken: privateToken);
    debugPrint('[M5 Cache] USE_REMOTE_SOURCE track=$trackId format=${streamUrl.format}');

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

    // If we are offline, always try to switch to the completed local cache.
    // This matters when the player state still contains an old remote streamUrl
    // but the background cache has finished since that state was created.
    if (await _isOffline()) {
      final cachedPath = await _audioCache.cachedAudioPathForTrack(
        current.bundle!.trackId,
      );

      if (cachedPath != null) {
        debugPrint('[M5 Cache] SWITCH_TO_LOCAL_SOURCE track=${current.bundle!.trackId} path=$cachedPath');
        final updated = current.copyWith(
          streamUrl: null,
          streamExpiresAt: null,
          localFilePath: cachedPath,
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

      // If the same remote source is already loaded in just_audio during the
      // current app session, let just_audio try to continue from its in-memory
      // buffer. This supports the exact case: user started the song online,
      // then internet disconnected while the loaded player still has data.
      final remoteKey = current.streamUrl?.url;
      final sameSourceStillLoaded =
          remoteKey != null &&
          _loadedTrackId == current.bundle!.trackId &&
          _loadedSourceKey == remoteKey;

      if (sameSourceStillLoaded) {
        debugPrint('[M5 Cache] CONTINUE_MEMORY_BUFFER track=${current.bundle!.trackId}');
        await _prepareAudioSource(current);
        return current;
      }

      throw Exception(
        'This track is not available offline yet. Play it online first and wait until it finishes caching.',
      );
    }

    final expiresAt = current.streamExpiresAt;
    final mustRefresh =
        current.localFilePath == null &&
        (current.streamUrl == null ||
            (expiresAt != null &&
                DateTime.now().isAfter(
                  expiresAt.subtract(const Duration(seconds: 10)),
                )));

    if (!mustRefresh) {
      await _prepareAudioSource(current);
      return current;
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

    final sourceKey = playerState.localFilePath ?? playerState.streamUrl?.url;

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
      if (playerState.localFilePath != null &&
          playerState.localFilePath!.trim().isNotEmpty) {
        debugPrint('[M5 Cache] PLAYER_SET_FILE track=${activeBundle.trackId} path=${playerState.localFilePath}');
        await _audioPlayer.setFilePath(playerState.localFilePath!);
      } else if (playerState.streamUrl?.url.trim().isNotEmpty == true) {
        debugPrint('[M5 Cache] PLAYER_SET_REMOTE track=${activeBundle.trackId}');
        await _audioPlayer.setAudioSource(
          just_audio.AudioSource.uri(Uri.parse(playerState.streamUrl!.url)),
          preload: true,
        );
      } else {
        throw Exception('No playable audio source is available for this track.');
      }
    } on just_audio.PlayerInterruptedException {
      return;
    }

    if (playerState.streamUrl?.url.trim().isNotEmpty == true &&
        (playerState.localFilePath == null ||
            playerState.localFilePath!.trim().isEmpty)) {
      // Download audio + artwork to device storage in the background so later
      // plays can use a real local file while offline. HLS manifests (.m3u8)
      // are skipped inside AudioCacheService because they are not one simple
      // audio file.
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

  Future<String?> _bestLocalAudioPath(
    String trackId,
    PlayerSeedTrack? seedTrack,
  ) async {
    final seedPath = seedTrack?.localFilePath;
    if (seedPath != null && seedPath.trim().isNotEmpty) {
      final file = File(seedPath);
      try {
        if (await file.exists() && await file.length() >= 8 * 1024) {
          debugPrint('[M5 Cache] HIT_SEED_PATH track=$trackId path=$seedPath');
          return seedPath;
        }
      } catch (_) {}
    }

    return _audioCache.cachedAudioPathForTrack(trackId);
  }

  Future<bool> _isOffline() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity.every((result) => result == ConnectivityResult.none);
  }

  Future<void> _applyVolume(PlayerState playerState) async {
    final targetVolume = playerState.isMuted ? 0.0 : playerState.volume;
    await _audioPlayer.setVolume(targetVolume.clamp(0.0, 1.0).toDouble());
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

}
