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
      _setPlayerState(preparedState);
    }

    await _applyVolume(preparedState);

    // just_audio.play() completes when playback finishes or is interrupted,
    // not when playback STARTS. So awaiting it blocks navigation/history/queue.
    unawaited(
      _audioPlayer.play().catchError((Object error, StackTrace stackTrace) {
        debugPrint('just_audio play failed: $error');
      }),
    );

    final playingState = preparedState.copyWith(
      isPlaying: true,
      isBuffering: false,
    );
    _setPlayerState(playingState);
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

    _setPlayerState(pausedState);
    await _persistCurrentSession(playerState: pausedState, force: true);
    _rememberCurrentHistoryPosition(pausedState, force: true);

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

    _setPlayerState(soughtState);
    await _persistCurrentSession(playerState: soughtState, force: true);
    _rememberCurrentHistoryPosition(soughtState, force: true);

    await _safeReportEvent(
      PlaybackEvent(
        trackId: current.bundle!.trackId,
        action: PlaybackAction.progress,
        positionSeconds: clamped.round(),
      ),
    );

    // M5-002: 180ms was not enough on slower networks — the position stream
    // could still emit a pre-seek position after the flag was cleared.
    // 400ms covers typical remote-seek latency without feeling laggy.
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      _isManualSeeking = false;
    });
  }

  void toggleMute() {
    final current = _current;
    if (current == null) return;

    final next = current.copyWith(isMuted: !current.isMuted);
    _setPlayerState(next);
    unawaited(_applyVolume(next));
    unawaited(_persistCurrentSession(playerState: next, force: true));
  }

  void setVolume(double volume) {
    final current = _current;
    if (current == null) return;

    final safeVolume = volume.clamp(0.0, 1.0).toDouble();
    final next = current.copyWith(volume: safeVolume);
    _setPlayerState(next);
    unawaited(_applyVolume(next));
    unawaited(_persistCurrentSession(playerState: next, force: true));
  }

  void toggleShuffle() {
    final current = _current;
    if (current == null || current.queue == null) return;

    final queue = current.queue!;
    final newShuffle = !queue.shuffle;

    // Single-track queue → nothing to shuffle; still flip the flag so the icon
    // reflects user intent (next track enqueued will land at a random spot).
    if (queue.trackIds.length <= 1) {
      final next = current.copyWith(
        queue: queue.copyWith(shuffle: newShuffle),
      );
      _setPlayerState(next);
      unawaited(_persistCurrentSession(playerState: next, force: true));
      return;
    }

    PlaybackQueue nextQueue;

    if (newShuffle) {
      // Turning shuffle ON:
      //  - Snapshot the current order so we can undo it later.
      //  - Shuffle only the slice AFTER the current track; the already-played
      //    portion stays intact so next/previous behave predictably.
      final original = List<String>.from(queue.trackIds);
      final after = queue.trackIds.sublist(queue.currentIndex + 1)..shuffle();
      final shuffled = <String>[
        ...queue.trackIds.sublist(0, queue.currentIndex + 1),
        ...after,
      ];
      nextQueue = queue.copyWith(
        trackIds: shuffled,
        shuffle: true,
        originalTrackIds: original,
      );
    } else {
      // Turning shuffle OFF:
      //  - Restore original order (if we have it).
      //  - Re-point currentIndex to wherever the current track now lives.
      //  - Drop the snapshot so copyWith can't leak it into the next session.
      final currentTrackId = queue.currentTrackId;
      final restored =
          queue.originalTrackIds ?? List<String>.from(queue.trackIds);
      final restoredIndex = currentTrackId == null
          ? 0
          : restored.indexOf(currentTrackId).clamp(0, restored.length - 1);

      nextQueue = queue.copyWith(
        trackIds: restored,
        shuffle: false,
        currentIndex: restoredIndex,
        clearOriginalTrackIds: true,
      );
    }

    final next = current.copyWith(queue: nextQueue);
    _setPlayerState(next);
    unawaited(_persistCurrentSession(playerState: next, force: true));
  }

  // Called externally (e.g. from the delete-track flow) when a track has been
  // removed from the backend. If it's what we're currently playing, stop audio,
  // cancel any pending history write, and clear state so the mini-player
  // disappears and the cached session is wiped from secure storage
  // (see _persistCurrentSession — bundle==null → delete branch).
  //
  // No-op if the current track is different (or nothing is playing), so it's
  // always safe to call from a bulk/batch delete.
  Future<void> stopIfPlaying(String trackId) async {
    final current = _current;
    if (current == null || current.bundle?.trackId != trackId) return;

    _progressReportTimer?.cancel();
    _pendingHistoryTrackId = null;
    await _audioPlayer.stop();

    // Preserve volume/mute so the next track the user plays picks them up.
    final cleared = PlayerState(
      isMuted: current.isMuted,
      volume: current.volume,
    );
    _loadedTrackId = null;
    _loadedSourceKey = null;
    _setPlayerState(cleared);

    await _persistCurrentSession(playerState: cleared, force: true);
  }

  Future<void> clearPlaybackSession() async {
    _progressReportTimer?.cancel();
    _pendingHistoryTrackId = null;
    _completedTrackIds.clear();

    try {
      await _audioPlayer.stop();
    } catch (_) {}

    _loadedTrackId = null;
    _loadedSourceKey = null;
    _lastKnownState = const PlayerState();
    _setAsyncState(const AsyncData(PlayerState()));

    await PlayerNotifier._storage.delete(
      key: StorageKeys.cachedPlayerSession,
    );
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
    _setPlayerState(next);
    unawaited(_persistCurrentSession(playerState: next, force: true));
  }
}
