part of 'player_provider.dart';

extension PlayerNotifierLoading on PlayerNotifier {
  Future<void> loadTrack(
    String trackId, {
    String? privateToken,
    PlaybackQueue? queue,
    bool autoPlay = false,
    PlayerSeedTrack? seedTrack,
    double? initialPositionSeconds,
  }) async {
    if (_isLoadingTrack) {
      debugPrint('[M5 Player] loadTrack ignored while another track is loading');
      return;
    }

    _isLoadingTrack = true;

    try {
      _pendingHistoryTrackId = null;

      final previous = _current;

      _progressReportTimer?.cancel();
      try {
        await _audioPlayer.stop();
      } on just_audio.PlayerInterruptedException {
        debugPrint('[M5 Player] stop ignored because loading was interrupted');
      } catch (error) {
        debugPrint('[M5 Player] stop failed safely: $error');
      }

      _loadedTrackId = null;
      _loadedSourceKey = null;

      final provisionalBundle = seedTrack?.toPlaybackBundle();
      final provisionalPosition = initialPositionSeconds ??
          (provisionalBundle == null
              ? 0.0
              : _initialPositionFor(provisionalBundle).toDouble());

      if (provisionalBundle != null) {
        _setPlayerState(
          PlayerState(
            bundle: provisionalBundle,
            queue: queue,
            isPlaying: false,
            positionSeconds: provisionalPosition,
            isMuted: previous?.isMuted ?? false,
            volume: previous?.volume ?? 1.0,
            isBuffering: true,
            localFilePath: seedTrack?.localFilePath,
            privateToken: privateToken,
          ),
        );
      } else if (previous != null) {
        _setPlayerState(
          previous.copyWith(
            isPlaying: false,
            isBuffering: true,
            queue: queue,
            privateToken: privateToken,
          ),
        );
      } else {
        _setAsyncState(const AsyncLoading());
      }

      _setAsyncState(
        await AsyncValue.guard(() async {
          final bundle = await _resolveBundle(
            trackId,
            privateToken: privateToken,
            seedTrack: seedTrack,
          );

          final source = await _resolvePlaybackSource(
            trackId,
            seedTrack: seedTrack,
            privateToken: privateToken,
          );

          final initialPosition = initialPositionSeconds ??
              _initialPositionFor(bundle).toDouble();

          final nextState = PlayerState(
            bundle: bundle,
            streamUrl: source.streamUrl,
            streamExpiresAt: source.streamExpiresAt,
            localFilePath: source.localFilePath,
            queue: queue,
            isPlaying: false,
            positionSeconds: initialPosition,
            isMuted: previous?.isMuted ?? false,
            volume: previous?.volume ?? 1.0,
            isBuffering: false,
            mediaDurationSeconds: bundle.durationSeconds.toDouble(),
            privateToken: privateToken,
          );

          await _prepareAudioSource(nextState, force: true);
          await _applyVolume(nextState);

          if (initialPosition > 0) {
            try {
              await _audioPlayer.seek(
                Duration(milliseconds: (initialPosition * 1000).round()),
              );
            } on just_audio.PlayerInterruptedException {
              debugPrint('[M5 Player] initial seek ignored because loading was interrupted');
            }
          }

          return nextState;
        }),
      );

      if (state.hasError) {
        debugPrint('loadTrack failed for $trackId: ${state.error}');
      }

      if (state.asData?.value != null) {
        await _persistCurrentSession(
          playerState: state.asData!.value,
          force: true,
        );
      }
    } finally {
      _isLoadingTrack = false;
    }

    if (autoPlay && state.asData?.value != null) {
      await play();
    }

    final landed = state.asData?.value;
    final landedArtistId = landed?.bundle?.artist.id;
    if (landed != null &&
        landed.bundle?.trackId == trackId &&
        landedArtistId != null &&
        landedArtistId.trim().isNotEmpty) {
      unawaited(
        enrichQueueWithArtistTracks(
          artistUserId: landedArtistId,
          anchorTrackId: trackId,
        ),
      );
    }
  }

  Future<void> loadTrackWithQueue({
    required String trackId,
    required List<String> trackIds,
    int currentIndex = 0,
    String? privateToken,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    PlayerSeedTrack? seedTrack,
    QueueSource source = QueueSource.artistCatalog,
    double? initialPositionSeconds,
  }) {
    return loadTrack(
      trackId,
      privateToken: privateToken,
      autoPlay: autoPlay,
      seedTrack: seedTrack,
      initialPositionSeconds: initialPositionSeconds,
      queue: PlaybackQueue(
        trackIds: trackIds,
        currentIndex: currentIndex,
        shuffle: false,
        repeat: repeat,
        source: source,
      ),
    );
  }
}
