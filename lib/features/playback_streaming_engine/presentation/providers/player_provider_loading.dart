part of 'player_provider.dart';

extension PlayerNotifierLoading on PlayerNotifier {
  Future<void> loadTrack(
    String trackId, {
    String? privateToken,
    PlaybackQueue? queue,
    bool autoPlay = false,
    PlayerSeedTrack? seedTrack,
  }) async {
    // Cancel any pending history notification for the previous track so it is
    // never recorded just because the user tapped a new song.
    _pendingHistoryTrackId = null;

    final previous = _current;

    _progressReportTimer?.cancel();
    await _audioPlayer.stop();

    // FIX: always clear the loaded-source cache so _prepareAudioSource
    // unconditionally sets a fresh audio source on every loadTrack call.
    // Without this, if Account B loads the same trackId that Account A had
    // loaded (the cache survived the account switch), the source-key equality
    // check inside _prepareAudioSource skips setAudioSource entirely — leaving
    // just_audio in a stopped state with no playable source, which causes the
    // player screen to hang at paused indefinitely.
    _loadedTrackId = null;
    _loadedSourceKey = null;

    final provisionalBundle = seedTrack?.toPlaybackBundle();
    if (provisionalBundle != null) {
      _setPlayerState(
        PlayerState(
          bundle: provisionalBundle,
          queue: queue,
          isPlaying: false,
          positionSeconds: _initialPositionFor(provisionalBundle).toDouble(),
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
          privateToken: privateToken,
        );

        await _prepareAudioSource(nextState, force: true);
        await _applyVolume(nextState);

        if (initialPosition > 0) {
          await _audioPlayer.seek(
            Duration(milliseconds: (initialPosition * 1000).round()),
          );
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

    if (autoPlay && state.asData?.value != null) {
      await play();
    }

    // Kick off the "more by this artist" enrichment now that the real bundle
    // is in state. Doing it here (instead of polling from the launcher) makes
    // the trigger reliable: we only run it when artist.id is real, never on
    // the seed bundle's empty placeholder. Fire-and-forget — audio start
    // never waits on this.
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
