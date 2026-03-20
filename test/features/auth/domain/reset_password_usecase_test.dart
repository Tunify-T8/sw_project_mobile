import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/domain/usecases/reset_password_usecase.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late ResetPasswordUseCase useCase;

  const tEmail = 'user@example.com';
  const tToken = 'ABC123';
  const tPassword = 'NewSecret1!';

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ResetPasswordUseCase(mockRepository);
  });

  test('completes when token and password are valid', () async {
    when(
      mockRepository.resetPassword(
        email: tEmail,
        token: tToken,
        newPassword: tPassword,
        confirmPassword: tPassword,
        signoutAll: true,
      ),
    ).thenAnswer((_) async {});

    await expectLater(
      useCase(
        email: tEmail,
        token: tToken,
        newPassword: tPassword,
        confirmPassword: tPassword,
      ),
      completes,
    );
    verify(
      mockRepository.resetPassword(
        email: tEmail,
        token: tToken,
        newPassword: tPassword,
        confirmPassword: tPassword,
        signoutAll: true,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('propagates UnauthorizedFailure for expired token', () {
    when(
      mockRepository.resetPassword(
        email: anyNamed('email'),
        token: anyNamed('token'),
        newPassword: anyNamed('newPassword'),
        confirmPassword: anyNamed('confirmPassword'),
        signoutAll: anyNamed('signoutAll'),
      ),
    ).thenThrow(const UnauthorizedFailure());

    expect(
      () => useCase(
        email: tEmail,
        token: 'EXPIRE',
        newPassword: tPassword,
        confirmPassword: tPassword,
      ),
      throwsA(isA<UnauthorizedFailure>()),
    );
  });

  test('passes signoutAll=false when explicitly set', () async {
    when(
      mockRepository.resetPassword(
        email: tEmail,
        token: tToken,
        newPassword: tPassword,
        confirmPassword: tPassword,
        signoutAll: false,
      ),
    ).thenAnswer((_) async {});

    await useCase(
      email: tEmail,
      token: tToken,
      newPassword: tPassword,
      confirmPassword: tPassword,
      signoutAll: false,
    );

    verify(
      mockRepository.resetPassword(
        email: tEmail,
        token: tToken,
        newPassword: tPassword,
        confirmPassword: tPassword,
        signoutAll: false,
      ),
    ).called(1);
  });
}
