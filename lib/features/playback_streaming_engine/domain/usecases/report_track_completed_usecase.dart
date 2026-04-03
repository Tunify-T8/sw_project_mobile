import '../repositories/player_repository.dart';

/// Notifies the backend that the user reached 90 % of a track naturally.
/// Maps to `POST /tracks/{trackId}/played`.
class ReportTrackCompletedUsecase {
  const ReportTrackCompletedUsecase(this._repository);

  final PlayerRepository _repository;

  Future<void> call(String trackId) => _repository.reportTrackCompleted(trackId);
}
