import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/domain/usecases/register_usecase.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late RegisterUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  test('completes without error on success', () async {
    when(
      mockRepository.register(
        email: anyNamed('email'),
        username: anyNamed('username'),
        password: anyNamed('password'),
        gender: anyNamed('gender'),
        dateOfBirth: anyNamed('dateOfBirth'),
      ),
    ).thenAnswer((_) async {});

    await expectLater(
      useCase(
        email: 'new@example.com',
        username: 'newuser',
        password: 'Secret1!',
        gender: 'MALE',
        dateOfBirth: '2000-01-01',
      ),
      completes,
    );
    verify(
      mockRepository.register(
        email: 'new@example.com',
        username: 'newuser',
        password: 'Secret1!',
        gender: 'MALE',
        dateOfBirth: '2000-01-01',
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('propagates ConflictFailure for duplicate email', () {
    when(
      mockRepository.register(
        email: anyNamed('email'),
        username: anyNamed('username'),
        password: anyNamed('password'),
        gender: anyNamed('gender'),
        dateOfBirth: anyNamed('dateOfBirth'),
      ),
    ).thenThrow(const ConflictFailure('Email already in use.'));

    expect(
      () => useCase(
        email: 'dup@example.com',
        username: 'user',
        password: 'Secret1!',
        gender: 'MALE',
        dateOfBirth: '2000-01-01',
      ),
      throwsA(isA<ConflictFailure>()),
    );
  });

  test('propagates ConflictFailure for duplicate username', () {
    when(
      mockRepository.register(
        email: anyNamed('email'),
        username: anyNamed('username'),
        password: anyNamed('password'),
        gender: anyNamed('gender'),
        dateOfBirth: anyNamed('dateOfBirth'),
      ),
    ).thenThrow(const ConflictFailure('Username already taken.'));

    expect(
      () => useCase(
        email: 'new@example.com',
        username: 'taken',
        password: 'Secret1!',
        gender: 'MALE',
        dateOfBirth: '2000-01-01',
      ),
      throwsA(isA<ConflictFailure>()),
    );
  });
}
