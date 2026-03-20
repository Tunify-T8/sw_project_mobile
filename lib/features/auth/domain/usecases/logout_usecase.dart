import '../repositories/auth_repository.dart';

/// Signs out the current device.
class LogoutUseCase {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);
  Future<void> call() => _repository.signOut();
}
