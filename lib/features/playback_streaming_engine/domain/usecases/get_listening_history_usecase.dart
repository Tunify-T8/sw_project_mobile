import '../entities/history_track.dart';
import '../repositories/player_repository.dart';

class GetListeningHistoryUsecase {
  const GetListeningHistoryUsecase(this._repository);

  final PlayerRepository _repository;

  Future<List<HistoryTrack>> call({int page = 1, int limit = 20}) {
    return _repository.getListeningHistory(page: page, limit: limit);
  }
}
