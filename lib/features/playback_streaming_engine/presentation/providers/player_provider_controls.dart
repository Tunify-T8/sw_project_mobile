part of 'player_provider.dart';

extension PlayerNotifierControls on PlayerNotifier {
  Future<void> play() async {
    final current = _current;
    if (current == null || !current.canPlay) return;

    var preparedState = await _ensureFreshPlaybackSource(current);
    if (preparedState == null) return;

    final restartPosition =
        preparedState.positionSeconds >= preparedState.previewEndSeconds
        ? _initialPositionFor(preparedState.bundle!).toDouble()
        : null;

    if (restartPosition != null) {
      await _audioPlayer.seek(
        Duration(milliseconds: (restartPosition * 1000).round()),
      );
      preparedState = preparedState.copyWith(positionSeconds: restartPosition);
      state = AsyncData(preparedState);
    }

    await _applyVolume(preparedState);
    await _audioPlayer.play();

    state = AsyncData(
      preparedState.copyWith(isPlaying: true, isBuffering: false),
    );

    await _safeReportEvent(
      PlaybackEvent(
        trackId: preparedState.bundle!.trackId,
        action: PlaybackAction.play,
        positionSeconds: preparedState.positionSeconds.round(),
      ),
    );

    _startProgressReporting();
  }

  Future<void> pause() async {
    final current = _current;
    if (current == null) return;

    _progressReportTimer?.cancel();
    await _audioPlayer.pause();

    final pausedPosition = _audioPlayer.position.inMilliseconds / 1000.0;

    state = AsyncData(
      current.copyWith(
        isPlaying: false,
        isBuffering: false,
        positionSeconds: _clampPosition(current.bundle!, pausedPosition),
      ),
    );

    await _safeReportEvent(
      PlaybackEvent(
        trackId: current.bundle!.trackId,
        action: PlaybackAction.pause,
        positionSeconds: _clampPosition(
          current.bundle!,
          pausedPosition,
        ).round(),
      ),
    );
  }

  Future<void> seek(num positionSeconds) async {
    final current = _current;
    if (current == null || current.bundle == null) return;

    final clamped = _clampPosition(current.bundle!, positionSeconds.toDouble());

    _isManualSeeking = true;

    await _audioPlayer.seek(Duration(milliseconds: (clamped * 1000).round()));

    state = AsyncData(
      current.copyWith(positionSeconds: clamped, isBuffering: false),
    );

    await _safeReportEvent(
      PlaybackEvent(
        trackId: current.bundle!.trackId,
        action: PlaybackAction.progress,
        positionSeconds: clamped.round(),
      ),
    );

    Future<void>.delayed(const Duration(milliseconds: 180), () {
      _isManualSeeking = false;
    });
  }

  void toggleMute() {
    final current = _current;
    if (current == null) return;

    final next = current.copyWith(isMuted: !current.isMuted);
    state = AsyncData(next);
    unawaited(_applyVolume(next));
  }

  void setVolume(double volume) {
    final current = _current;
    if (current == null) return;

    final safeVolume = volume.clamp(0.0, 1.0).toDouble();
    final next = current.copyWith(volume: safeVolume);
    state = AsyncData(next);
    unawaited(_applyVolume(next));
  }
}
