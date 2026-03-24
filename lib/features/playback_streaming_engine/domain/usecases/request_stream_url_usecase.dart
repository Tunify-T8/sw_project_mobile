import '../entities/stream_url.dart';
import '../repositories/player_repository.dart';

class RequestStreamUrlUsecase {
  const RequestStreamUrlUsecase(this._repository);

  final PlayerRepository _repository;

  Future<StreamUrl> call(String trackId, {String quality = 'auto'}) {
    return _repository.requestStreamUrl(trackId, quality: quality);
  }
}
