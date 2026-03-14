import '../repositories/auth_repository.dart';

/// Soft-deletes the authenticated user's account.
class DeleteAccountUseCase {
  final AuthRepository _repository;
  const DeleteAccountUseCase(this._repository);
  Future<void> call({String? password}) =>
      _repository.deleteAccount(password: password);
}
