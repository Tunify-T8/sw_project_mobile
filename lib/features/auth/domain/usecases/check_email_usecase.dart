import '../repositories/auth_repository.dart';

/// Returns true if [email] is already registered, false if available.
class CheckEmailUseCase {
  final AuthRepository _repository;
  const CheckEmailUseCase(this._repository);
  Future<bool> call(String email) => _repository.checkEmail(email);
}
