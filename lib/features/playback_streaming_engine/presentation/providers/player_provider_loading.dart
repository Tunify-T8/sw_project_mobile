part of 'player_provider.dart';

extension PlayerNotifierLoading on PlayerNotifier {
  Future<void> loadTrack(
    String trackId, {
    String? privateToken,
    PlaybackQueue? queue,
    bool autoPlay = false,
    PlayerSeedTrack? seedTrack,
  }) async {
    final previous = _current;

    _progressReportTimer?.cancel();
    await _audioPlayer.stop();

    final provisionalBundle = seedTrack?.toPlaybackBundle();
    if (provisionalBundle != null) {
      state = AsyncData(
        PlayerState(
          bundle: provisionalBundle,
          queue: queue,
          isPlaying: false,
          positionSeconds: _initialPositionFor(provisionalBundle).toDouble(),
          isMuted: previous?.isMuted ?? false,
          volume: previous?.volume ?? 1.0,
          isBuffering: true,
          localFilePath: seedTrack?.localFilePath,
        ),
      );
    } else if (previous != null) {
      state = AsyncData(
        previous.copyWith(
          isPlaying: false,
          isBuffering: true,
          queue: queue,
        ),
      );
    } else {
      state = const AsyncLoading();
    }

    state = await AsyncValue.guard(() async {
      final bundle = await _resolveBundle(
        trackId,
        privateToken: privateToken,
        seedTrack: seedTrack,
      );

      final source = await _resolvePlaybackSource(
        trackId,
        seedTrack: seedTrack,
      );

      final initialPosition = _initialPositionFor(bundle).toDouble();

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
      );

      await _prepareAudioSource(nextState, force: true);
      await _applyVolume(nextState);

      if (initialPosition > 0) {
        await _audioPlayer.seek(
          Duration(milliseconds: (initialPosition * 1000).round()),
        );
      }

      return nextState;
    });

    if (state.asData?.value != null) {
      await _persistCurrentSession(
        playerState: state.asData!.value,
        force: true,
      );
    }

    if (autoPlay && state.asData?.value != null) {
      await play();
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
  }) {
    return loadTrack(
      trackId,
      privateToken: privateToken,
      autoPlay: autoPlay,
      seedTrack: seedTrack,
      queue: PlaybackQueue(
        trackIds: trackIds,
        currentIndex: currentIndex,
        shuffle: false,
        repeat: repeat,
      ),
    );
  }
}
