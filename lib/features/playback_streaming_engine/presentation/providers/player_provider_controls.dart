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

    // just_audio.play() completes when playback finishes or is interrupted,
    // not when playback STARTS. So awaiting it blocks navigation/history/queue.
    unawaited(_audioPlayer.play());

    final playingState = preparedState.copyWith(
      isPlaying: true,
      isBuffering: false,
    );
    state = AsyncData(playingState);
    unawaited(_persistCurrentSession(playerState: playingState, force: true));

    // History is recorded only after 2 seconds of real playback (see
    // _positionSubscription in player_provider_bindings.dart).
    _pendingHistoryTrackId = playingState.bundle?.trackId;

    await _safeReportEvent(
      PlaybackEvent(
        trackId: playingState.bundle!.trackId,
        action: PlaybackAction.play,
        positionSeconds: playingState.positionSeconds.round(),
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

    final pausedState = current.copyWith(
      isPlaying: false,
      isBuffering: false,
      positionSeconds: _clampPosition(current.bundle!, pausedPosition),
    );

    state = AsyncData(pausedState);
    await _persistCurrentSession(playerState: pausedState, force: true);

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

    final soughtState = current.copyWith(
      positionSeconds: clamped,
      isBuffering: false,
    );

    state = AsyncData(soughtState);
    await _persistCurrentSession(playerState: soughtState, force: true);

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
    unawaited(_persistCurrentSession(playerState: next, force: true));
  }

  void setVolume(double volume) {
    final current = _current;
    if (current == null) return;

    final safeVolume = volume.clamp(0.0, 1.0).toDouble();
    final next = current.copyWith(volume: safeVolume);
    state = AsyncData(next);
    unawaited(_applyVolume(next));
    unawaited(_persistCurrentSession(playerState: next, force: true));
  }

  void toggleShuffle() {
    final current = _current;
    if (current == null || current.queue == null) return;

    final next = current.copyWith(
      queue: current.queue!.copyWith(shuffle: !current.queue!.shuffle),
    );
    state = AsyncData(next);
    unawaited(_persistCurrentSession(playerState: next, force: true));
  }

  void toggleRepeat() {
    final current = _current;
    if (current == null || current.queue == null) return;

    final nextRepeat = switch (current.queue!.repeat) {
      RepeatMode.none => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.none,
    };
    final next = current.copyWith(
      queue: current.queue!.copyWith(repeat: nextRepeat),
    );
    state = AsyncData(next);
    unawaited(_persistCurrentSession(playerState: next, force: true));
  }
}
