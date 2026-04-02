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

    try {
      return await _getBundle(trackId, privateToken: privateToken);
    } catch (_) {
      if (mode == PlayerBackendMode.mock && seedTrack != null) {
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
          // Pre-load headers can be added here for auth if needed
        ),
        preload: true,
      );
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
}