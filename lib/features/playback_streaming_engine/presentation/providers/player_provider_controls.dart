part of 'player_provider.dart';

extension PlayerNotifierControls on PlayerNotifier {
  Future<void> play() async {
    if (_isTransportBusy) {
      debugPrint('[M5 Player] play ignored during another transport action');
      return;
    }
    _isTransportBusy = true;
    try {
      final current = _current;
      if (current == null || !current.canPlay || current.isBuffering) return;

      var preparedState = await _ensureFreshPlaybackSource(current);
      if (preparedState == null) return;

      final restartPosition =
          preparedState.positionSeconds >= preparedState.previewEndSeconds
          ? _initialPositionFor(preparedState.bundle!).toDouble()
          : null;

      if (restartPosition != null) {
        try {
          await _audioPlayer.seek(
            Duration(milliseconds: (restartPosition * 1000).round()),
          );
        } on just_audio.PlayerInterruptedException {
          debugPrint('[M5 Player] restart seek ignored safely');
          return;
        }
        preparedState = preparedState.copyWith(positionSeconds: restartPosition);
        _setPlayerState(preparedState);
      }

      await _applyVolume(preparedState);

      unawaited(
        _audioPlayer.play().catchError((Object error, StackTrace stackTrace) {
          debugPrint('[M5 Player] play failed safely: $error');
        }),
      );

      final playingState = preparedState.copyWith(
        isPlaying: true,
        isBuffering: false,
      );
      _setPlayerState(playingState);
      unawaited(_persistCurrentSession(playerState: playingState, force: true));

      _pendingHistoryTrackId = playingState.bundle?.trackId;

      await _safeReportEvent(
        PlaybackEvent(
          trackId: playingState.bundle!.trackId,
          action: PlaybackAction.play,
          positionSeconds: playingState.positionSeconds.round(),
        ),
      );

      _startProgressReporting();
    } on just_audio.PlayerInterruptedException {
      debugPrint('[M5 Player] play interrupted safely');
    } finally {
      _isTransportBusy = false;
    }
  }

  Future<void> pause() async {
    if (_isTransportBusy) {
      debugPrint('[M5 Player] pause ignored during another transport action');
      return;
    }
    _isTransportBusy = true;
    try {
      final current = _current;
      if (current == null) return;

      _progressReportTimer?.cancel();
      try {
        await _audioPlayer.pause();
      } on just_audio.PlayerInterruptedException {
        debugPrint('[M5 Player] pause interrupted safely');
      }

      final pausedPosition = _audioPlayer.position.inMilliseconds / 1000.0;

      final pausedState = current.copyWith(
        isPlaying: false,
        isBuffering: false,
        positionSeconds: _clampPosition(current.bundle!, pausedPosition),
      );

      _setPlayerState(pausedState);
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
    } finally {
      _isTransportBusy = false;
    }
  }

  Future<void> seek(num positionSeconds) async {
    if (_isTransportBusy || _isLoadingTrack) {
      debugPrint('[M5 Player] seek ignored while player is busy');
      return;
    }
    _isTransportBusy = true;
    try {
      final current = _current;
      if (current == null || current.bundle == null || current.isBuffering) {
        return;
      }

      final clamped = _clampPosition(current.bundle!, positionSeconds.toDouble());

      _isManualSeeking = true;

      try {
        await _audioPlayer.seek(Duration(milliseconds: (clamped * 1000).round()));
      } on just_audio.PlayerInterruptedException {
        debugPrint('[M5 Player] seek interrupted safely');
        return;
      }

      final soughtState = current.copyWith(
        positionSeconds: clamped,
        isBuffering: false,
      );

      _setPlayerState(soughtState);
      await _persistCurrentSession(playerState: soughtState, force: true);

      await _safeReportEvent(
        PlaybackEvent(
          trackId: current.bundle!.trackId,
          action: PlaybackAction.progress,
          positionSeconds: clamped.round(),
        ),
      );

      Future<void>.delayed(const Duration(milliseconds: 400), () {
        _isManualSeeking = false;
      });
    } finally {
      _isTransportBusy = false;
    }
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
    // Reset load-lock so new tracks can be loaded immediately after sign-in.
    _isLoadingTrack = false;
    _isTransportBusy = false;

    try {
      await _audioPlayer.stop();
    } catch (_) {}

    _loadedTrackId = null;
    _loadedSourceKey = null;
    _lastKnownState = const PlayerState();
    _setAsyncState(const AsyncData(PlayerState()));

    await _deleteCachedPlayerSession();
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
