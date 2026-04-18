import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as just_audio;

import '../../../playback_streaming_engine/domain/usecases/request_stream_url_usecase.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../../playback_streaming_engine/presentation/providers/player_repository_provider.dart';

final feedPreviewPlaybackControllerProvider =
    Provider<FeedPreviewPlaybackController>((ref) {
  final controller = FeedPreviewPlaybackController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

/// Owns an isolated [just_audio.AudioPlayer] used ONLY for the feed card
/// "Tap to Preview" experience. Kept separate from the main playerProvider
/// so previews never mutate the real playback state / mini-player / history.
class FeedPreviewPlaybackController {
  FeedPreviewPlaybackController(this._ref);

  final Ref _ref;
  final just_audio.AudioPlayer _audio = just_audio.AudioPlayer();

  Timer? _stopTimer;
  int _requestId = 0;
  bool _disposed = false;

  static const Duration _previewLength = Duration(seconds: 30);

  Future<void> start(String trackId, int durationSeconds) async {
    if (_disposed) return;
    final requestId = ++_requestId;

    await _stopInternal();

    // The main player and the preview share the device's audio output.
    // Pause the main player first so the two streams don't overlap.
    try {
      final current = _ref.read(playerProvider).asData?.value;
      if (current?.isPlaying == true) {
        await _ref.read(playerProvider.notifier).pause();
      }
    } catch (_) {}

    try {
      final repository = _ref.read(playerRepositoryProvider);
      final streamUrl = await RequestStreamUrlUsecase(repository).call(trackId);
      if (_disposed || requestId != _requestId) return;

      await _audio.setAudioSource(
        just_audio.AudioSource.uri(Uri.parse(streamUrl.url)),
        preload: true,
      );
      if (_disposed || requestId != _requestId) return;

      final offset = _middleOffsetSeconds(durationSeconds);
      if (offset > 0) {
        await _audio.seek(Duration(seconds: offset));
      }
      if (_disposed || requestId != _requestId) return;

      await _audio.play();

      _stopTimer = Timer(_previewLength, () {
        unawaited(stop());
      });
    } catch (_) {
      // Swallow — preview is best-effort; the UI overlay already flipped.
    }
  }

  Future<void> stop() async {
    if (_disposed) return;
    _requestId++;
    await _stopInternal();
  }

  Future<void> _stopInternal() async {
    _stopTimer?.cancel();
    _stopTimer = null;
    try {
      await _audio.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _stopTimer?.cancel();
    _stopTimer = null;
    try {
      await _audio.dispose();
    } catch (_) {}
  }

  // Centre a 30s window on the midpoint when the track is long enough,
  // clamped so we never seek past (duration - 30s). Tracks ≤ 30s play
  // from the start — there is no "middle" to pick from.
  int _middleOffsetSeconds(int durationSeconds) {
    if (durationSeconds <= 30) return 0;
    final middle = durationSeconds ~/ 2;
    final start = middle - 15;
    final maxStart = durationSeconds - 30;
    if (start < 0) return 0;
    if (start > maxStart) return maxStart;
    return start;
  }
}
