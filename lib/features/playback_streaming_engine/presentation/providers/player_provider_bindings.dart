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
        state = AsyncData(current.copyWith(positionSeconds: clamped));
      }

      if (current.isPreviewOnly &&
          position.inSeconds >= current.previewEndSeconds) {
        unawaited(_handlePreviewCompletion());
      }
    });

    _durationSubscription = _audioPlayer.durationStream.listen((_) {});

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
        state = AsyncData(
          current.copyWith(
            isPlaying: audioState.playing,
            isBuffering: isBuffering,
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

      state = AsyncData(
        current.copyWith(
          isPlaying: false,
          isBuffering: false,
          positionSeconds: previewEnd,
        ),
      );

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
      final finalPosition = current.bundle!.durationSeconds.toDouble();

      await _audioPlayer.pause();
      await _audioPlayer.seek(
        Duration(milliseconds: (finalPosition * 1000).round()),
      );

      state = AsyncData(
        current.copyWith(
          isPlaying: false,
          isBuffering: false,
          positionSeconds: finalPosition,
        ),
      );
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
}
