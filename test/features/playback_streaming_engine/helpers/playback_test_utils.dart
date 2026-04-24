import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/global_track_store.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_item.dart';
import 'package:software_project/features/playback_streaming_engine/data/api/streaming_api.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/history_track_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/playback_context_response_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/stream_response_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/track_playback_bundle_dto.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/history_track.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/offline_play_record.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playability_info.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_context_request.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_event.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_queue.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_status.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/player_seed_track.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/preview_info.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/stream_url.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/track_artist_summary.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/track_engagement.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/track_playback_bundle.dart';
import 'package:software_project/features/playback_streaming_engine/domain/repositories/player_repository.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/listening_history_provider.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_provider.dart';

const MethodChannel _audioSessionChannel = MethodChannel(
  'com.ryanheise.audio_session',
);

PlaybackTestEnvironment createPlaybackTestEnvironment({
  Map<String, String>? seededStorage,
  List<ConnectivityResult>? connectivityResults,
}) {
  final environment = PlaybackTestEnvironment(
    seededStorage: seededStorage,
    connectivityResults: connectivityResults,
  );
  environment.install();
  return environment;
}

class PlaybackTestEnvironment {
  PlaybackTestEnvironment({
    Map<String, String>? seededStorage,
    List<ConnectivityResult>? connectivityResults,
  })  : storage = FakeSecureStoragePlatform(seededStorage),
        connectivity = FakeConnectivityPlatform(
          connectivityResults ?? const [ConnectivityResult.wifi],
        ),
        justAudio = FakeJustAudioPlatform();

  final FakeSecureStoragePlatform storage;
  final FakeConnectivityPlatform connectivity;
  final FakeJustAudioPlatform justAudio;

  void install() {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStoragePlatform.instance = storage;
    ConnectivityPlatform.instance = connectivity;
    JustAudioPlatform.instance = justAudio;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_audioSessionChannel, (_) async => null);
    GlobalTrackStore.instance.clear();
  }

  Future<void> dispose() async {
    GlobalTrackStore.instance.clear();
    await justAudio.disposeAllPlayers(DisposeAllPlayersRequest());
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_audioSessionChannel, null);
  }
}

class FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  FakeSecureStoragePlatform([Map<String, String>? seededValues])
      : _values = {...?seededValues};

  final Map<String, String> _values;

  Map<String, String> get values => Map.unmodifiable(_values);

  void seed(String key, String value) {
    _values[key] = value;
  }

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _values[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    return _values[key];
  }

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async {
    return _values.containsKey(key);
  }

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _values.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async {
    return Map<String, String>.from(_values);
  }

  @override
  Future<void> deleteAll({
    required Map<String, String> options,
  }) async {
    _values.clear();
  }
}

class FakeConnectivityPlatform extends ConnectivityPlatform {
  FakeConnectivityPlatform(List<ConnectivityResult> currentResults)
      : _currentResults = List<ConnectivityResult>.from(currentResults);

  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();
  List<ConnectivityResult> _currentResults;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return List<ConnectivityResult>.from(_currentResults);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  void setResults(List<ConnectivityResult> results) {
    _currentResults = List<ConnectivityResult>.from(results);
    _controller.add(List<ConnectivityResult>.from(_currentResults));
  }
}

class FakeJustAudioPlatform extends JustAudioPlatform {
  final Map<String, FakeAudioPlayerPlatform> _players = {};

  FakeAudioPlayerPlatform? get mostRecentPlayer =>
      _players.isEmpty ? null : _players.values.last;

  @override
  Future<AudioPlayerPlatform> init(InitRequest request) async {
    final player = FakeAudioPlayerPlatform(request.id);
    _players[request.id] = player;
    return player;
  }

  @override
  Future<DisposePlayerResponse> disposePlayer(
    DisposePlayerRequest request,
  ) async {
    final player = _players.remove(request.id);
    if (player != null) {
      await player.dispose(DisposeRequest());
    }
    return DisposePlayerResponse();
  }

  @override
  Future<DisposeAllPlayersResponse> disposeAllPlayers(
    DisposeAllPlayersRequest request,
  ) async {
    final players = _players.values.toList(growable: false);
    _players.clear();
    for (final player in players) {
      await player.dispose(DisposeRequest());
    }
    return DisposeAllPlayersResponse();
  }
}

class FakeAudioPlayerPlatform extends AudioPlayerPlatform {
  FakeAudioPlayerPlatform(super.id);

  final StreamController<PlaybackEventMessage> _playbackEvents =
      StreamController<PlaybackEventMessage>.broadcast();
  final StreamController<PlayerDataMessage> _playerData =
      StreamController<PlayerDataMessage>.broadcast();

  AudioSourceMessage? _audioSource;
  ProcessingStateMessage _processingState = ProcessingStateMessage.idle;
  Duration _updatePosition = Duration.zero;
  DateTime _updateTime = DateTime.now();
  Duration? _duration;
  int? _index;
  bool _playing = false;
  double _speed = 1.0;

  @override
  Stream<PlaybackEventMessage> get playbackEventMessageStream =>
      _playbackEvents.stream;

  @override
  Stream<PlayerDataMessage> get playerDataMessageStream => _playerData.stream;

  Duration get position => _updatePosition;
  bool get playing => _playing;

  @override
  Future<LoadResponse> load(LoadRequest request) async {
    final playlist =
        request.audioSourceMessage as ConcatenatingAudioSourceMessage;
    final children = playlist.children;
    _audioSource = children.isEmpty ? null : children.first;
    _duration = _durationForSource(_audioSource);
    _index = request.initialIndex ?? 0;
    _setPosition(request.initialPosition ?? Duration.zero);
    _processingState = ProcessingStateMessage.ready;
    _broadcast();
    return LoadResponse(duration: _duration);
  }

  @override
  Future<PlayResponse> play(PlayRequest request) async {
    _playing = true;
    _broadcast();
    return PlayResponse();
  }

  @override
  Future<PauseResponse> pause(PauseRequest request) async {
    _playing = false;
    _broadcast();
    return PauseResponse();
  }

  @override
  Future<SeekResponse> seek(SeekRequest request) async {
    _setPosition(request.position ?? Duration.zero);
    _index = request.index ?? _index ?? 0;
    _broadcast();
    return SeekResponse();
  }

  @override
  Future<SetVolumeResponse> setVolume(SetVolumeRequest request) async {
    _playerData.add(PlayerDataMessage(volume: request.volume));
    return SetVolumeResponse();
  }

  @override
  Future<SetSpeedResponse> setSpeed(SetSpeedRequest request) async {
    _speed = request.speed;
    _playerData.add(PlayerDataMessage(speed: request.speed));
    return SetSpeedResponse();
  }

  @override
  Future<SetPitchResponse> setPitch(SetPitchRequest request) async {
    return SetPitchResponse();
  }

  @override
  Future<SetSkipSilenceResponse> setSkipSilence(
    SetSkipSilenceRequest request,
  ) async {
    return SetSkipSilenceResponse();
  }

  @override
  Future<SetLoopModeResponse> setLoopMode(SetLoopModeRequest request) async {
    _playerData.add(PlayerDataMessage(loopMode: request.loopMode));
    return SetLoopModeResponse();
  }

  @override
  Future<SetShuffleModeResponse> setShuffleMode(
    SetShuffleModeRequest request,
  ) async {
    _playerData.add(PlayerDataMessage(shuffleMode: request.shuffleMode));
    return SetShuffleModeResponse();
  }

  @override
  Future<SetShuffleOrderResponse> setShuffleOrder(
    SetShuffleOrderRequest request,
  ) async {
    return SetShuffleOrderResponse();
  }

  @override
  Future<SetAutomaticallyWaitsToMinimizeStallingResponse>
      setAutomaticallyWaitsToMinimizeStalling(
    SetAutomaticallyWaitsToMinimizeStallingRequest request,
  ) async {
    return SetAutomaticallyWaitsToMinimizeStallingResponse();
  }

  @override
  Future<SetCanUseNetworkResourcesForLiveStreamingWhilePausedResponse>
      setCanUseNetworkResourcesForLiveStreamingWhilePaused(
    SetCanUseNetworkResourcesForLiveStreamingWhilePausedRequest request,
  ) async {
    return SetCanUseNetworkResourcesForLiveStreamingWhilePausedResponse();
  }

  @override
  Future<SetPreferredPeakBitRateResponse> setPreferredPeakBitRate(
    SetPreferredPeakBitRateRequest request,
  ) async {
    return SetPreferredPeakBitRateResponse();
  }

  @override
  Future<SetAllowsExternalPlaybackResponse> setAllowsExternalPlayback(
    SetAllowsExternalPlaybackRequest request,
  ) async {
    return SetAllowsExternalPlaybackResponse();
  }

  @override
  Future<SetAndroidAudioAttributesResponse> setAndroidAudioAttributes(
    SetAndroidAudioAttributesRequest request,
  ) async {
    return SetAndroidAudioAttributesResponse();
  }

  @override
  Future<DisposeResponse> dispose(DisposeRequest request) async {
    _playing = false;
    _processingState = ProcessingStateMessage.idle;
    if (!_playbackEvents.isClosed) {
      _broadcast();
      await _playbackEvents.close();
    }
    if (!_playerData.isClosed) {
      await _playerData.close();
    }
    return DisposeResponse();
  }

  @override
  Future<ConcatenatingInsertAllResponse> concatenatingInsertAll(
    ConcatenatingInsertAllRequest request,
  ) async {
    return ConcatenatingInsertAllResponse();
  }

  @override
  Future<ConcatenatingRemoveRangeResponse> concatenatingRemoveRange(
    ConcatenatingRemoveRangeRequest request,
  ) async {
    return ConcatenatingRemoveRangeResponse();
  }

  @override
  Future<ConcatenatingMoveResponse> concatenatingMove(
    ConcatenatingMoveRequest request,
  ) async {
    return ConcatenatingMoveResponse();
  }

  @override
  Future<AudioEffectSetEnabledResponse> audioEffectSetEnabled(
    AudioEffectSetEnabledRequest request,
  ) async {
    return AudioEffectSetEnabledResponse();
  }

  @override
  Future<AndroidLoudnessEnhancerSetTargetGainResponse>
      androidLoudnessEnhancerSetTargetGain(
    AndroidLoudnessEnhancerSetTargetGainRequest request,
  ) async {
    return AndroidLoudnessEnhancerSetTargetGainResponse();
  }

  @override
  Future<AndroidEqualizerGetParametersResponse> androidEqualizerGetParameters(
    AndroidEqualizerGetParametersRequest request,
  ) async {
    return AndroidEqualizerGetParametersResponse(
      parameters: AndroidEqualizerParametersMessage(
        minDecibels: 0,
        maxDecibels: 0,
        bands: <AndroidEqualizerBandMessage>[],
      ),
    );
  }

  @override
  Future<AndroidEqualizerBandSetGainResponse> androidEqualizerBandSetGain(
    AndroidEqualizerBandSetGainRequest request,
  ) async {
    return AndroidEqualizerBandSetGainResponse();
  }

  @override
  Future<SetWebCrossOriginResponse> setWebCrossOrigin(
    SetWebCrossOriginRequest request,
  ) async {
    return SetWebCrossOriginResponse();
  }

  @override
  Future<SetWebSinkIdResponse> setWebSinkId(
    SetWebSinkIdRequest request,
  ) async {
    return SetWebSinkIdResponse();
  }

  void emitPlaybackEvent({
    Duration? position,
    Duration? duration,
    ProcessingStateMessage? processingState,
    int? currentIndex,
    bool? playing,
  }) {
    if (position != null) {
      _setPosition(position);
    }
    if (duration != null) {
      _duration = duration;
    }
    if (processingState != null) {
      _processingState = processingState;
    }
    if (currentIndex != null) {
      _index = currentIndex;
    }
    if (playing != null) {
      _playing = playing;
    }
    _broadcast();
  }

  void _setPosition(Duration value) {
    _updatePosition = value;
    _updateTime = DateTime.now();
  }

  Duration? _durationForSource(AudioSourceMessage? source) {
    if (source case UriAudioSourceMessage()) {
      return const Duration(minutes: 3);
    }
    return const Duration(minutes: 3);
  }

  void _broadcast() {
    if (_playbackEvents.isClosed) return;
    _playbackEvents.add(
      PlaybackEventMessage(
        processingState: _processingState,
        updatePosition: _updatePosition,
        updateTime: _updateTime,
        bufferedPosition: _duration ?? _updatePosition,
        duration: _duration,
        icyMetadata: null,
        currentIndex: _index,
        androidAudioSessionId: null,
      ),
    );
  }
}

class FakeStreamingApi extends StreamingApi {
  FakeStreamingApi() : super(Dio());

  Future<TrackPlaybackBundleDto> Function(
    String trackId, {
    String? privateToken,
  })? getPlaybackBundleHandler;
  Future<StreamResponseDto> Function(
    String trackId, {
    String quality,
    String? privateToken,
  })? requestStreamUrlHandler;
  Future<void> Function({
    required String trackId,
    required PlaybackAction action,
    required int positionSeconds,
  })? reportPlaybackEventHandler;
  Future<PlaybackContextResponseDto> Function({
    required String contextType,
    required String contextId,
    String? startTrackId,
    bool shuffle,
    String repeat,
  })? buildPlaybackQueueHandler;
  Future<List<HistoryTrackDto>> Function({
    int page,
    int limit,
  })? getListeningHistoryHandler;
  Future<void> Function()? clearListeningHistoryHandler;
  Future<void> Function(String trackId)? reportTrackCompletedHandler;
  Future<void> Function(List<OfflinePlayRecord> plays)?
      reportBatchOfflinePlaysHandler;

  @override
  Future<TrackPlaybackBundleDto> getPlaybackBundle(
    String trackId, {
    String? privateToken,
  }) async {
    final handler = getPlaybackBundleHandler;
    if (handler != null) {
      return handler(trackId, privateToken: privateToken);
    }
    return TrackPlaybackBundleDto.fromJson(sampleBundleJson(trackId: trackId));
  }

  @override
  Future<StreamResponseDto> requestStreamUrl(
    String trackId, {
    String quality = 'auto',
    String? privateToken,
  }) async {
    final handler = requestStreamUrlHandler;
    if (handler != null) {
      return handler(trackId, quality: quality, privateToken: privateToken);
    }
    return StreamResponseDto.fromJson(
      sampleStreamResponseJson(trackId: trackId),
      trackId,
    );
  }

  @override
  Future<void> reportPlaybackEvent({
    required String trackId,
    required PlaybackAction action,
    required int positionSeconds,
  }) async {
    final handler = reportPlaybackEventHandler;
    if (handler != null) {
      return handler(
        trackId: trackId,
        action: action,
        positionSeconds: positionSeconds,
      );
    }
  }

  @override
  Future<PlaybackContextResponseDto> buildPlaybackQueue({
    required String contextType,
    required String contextId,
    String? startTrackId,
    bool shuffle = false,
    String repeat = 'none',
  }) async {
    final handler = buildPlaybackQueueHandler;
    if (handler != null) {
      return handler(
        contextType: contextType,
        contextId: contextId,
        startTrackId: startTrackId,
        shuffle: shuffle,
        repeat: repeat,
      );
    }
    return PlaybackContextResponseDto(
      trackIds: <String>[
        if (startTrackId != null) startTrackId,
        'track-2',
        'track-3',
      ],
      currentIndex: 0,
      shuffle: shuffle,
      repeat: repeat,
    );
  }

  @override
  Future<List<HistoryTrackDto>> getListeningHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final handler = getListeningHistoryHandler;
    if (handler != null) {
      return handler(page: page, limit: limit);
    }
    return <HistoryTrackDto>[HistoryTrackDto.fromJson(sampleHistoryJson())];
  }

  @override
  Future<void> clearListeningHistory() async {
    final handler = clearListeningHistoryHandler;
    if (handler != null) {
      return handler();
    }
  }

  @override
  Future<void> reportTrackCompleted(String trackId) async {
    final handler = reportTrackCompletedHandler;
    if (handler != null) {
      return handler(trackId);
    }
  }

  @override
  Future<void> reportBatchOfflinePlays(List<OfflinePlayRecord> plays) async {
    final handler = reportBatchOfflinePlaysHandler;
    if (handler != null) {
      return handler(plays);
    }
  }
}

class FakePlayerRepository implements PlayerRepository {
  Future<TrackPlaybackBundle> Function(
    String trackId, {
    String? privateToken,
  })? getPlaybackBundleHandler;
  Future<StreamUrl> Function(
    String trackId, {
    String quality,
    String? privateToken,
  })? requestStreamUrlHandler;
  Future<void> Function(PlaybackEvent event)? reportPlaybackEventHandler;
  Future<PlaybackQueue> Function(PlaybackContextRequest request)?
      buildPlaybackQueueHandler;
  Future<List<HistoryTrack>> Function({int page, int limit})?
      getListeningHistoryHandler;
  Future<void> Function()? clearListeningHistoryHandler;
  Future<void> Function(String trackId)? reportTrackCompletedHandler;
  Future<void> Function(String trackId)? addOfflinePlayHandler;
  Future<void> Function(String trackId)? markOfflinePlayCompletedHandler;

  final List<PlaybackEvent> reportedEvents = <PlaybackEvent>[];
  final List<String> addedOfflinePlays = <String>[];
  final List<String> completedOfflinePlays = <String>[];

  @override
  Future<TrackPlaybackBundle> getPlaybackBundle(
    String trackId, {
    String? privateToken,
  }) async {
    final handler = getPlaybackBundleHandler;
    if (handler != null) {
      return handler(trackId, privateToken: privateToken);
    }
    return sampleBundle(trackId: trackId);
  }

  @override
  Future<StreamUrl> requestStreamUrl(
    String trackId, {
    String quality = 'auto',
    String? privateToken,
  }) async {
    final handler = requestStreamUrlHandler;
    if (handler != null) {
      return handler(trackId, quality: quality, privateToken: privateToken);
    }
    return sampleStreamUrl(trackId: trackId);
  }

  @override
  Future<void> reportPlaybackEvent(PlaybackEvent event) async {
    reportedEvents.add(event);
    final handler = reportPlaybackEventHandler;
    if (handler != null) {
      return handler(event);
    }
  }

  @override
  Future<PlaybackQueue> buildPlaybackQueue(
    PlaybackContextRequest request,
  ) async {
    final handler = buildPlaybackQueueHandler;
    if (handler != null) {
      return handler(request);
    }
    return PlaybackQueue(
      trackIds: <String>[
        request.startTrackId ?? 'track-1',
        'track-2',
        'track-3',
      ],
      currentIndex: 0,
      shuffle: request.shuffle,
      repeat: request.repeat,
    );
  }

  @override
  Future<List<HistoryTrack>> getListeningHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final handler = getListeningHistoryHandler;
    if (handler != null) {
      return handler(page: page, limit: limit);
    }
    return <HistoryTrack>[sampleHistoryTrack()];
  }

  @override
  Future<void> clearListeningHistory() async {
    final handler = clearListeningHistoryHandler;
    if (handler != null) {
      return handler();
    }
  }

  @override
  Future<void> reportTrackCompleted(String trackId) async {
    final handler = reportTrackCompletedHandler;
    if (handler != null) {
      return handler(trackId);
    }
  }

  @override
  Future<void> addOfflinePlay(String trackId) async {
    addedOfflinePlays.add(trackId);
    final handler = addOfflinePlayHandler;
    if (handler != null) {
      return handler(trackId);
    }
  }

  @override
  Future<void> markOfflinePlayCompleted(String trackId) async {
    completedOfflinePlays.add(trackId);
    final handler = markOfflinePlayCompletedHandler;
    if (handler != null) {
      return handler(trackId);
    }
  }
}

class TestPlayerNotifier extends PlayerNotifier {
  TestPlayerNotifier(this.currentState);

  PlayerState currentState;
  int playCalls = 0;
  int pauseCalls = 0;
  int nextCalls = 0;
  int previousCalls = 0;
  int jumpCalls = 0;
  int toggleMuteCalls = 0;
  int setVolumeCalls = 0;
  int seekCalls = 0;
  int loadTrackWithQueueCalls = 0;

  @override
  Future<PlayerState> build() async {
    return currentState;
  }

  void emit(PlayerState value) {
    currentState = value;
    state = AsyncData(value);
  }

  void emitAsync(AsyncValue<PlayerState> value) {
    state = value;
    if (value case AsyncData<PlayerState>(:final value)) {
      currentState = value;
    }
  }

  @override
  Future<void> play() async {
    playCalls++;
    emit(currentState.copyWith(isPlaying: true));
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    emit(currentState.copyWith(isPlaying: false));
  }

  @override
  Future<void> next() async {
    nextCalls++;
  }

  @override
  Future<void> previous() async {
    previousCalls++;
  }

  @override
  Future<void> jumpToQueueIndex(int index) async {
    jumpCalls++;
    final queue = currentState.queue;
    if (queue != null) {
      emit(currentState.copyWith(queue: queue.copyWith(currentIndex: index)));
    }
  }

  @override
  Future<void> seek(num positionSeconds) async {
    seekCalls++;
    emit(currentState.copyWith(positionSeconds: positionSeconds.toDouble()));
  }

  @override
  void toggleMute() {
    toggleMuteCalls++;
    emit(currentState.copyWith(isMuted: !currentState.isMuted));
  }

  @override
  void setVolume(double volume) {
    setVolumeCalls++;
    emit(currentState.copyWith(volume: volume));
  }

  @override
  Future<void> loadTrackWithQueue({
    required String trackId,
    required List<String> trackIds,
    int currentIndex = 0,
    String? privateToken,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    PlayerSeedTrack? seedTrack,
  }) async {
    loadTrackWithQueueCalls++;
    emit(
      PlayerState(
        bundle: sampleBundle(trackId: trackId),
        queue: PlaybackQueue(
          trackIds: trackIds,
          currentIndex: currentIndex,
          shuffle: false,
          repeat: repeat,
        ),
        isPlaying: autoPlay,
      ),
    );
  }
}

class TestListeningHistoryNotifier extends ListeningHistoryNotifier {
  TestListeningHistoryNotifier(this.currentState);

  ListeningHistoryState currentState;
  int refreshCalls = 0;
  int loadMoreCalls = 0;
  int clearCalls = 0;
  int trackPlayedCalls = 0;
  HistoryTrack? lastTrackedHistory;
  bool? lastNeedsBackendSync;

  @override
  Future<ListeningHistoryState> build() async {
    return currentState;
  }

  void emit(ListeningHistoryState value) {
    currentState = value;
    state = AsyncData(value);
  }

  void emitAsync(AsyncValue<ListeningHistoryState> value) {
    state = value;
    if (value case AsyncData<ListeningHistoryState>(:final value)) {
      currentState = value;
    }
  }

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }

  @override
  Future<void> loadMore() async {
    loadMoreCalls++;
  }

  @override
  Future<void> clearHistory() async {
    clearCalls++;
    emit(
      const ListeningHistoryState(
        tracks: <HistoryTrack>[],
        currentPage: 1,
        hasMore: false,
        wasClearedLocally: true,
      ),
    );
  }

  @override
  Future<void> trackPlayed(
    HistoryTrack track, {
    bool needsBackendSync = false,
  }) async {
    trackPlayedCalls++;
    lastTrackedHistory = track;
    lastNeedsBackendSync = needsBackendSync;
  }
}

TrackPlaybackBundle sampleBundle({
  String trackId = 'track-1',
  String title = 'Night Drive',
  String artistName = 'DJ Test',
  int durationSeconds = 180,
  PlaybackStatus status = PlaybackStatus.playable,
  BlockedReason? blockedReason,
  bool previewEnabled = false,
  int previewStartSeconds = 0,
  int previewDurationSeconds = 30,
  bool isLiked = false,
  String waveformUrl = '',
  String coverUrl = '',
  DateTime? scheduledReleaseDate,
}) {
  return TrackPlaybackBundle(
    trackId: trackId,
    title: title,
    artist: TrackArtistSummary(
      id: 'artist-1',
      name: artistName,
      username: 'dj_test',
      displayName: artistName,
      avatarUrl: 'https://example.com/avatar.png',
      tier: 'pro',
    ),
    durationSeconds: durationSeconds,
    waveformUrl: waveformUrl,
    coverUrl: coverUrl,
    contentWarning: false,
    engagement: TrackEngagement(
      likeCount: 10,
      commentCount: 4,
      repostCount: 2,
      isLiked: isLiked,
      isReposted: false,
      isSaved: false,
    ),
    playability: PlayabilityInfo(
      status: status,
      regionBlocked: blockedReason == BlockedReason.regionRestricted,
      tierBlocked: blockedReason == BlockedReason.tierRestricted,
      requiresSubscription: blockedReason == BlockedReason.tierRestricted,
      blockedReason: blockedReason,
    ),
    preview: PreviewInfo(
      enabled: previewEnabled,
      previewDurationSeconds: previewDurationSeconds,
      previewStartSeconds: previewStartSeconds,
    ),
    scheduledReleaseDate: scheduledReleaseDate,
  );
}

StreamUrl sampleStreamUrl({
  String trackId = 'track-1',
  String url = 'https://example.com/stream.m3u8',
  int expiresInSeconds = 600,
  String format = 'hls',
}) {
  return StreamUrl(
    trackId: trackId,
    url: url,
    expiresInSeconds: expiresInSeconds,
    format: format,
  );
}

PlaybackQueue sampleQueue({
  List<String>? trackIds,
  int currentIndex = 0,
  bool shuffle = false,
  RepeatMode repeat = RepeatMode.none,
}) {
  return PlaybackQueue(
    trackIds: trackIds ?? const <String>['track-1', 'track-2', 'track-3'],
    currentIndex: currentIndex,
    shuffle: shuffle,
    repeat: repeat,
  );
}

HistoryTrack sampleHistoryTrack({
  String trackId = 'track-1',
  String title = 'Night Drive',
  String artistName = 'DJ Test',
  DateTime? playedAt,
  int durationSeconds = 180,
  PlaybackStatus status = PlaybackStatus.playable,
  String? coverUrl,
}) {
  return HistoryTrack(
    trackId: trackId,
    title: title,
    artist: TrackArtistSummary(id: 'artist-1', name: artistName),
    playedAt: playedAt ?? DateTime.utc(2026, 4, 4, 20),
    durationSeconds: durationSeconds,
    status: status,
    coverUrl: coverUrl,
    genre: 'Electronic',
    releaseDate: DateTime.utc(2026, 3, 1),
    likeCount: 8,
    commentCount: 3,
    repostCount: 1,
    playCount: 50,
  );
}

PlayerState samplePlayerState({
  TrackPlaybackBundle? bundle,
  StreamUrl? streamUrl,
  PlaybackQueue? queue,
  bool isPlaying = false,
  double positionSeconds = 0,
  bool isMuted = false,
  double volume = 1.0,
  bool isBuffering = false,
  DateTime? streamExpiresAt,
  String? localFilePath,
  double? mediaDurationSeconds,
}) {
  final resolvedBundle = bundle ?? sampleBundle();
  return PlayerState(
    bundle: resolvedBundle,
    streamUrl: streamUrl,
    queue: queue,
    isPlaying: isPlaying,
    positionSeconds: positionSeconds,
    isMuted: isMuted,
    volume: volume,
    isBuffering: isBuffering,
    streamExpiresAt: streamExpiresAt,
    localFilePath: localFilePath,
    mediaDurationSeconds: mediaDurationSeconds,
  );
}

UploadItem sampleUploadItem({
  String id = 'track-1',
  String title = 'Night Drive',
  String artistDisplay = 'DJ Test',
  int durationSeconds = 180,
  String? artworkUrl,
  String? audioUrl,
  String? waveformUrl,
  String? localFilePath,
}) {
  return UploadItem(
    id: id,
    title: title,
    artistDisplay: artistDisplay,
    durationLabel:
        '${durationSeconds ~/ 60}:${(durationSeconds % 60).toString().padLeft(2, '0')}',
    durationSeconds: durationSeconds,
    audioUrl: audioUrl,
    waveformUrl: waveformUrl,
    artworkUrl: artworkUrl,
    localFilePath: localFilePath,
    visibility: UploadVisibility.public,
    status: UploadProcessingStatus.finished,
    isExplicit: false,
    createdAt: DateTime.utc(2026, 4, 4, 20),
  );
}

Map<String, dynamic> sampleBundleJson({
  String trackId = 'track-1',
  String status = 'playable',
  String? blockedReason,
  bool previewEnabled = false,
  String coverUrl = '',
  String waveformUrl = '',
  String? scheduledReleaseDate,
}) {
  return <String, dynamic>{
    'trackId': trackId,
    'title': 'Night Drive',
    'artist': <String, dynamic>{
      'id': 'artist-1',
      'displayName': 'DJ Test',
      'username': 'dj_test',
      'avatarUrl': 'https://example.com/avatar.png',
      'tier': 'pro',
    },
    'durationSeconds': 180,
    'waveformUrl': waveformUrl,
    'coverUrl': coverUrl,
    'contentWarning': false,
    'engagement': <String, dynamic>{
      'likeCount': 10,
      'commentCount': 4,
      'repostCount': 2,
      'isLiked': false,
      'isReposted': false,
      'isSaved': false,
    },
    'playability': <String, dynamic>{
      'status': status,
      'regionBlocked': blockedReason == 'region_restricted',
      'tierBlocked': blockedReason == 'tier_restricted',
      'requiresSubscription': blockedReason == 'tier_restricted',
      'blockedReason': blockedReason,
    },
    'preview': <String, dynamic>{
      'enabled': previewEnabled,
      'previewDurationSeconds': 30,
      'previewStartSeconds': 5,
    },
    'scheduledReleaseDate': scheduledReleaseDate,
  };
}

Map<String, dynamic> sampleHistoryJson({
  String trackId = 'track-1',
  String status = 'playable',
}) {
  return <String, dynamic>{
    'trackId': trackId,
    'title': 'Night Drive',
    'artist': <String, dynamic>{
      'id': 'artist-1',
      'displayName': 'DJ Test',
      'username': 'dj_test',
      'avatarUrl': 'https://example.com/avatar.png',
      'tier': 'pro',
    },
    'playedAt': DateTime.utc(2026, 4, 4, 20).toIso8601String(),
    'durationSeconds': 180,
    'status': status,
    'coverUrl': 'https://example.com/cover.png',
    'genre': 'Electronic',
    'releaseDate': DateTime.utc(2026, 3, 1).toIso8601String(),
    'engagement': <String, dynamic>{
      'likeCount': 8,
      'commentCount': 3,
      'repostCount': 1,
      'playCount': 50,
    },
  };
}

Map<String, dynamic> sampleStreamResponseJson({
  String trackId = 'track-1',
  String url = 'https://example.com/stream.m3u8',
  int expiresInSeconds = 600,
  String format = 'hls',
}) {
  return <String, dynamic>{
    'trackId': trackId,
    'stream': <String, dynamic>{
      'url': url,
      'expiresInSeconds': expiresInSeconds,
      'format': format,
    },
  };
}

Map<String, dynamic> sampleQueueJson({
  List<dynamic>? queue,
  int currentIndex = 0,
  bool shuffle = false,
  String repeat = 'none',
}) {
  return <String, dynamic>{
    'queue': queue ??
        const <Map<String, dynamic>>[
          <String, dynamic>{'trackId': 'track-1'},
          <String, dynamic>{'trackId': 'track-2'},
        ],
    'currentIndex': currentIndex,
    'shuffle': shuffle,
    'repeat': repeat,
  };
}

Map<String, dynamic> encodePlayerSession({
  TrackPlaybackBundle? bundle,
  StreamUrl? streamUrl,
  PlaybackQueue? queue,
  double positionSeconds = 0,
  bool isMuted = false,
  double volume = 1.0,
  DateTime? streamExpiresAt,
  String? localFilePath,
  double? mediaDurationSeconds,
}) {
  final resolvedBundle = bundle ?? sampleBundle();
  final playerState = samplePlayerState(
    bundle: resolvedBundle,
    streamUrl: streamUrl,
    queue: queue,
    positionSeconds: positionSeconds,
    isMuted: isMuted,
    volume: volume,
    streamExpiresAt: streamExpiresAt,
    localFilePath: localFilePath,
    mediaDurationSeconds: mediaDurationSeconds,
  );

  return <String, dynamic>{
    'bundle': sampleBundleJson(
      trackId: playerState.bundle!.trackId,
      status: playerState.bundle!.playability.status.name,
      blockedReason:
          _blockedReasonToRaw(playerState.bundle!.playability.blockedReason),
      previewEnabled: playerState.bundle!.preview.enabled,
      coverUrl: playerState.bundle!.coverUrl,
      waveformUrl: playerState.bundle!.waveformUrl,
      scheduledReleaseDate:
          playerState.bundle!.scheduledReleaseDate?.toIso8601String(),
    ),
    'streamUrl': playerState.streamUrl == null
        ? null
        : <String, dynamic>{
            'trackId': playerState.streamUrl!.trackId,
            'url': playerState.streamUrl!.url,
            'expiresInSeconds': playerState.streamUrl!.expiresInSeconds,
            'format': playerState.streamUrl!.format,
          },
    'queue': playerState.queue == null
        ? null
        : <String, dynamic>{
            'trackIds': playerState.queue!.trackIds,
            'currentIndex': playerState.queue!.currentIndex,
            'shuffle': playerState.queue!.shuffle,
            'repeat': playerState.queue!.repeat.name,
          },
    'positionSeconds': playerState.positionSeconds,
    'isMuted': playerState.isMuted,
    'volume': playerState.volume,
    'streamExpiresAt': playerState.streamExpiresAt?.toIso8601String(),
    'localFilePath': playerState.localFilePath,
    'mediaDurationSeconds': playerState.mediaDurationSeconds,
  };
}

String _blockedReasonToRaw(BlockedReason? blockedReason) {
  switch (blockedReason) {
    case BlockedReason.regionRestricted:
      return 'region_restricted';
    case BlockedReason.tierRestricted:
      return 'tier_restricted';
    case BlockedReason.scheduledRelease:
      return 'scheduled_release';
    case BlockedReason.deleted:
      return 'deleted';
    case BlockedReason.privateNoToken:
      return 'private_no_token';
    case BlockedReason.copyright:
      return 'copyright';
    case BlockedReason.processing:
      return 'processing';
    case BlockedReason.processingFailed:
      return 'processing_failed';
    case null:
      return '';
  }
}

String encodeJson(Map<String, dynamic> value) => jsonEncode(value);
