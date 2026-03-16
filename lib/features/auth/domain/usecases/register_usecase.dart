import '../repositories/auth_repository.dart';

/// Registers a new user account.
///
/// Does not return tokens — email verification is required next.
class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<void> call({
    required String email,
    required String username,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) => _repository.register(
    email: email,
    username: username,
    password: password,
    gender: gender,
    dateOfBirth: dateOfBirth,
  );
}
