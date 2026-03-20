import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/data/repository/auth_repository_impl.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthApi mockApi;
  late MockTokenStorage mockStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockApi = MockAuthApi();
    mockStorage = MockTokenStorage();
    repository = AuthRepositoryImpl(mockApi, mockStorage);
  });

  Response<dynamic> makeOk(Map<String, dynamic> data) => Response(
    data: data,
    requestOptions: RequestOptions(path: '/test'),
    statusCode: 200,
  );

  DioException makeDioError(int statusCode, String path) => DioException(
    requestOptions: RequestOptions(path: path),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: path),
      statusCode: statusCode,
    ),
  );

  Map<String, dynamic> makeAuthJson({
    String userId = '1',
    String email = 'user@example.com',
    String username = 'testuser',
    String role = 'LISTENER',
    bool isVerified = true,
  }) => {
    'accessToken': 'access-abc',
    'refreshToken': 'refresh-xyz',
    'user': {
      'id': userId,
      'email': email,
      'username': username,
      'role': role,
      'isVerified': isVerified,
    },
  };

  // ── checkEmail ───────────────────────────────────────────────────────────────

  group('checkEmail', () {
    test('returns true when email is registered', () async {
      when(
        mockApi.checkEmail(any),
      ).thenAnswer((_) async => makeOk({'exists': true}));
      expect(await repository.checkEmail('existing@example.com'), isTrue);
    });

    test('returns false when email is available', () async {
      when(
        mockApi.checkEmail(any),
      ).thenAnswer((_) async => makeOk({'exists': false}));
      expect(await repository.checkEmail('new@example.com'), isFalse);
    });

    test('throws NetworkFailure on connection timeout', () {
      when(mockApi.checkEmail(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/check-email'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(
        () => repository.checkEmail('user@example.com'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  // ── login ────────────────────────────────────────────────────────────────────

  group('login', () {
    test('returns AuthUserEntity and saves session on success', () async {
      when(mockApi.login(any)).thenAnswer((_) async => makeOk(makeAuthJson()));
      // FIX: repository now calls saveSession, not saveTokens
      when(
        mockStorage.saveSession(
          accessToken: anyNamed('accessToken'),
          refreshToken: anyNamed('refreshToken'),
          user: anyNamed('user'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.login('user@example.com', 'Secret1!');

      expect(result.email, equals('user@example.com'));
      expect(result.isVerified, isTrue);
      verify(
        mockStorage.saveSession(
          accessToken: 'access-abc',
          refreshToken: 'refresh-xyz',
          user: anyNamed('user'),
        ),
      ).called(1);
    });

    test('throws UnverifiedUserFailure when isVerified=false', () {
      when(
        mockApi.login(any),
      ).thenAnswer((_) async => makeOk(makeAuthJson(isVerified: false)));
      expect(
        () => repository.login('user@example.com', 'Secret1!'),
        throwsA(isA<UnverifiedUserFailure>()),
      );
    });

    test('throws UnauthorizedFailure on 401', () {
      when(mockApi.login(any)).thenThrow(makeDioError(401, '/auth/login'));
      expect(
        () => repository.login('user@example.com', 'wrong'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('throws ConflictFailure on 409', () {
      when(mockApi.login(any)).thenThrow(makeDioError(409, '/auth/login'));
      expect(
        () => repository.login('user@example.com', 'pass'),
        throwsA(isA<ConflictFailure>()),
      );
    });

    test('throws UnknownFailure on unexpected exception', () {
      when(mockApi.login(any)).thenThrow(Exception('unexpected'));
      expect(
        () => repository.login('user@example.com', 'pass'),
        throwsA(isA<UnknownFailure>()),
      );
    });
  });

  // ── register ─────────────────────────────────────────────────────────────────

  group('register', () {
    test('completes without error on success', () async {
      when(
        mockApi.register(any),
      ).thenAnswer((_) async => makeOk({'message': 'User created'}));
      await expectLater(
        repository.register(
          email: 'new@example.com',
          username: 'newuser',
          password: 'Secret1!',
          gender: 'MALE',
          dateOfBirth: '2000-01-01',
        ),
        completes,
      );
    });

    test('throws ConflictFailure on 409', () {
      when(
        mockApi.register(any),
      ).thenThrow(makeDioError(409, '/auth/register'));
      expect(
        () => repository.register(
          email: 'dup@example.com',
          username: 'user',
          password: 'Secret1!',
          gender: 'MALE',
          dateOfBirth: '2000-01-01',
        ),
        throwsA(isA<ConflictFailure>()),
      );
    });

    test('throws ValidationFailure on 400', () {
      when(
        mockApi.register(any),
      ).thenThrow(makeDioError(400, '/auth/register'));
      expect(
        () => repository.register(
          email: 'bad',
          username: 'user',
          password: 'Secret1!',
          gender: 'MALE',
          dateOfBirth: '2000-01-01',
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  // ── verifyEmail ──────────────────────────────────────────────────────────────

  group('verifyEmail', () {
    test('returns AuthUserEntity and saves session on success', () async {
      when(
        mockApi.verifyEmail(any),
      ).thenAnswer((_) async => makeOk(makeAuthJson()));
      // FIX: repository now calls saveSession, not saveTokens
      when(
        mockStorage.saveSession(
          accessToken: anyNamed('accessToken'),
          refreshToken: anyNamed('refreshToken'),
          user: anyNamed('user'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.verifyEmail('user@example.com', 'ABC123');

      expect(result.email, equals('user@example.com'));
      verify(
        mockStorage.saveSession(
          accessToken: 'access-abc',
          refreshToken: 'refresh-xyz',
          user: anyNamed('user'),
        ),
      ).called(1);
    });

    test('throws UnauthorizedFailure on invalid token', () {
      when(
        mockApi.verifyEmail(any),
      ).thenThrow(makeDioError(401, '/auth/verify-email'));
      expect(
        () => repository.verifyEmail('user@example.com', 'WRONG1'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });
  });

  // ── signOut ──────────────────────────────────────────────────────────────────

  group('signOut', () {
    test('calls clearSession on success', () async {
      when(
        mockStorage.getRefreshToken(),
      ).thenAnswer((_) async => 'refresh-xyz');
      when(
        mockApi.signOut(any),
      ).thenAnswer((_) async => makeOk({'message': 'OK'}));
      // FIX: repository now calls clearSession, not clearTokens
      when(mockStorage.clearSession()).thenAnswer((_) async {});

      await repository.signOut();

      verify(mockStorage.clearSession()).called(1);
    });
  });

  // ── signOutAll ───────────────────────────────────────────────────────────────

  group('signOutAll', () {
    test('calls clearSession after signing out all devices', () async {
      when(
        mockStorage.getRefreshToken(),
      ).thenAnswer((_) async => 'refresh-xyz');
      when(
        mockApi.signOutAll(any),
      ).thenAnswer((_) async => makeOk({'message': 'OK'}));
      // FIX: repository now calls clearSession, not clearTokens
      when(mockStorage.clearSession()).thenAnswer((_) async {});

      await repository.signOutAll();

      verify(mockStorage.clearSession()).called(1);
    });
  });

  // ── forgotPassword ───────────────────────────────────────────────────────────

  group('forgotPassword', () {
    test('completes without error', () async {
      when(
        mockApi.forgotPassword(any),
      ).thenAnswer((_) async => makeOk({'message': 'Email sent'}));
      await expectLater(
        repository.forgotPassword('user@example.com'),
        completes,
      );
    });
  });

  // ── resetPassword ────────────────────────────────────────────────────────────

  group('resetPassword', () {
    test('completes without error on valid token', () async {
      when(
        mockApi.resetPassword(
          email: anyNamed('email'),
          token: anyNamed('token'),
          newPassword: anyNamed('newPassword'),
          confirmPassword: anyNamed('confirmPassword'),
          signoutAll: anyNamed('signoutAll'),
        ),
      ).thenAnswer((_) async => makeOk({'message': 'Password reset'}));
      // signoutAll=true by default, so clearSession is called
      when(mockStorage.clearSession()).thenAnswer((_) async {});

      await expectLater(
        repository.resetPassword(
          email: 'user@example.com',
          token: 'ABC123',
          newPassword: 'NewSecret1!',
          confirmPassword: 'NewSecret1!',
        ),
        completes,
      );
    });

    test('throws UnauthorizedFailure on expired token', () {
      when(
        mockApi.resetPassword(
          email: anyNamed('email'),
          token: anyNamed('token'),
          newPassword: anyNamed('newPassword'),
          confirmPassword: anyNamed('confirmPassword'),
          signoutAll: anyNamed('signoutAll'),
        ),
      ).thenThrow(makeDioError(401, '/auth/reset-password'));

      expect(
        () => repository.resetPassword(
          email: 'user@example.com',
          token: 'EXPIRE',
          newPassword: 'NewSecret1!',
          confirmPassword: 'NewSecret1!',
        ),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });
  });

  // ── deleteAccount ────────────────────────────────────────────────────────────

  group('deleteAccount', () {
    test('completes and clears session on success', () async {
      when(
        mockApi.deleteAccount(password: anyNamed('password')),
      ).thenAnswer((_) async => makeOk({'message': 'Deleted'}));
      // FIX: repository now calls clearSession, not clearTokens
      when(mockStorage.clearSession()).thenAnswer((_) async {});

      await expectLater(
        repository.deleteAccount(password: 'Secret1!'),
        completes,
      );
      verify(mockStorage.clearSession()).called(1);
    });

    test('throws UnauthorizedFailure for wrong password', () {
      when(
        mockApi.deleteAccount(password: anyNamed('password')),
      ).thenThrow(makeDioError(401, '/auth/delete-account'));
      expect(
        () => repository.deleteAccount(password: 'wrong'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('throws ForbiddenFailure for banned account', () {
      when(
        mockApi.deleteAccount(password: anyNamed('password')),
      ).thenThrow(makeDioError(403, '/auth/delete-account'));
      expect(
        () => repository.deleteAccount(),
        throwsA(isA<ForbiddenFailure>()),
      );
    });
  });
}
