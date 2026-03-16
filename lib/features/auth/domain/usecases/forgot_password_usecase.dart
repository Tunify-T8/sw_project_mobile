import '../repositories/auth_repository.dart';

/// Requests a password reset email for [email].
class ForgotPasswordUseCase {
  final AuthRepository _repository;
  const ForgotPasswordUseCase(this._repository);
  Future<void> call(String email) => _repository.forgotPassword(email);
}
