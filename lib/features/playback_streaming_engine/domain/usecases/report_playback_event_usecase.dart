import '../entities/playback_event.dart';
import '../repositories/player_repository.dart';

class ReportPlaybackEventUsecase {
  const ReportPlaybackEventUsecase(this._repository);

  final PlayerRepository _repository;

  Future<void> call(PlaybackEvent event) {
    return _repository.reportPlaybackEvent(event);
  }
}
