import '../repositories/auth_repository.dart';

/// Signs out all devices for the current user.
class LogoutAllUseCase {
  final AuthRepository _repository;
  const LogoutAllUseCase(this._repository);
  Future<void> call() => _repository.signOutAll();
}
