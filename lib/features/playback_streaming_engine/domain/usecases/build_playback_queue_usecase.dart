import '../entities/playback_context_request.dart';
import '../entities/playback_queue.dart';
import '../repositories/player_repository.dart';

class BuildPlaybackQueueUsecase {
  const BuildPlaybackQueueUsecase(this._repository);

  final PlayerRepository _repository;

  Future<PlaybackQueue> call(PlaybackContextRequest request) {
    return _repository.buildPlaybackQueue(request);
  }
}
