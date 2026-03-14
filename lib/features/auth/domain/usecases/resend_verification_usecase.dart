import '../repositories/auth_repository.dart';

/// Resends the verification email to the given address.
class ResendVerificationUseCase {
  final AuthRepository _repository;
  const ResendVerificationUseCase(this._repository);
  Future<void> call(String email) => _repository.resendVerification(email);
}
