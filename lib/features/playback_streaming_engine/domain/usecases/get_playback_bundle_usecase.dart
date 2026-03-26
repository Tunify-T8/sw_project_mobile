import '../entities/track_playback_bundle.dart';
import '../repositories/player_repository.dart';

class GetPlaybackBundleUsecase {
  const GetPlaybackBundleUsecase(this._repository);

  final PlayerRepository _repository;

  Future<TrackPlaybackBundle> call(
    String trackId, {
    String? privateToken,
  }) {
    return _repository.getPlaybackBundle(
      trackId,
      privateToken: privateToken,
    );
  }
}
