import '../repositories/auth_repository.dart';

/// Resets the user's password using the token from the reset email.
class ResetPasswordUseCase {
  final AuthRepository _repository;
  const ResetPasswordUseCase(this._repository);

  Future<void> call({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
    bool signoutAll = true,
  }) => _repository.resetPassword(
    email: email,
    token: token,
    newPassword: newPassword,
    confirmPassword: confirmPassword,
    signoutAll: signoutAll,
  );
}
