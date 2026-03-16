import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/domain/usecases/delete_account_usecase.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late DeleteAccountUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = DeleteAccountUseCase(mockRepository);
  });

  test('completes when password is correct', () async {
    when(
      mockRepository.deleteAccount(password: 'Secret1!'),
    ).thenAnswer((_) async {});

    await expectLater(useCase(password: 'Secret1!'), completes);
    verify(mockRepository.deleteAccount(password: 'Secret1!')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('completes without password for OAuth accounts', () async {
    when(mockRepository.deleteAccount(password: null)).thenAnswer((_) async {});

    await expectLater(useCase(), completes);
    verify(mockRepository.deleteAccount(password: null)).called(1);
  });

  test('propagates UnauthorizedFailure for wrong password', () {
    when(
      mockRepository.deleteAccount(password: 'wrong'),
    ).thenThrow(const UnauthorizedFailure());

    expect(
      () => useCase(password: 'wrong'),
      throwsA(isA<UnauthorizedFailure>()),
    );
  });

  test('propagates ForbiddenFailure for banned account', () {
    when(
      mockRepository.deleteAccount(password: anyNamed('password')),
    ).thenThrow(const ForbiddenFailure('Account is banned.'));

    expect(
      () => useCase(password: 'Secret1!'),
      throwsA(isA<ForbiddenFailure>()),
    );
  });
}
