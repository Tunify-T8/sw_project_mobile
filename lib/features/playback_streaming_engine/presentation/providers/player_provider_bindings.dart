part of 'player_provider.dart';

extension _PlayerNotifierBindings on PlayerNotifier {
  void _attachPlayerBindings() {
    if (_bindingsAttached) return;
    _bindingsAttached = true;

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      final current = _current;
      if (current == null || current.bundle == null) return;

      final clamped = _clampPosition(
        current.bundle!,
        position.inMilliseconds / 1000.0,
      );

      if ((clamped - current.positionSeconds).abs() > 0.03) {
        final nextState = current.copyWith(positionSeconds: clamped);
        _setPlayerState(nextState);
        unawaited(_persistCurrentSession(playerState: nextState));
      }

      if (current.isPreviewOnly &&
          position.inSeconds >= current.previewEndSeconds) {
        unawaited(_handlePreviewCompletion());
      }

      // 90 % completion — report once per track per session.
      final trackId = current.bundle!.trackId;
      final duration =
          current.mediaDurationSeconds ??
          current.bundle!.durationSeconds.toDouble();
      if (!current.isPreviewOnly &&
          duration > 0 &&
          clamped >= duration * 0.9 &&
          !_completedTrackIds.contains(trackId)) {
        _completedTrackIds.add(trackId);
        unawaited(_safeReportTrackCompleted(trackId));
      }
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      final current = _current;
      if (current == null || duration == null) return;

      final seconds = duration.inMilliseconds / 1000.0;
      if (seconds <= 0) return;

      if (((current.mediaDurationSeconds ?? 0) - seconds).abs() > 0.2) {
        final nextState = current.copyWith(mediaDurationSeconds: seconds);
        _setPlayerState(nextState);
        unawaited(_persistCurrentSession(playerState: nextState));
      }
    });

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      audioState,
    ) {
      final current = _current;
      if (current == null) return;

      final isBuffering =
          !_isManualSeeking &&
          (audioState.processingState == just_audio.ProcessingState.loading ||
              audioState.processingState ==
                  just_audio.ProcessingState.buffering);

      if (current.isPlaying != audioState.playing ||
          current.isBuffering != isBuffering) {
        final nextState = current.copyWith(
          isPlaying: audioState.playing,
          isBuffering: isBuffering,
        );
        _setPlayerState(nextState);
        unawaited(
          _persistCurrentSession(
            playerState: nextState,
            force: !audioState.playing,
          ),
        );
      }

      if (audioState.processingState == just_audio.ProcessingState.completed) {
        unawaited(_handlePlaybackCompleted());
      }
    });
  }

  Future<void> _handlePreviewCompletion() async {
    if (_handlingPreviewStop) return;
    _handlingPreviewStop = true;

    try {
      final current = _current;
      if (current == null || current.bundle == null) return;

      _progressReportTimer?.cancel();
      final previewEnd = current.previewEndSeconds.toDouble();

      await _audioPlayer.pause();
      await _audioPlayer.seek(
        Duration(milliseconds: (previewEnd * 1000).round()),
      );

      final previewState = current.copyWith(
        isPlaying: false,
        isBuffering: false,
        positionSeconds: previewEnd,
      );

      _setPlayerState(previewState);
      await _persistCurrentSession(playerState: previewState, force: true);

      await _safeReportEvent(
        PlaybackEvent(
          trackId: current.bundle!.trackId,
          action: PlaybackAction.pause,
          positionSeconds: previewEnd.round(),
        ),
      );
    } finally {
      _handlingPreviewStop = false;
    }
  }

  Future<void> _handlePlaybackCompleted() async {
    if (_handlingCompletion) return;
    _handlingCompletion = true;

    try {
      final current = _current;
      if (current == null || current.bundle == null) return;

      if (current.isPreviewOnly) {
        await _handlePreviewCompletion();
        return;
      }

      if (current.queue != null) {
        final queue = current.queue!;
        final hasNext = queue.currentIndex + 1 < queue.trackIds.length;

        if (hasNext) {
          await next();
          return;
        }

        if (queue.repeat == RepeatMode.all && queue.trackIds.isNotEmpty) {
          await _jumpToIndex(0, queue, autoPlay: true);
          return;
        }
      }

      _progressReportTimer?.cancel();
      final finalPosition = current.visualDurationSeconds.toDouble();

      await _audioPlayer.pause();
      await _audioPlayer.seek(
        Duration(milliseconds: (finalPosition * 1000).round()),
      );

      final completedState = current.copyWith(
        isPlaying: false,
        isBuffering: false,
        positionSeconds: finalPosition,
      );

      _setPlayerState(completedState);
      await _persistCurrentSession(playerState: completedState, force: true);
    } finally {
      _handlingCompletion = false;
    }
  }

  void _startProgressReporting() {
    _progressReportTimer?.cancel();

    _progressReportTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      final current = _current;
      if (current == null || current.bundle == null || !current.isPlaying) {
        _progressReportTimer?.cancel();
        return;
      }

      unawaited(
        _safeReportEvent(
          PlaybackEvent(
            trackId: current.bundle!.trackId,
            action: PlaybackAction.progress,
            positionSeconds: _audioPlayer.position.inSeconds,
          ),
        ),
      );
    });
  }

  void _notifyHistoryPlayed() {
    final current = _current;
    final bundle = current?.bundle;
    if (bundle == null) return;

    final isOfflinePlay = current?.streamUrl == null;

    try {
      final historyTrack = HistoryTrack(
        trackId: bundle.trackId,
        title: bundle.title,
        artist: bundle.artist,
        playedAt: DateTime.now(),
        durationSeconds: bundle.durationSeconds,
        status: bundle.playability.status,
        coverUrl: bundle.coverUrl,
      );

      unawaited(
        _trackHistoryPlayed(
          historyTrack,
          needsBackendSync: isOfflinePlay,
        ),
      );
    } catch (_) {
      // History update is best-effort; never break playback.
    }

    // When playing from a local file the stream endpoint was never called, so
    // the server has no record of this play.  Queue it locally for batch sync.
    if (isOfflinePlay) {
      try {
        unawaited(_repository.addOfflinePlay(bundle.trackId));
      } catch (_) {
        // Queue failure must never interrupt playback.
      }
    }
  }
}
