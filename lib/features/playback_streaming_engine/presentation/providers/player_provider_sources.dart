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
    } catch (_) {
      // Server reachable but request failed — fall back to seed metadata.
      if (seedTrack != null) {
        return seedTrack.toPlaybackBundle();
      }
      rethrow;
    }
  }

  Future<_ResolvedPlaybackSource> _resolvePlaybackSource(
    String trackId, {
    PlayerSeedTrack? seedTrack,
  }) async {
    final mode = ref.read(playerBackendModeProvider);

    if (mode == PlayerBackendMode.mock && seedTrack != null) {
      final directStream = seedTrack.toDirectStreamUrl();

      return _ResolvedPlaybackSource(
        streamUrl: directStream,
        streamExpiresAt: directStream == null
            ? null
            : DateTime.now().add(
                Duration(seconds: directStream.expiresInSeconds),
              ),
        localFilePath: seedTrack.localFilePath,
      );
    }

    // A locally cached audio file — plays fully offline, no server call needed.
    if (seedTrack?.localFilePath?.trim().isNotEmpty == true) {
      return _ResolvedPlaybackSource(
        streamUrl: null,
        streamExpiresAt: null,
        localFilePath: seedTrack!.localFilePath,
      );
    }

    // No local file.  Fail fast when offline instead of waiting for the
    // connection timeout (which can be up to 60 s).
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.every((r) => r == ConnectivityResult.none)) {
      throw Exception('No internet connection and no local audio source available.');
    }

    // Request a signed streaming URL from the server (the only correct way
    // to play a track online — never use the raw upload audioUrl directly).
    final streamUrl = await _requestStream(trackId);

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

    final resolved = await _resolvePlaybackSource(current.bundle!.trackId);

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

    state = AsyncData(updated);
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

    if (playerState.localFilePath != null &&
        playerState.localFilePath!.trim().isNotEmpty) {
      await _audioPlayer.setFilePath(playerState.localFilePath!);
    } else if (playerState.streamUrl?.url.trim().isNotEmpty == true) {
      // Use AudioSource.uri for better caching and buffering control.
      // This avoids repeated seeks causing stuttering on remote URLs.
      await _audioPlayer.setAudioSource(
        just_audio.AudioSource.uri(
          Uri.parse(playerState.streamUrl!.url),
        ),
        preload: true,
      );

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