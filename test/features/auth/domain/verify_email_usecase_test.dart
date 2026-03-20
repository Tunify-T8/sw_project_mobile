import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/domain/usecases/verify_email_usecase.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late VerifyEmailUseCase useCase;

  const tEmail = 'user@example.com';
  const tToken = 'ABC123';
  const tUser = AuthUserEntity(
    id: '1',
    email: tEmail,
    username: 'testuser',
    role: 'LISTENER',
    isVerified: true,
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = VerifyEmailUseCase(mockRepository);
  });

  test('returns AuthUserEntity on valid token', () async {
    when(
      mockRepository.verifyEmail(tEmail, tToken),
    ).thenAnswer((_) async => tUser);

    final result = await useCase(tEmail, tToken);

    expect(result, equals(tUser));
    verify(mockRepository.verifyEmail(tEmail, tToken)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('propagates UnauthorizedFailure for invalid token', () {
    when(
      mockRepository.verifyEmail(tEmail, 'WRONG1'),
    ).thenThrow(const UnauthorizedFailure());

    expect(
      () => useCase(tEmail, 'WRONG1'),
      throwsA(isA<UnauthorizedFailure>()),
    );
  });
}
