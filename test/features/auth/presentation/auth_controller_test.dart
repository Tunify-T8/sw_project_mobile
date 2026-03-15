import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockCheckEmailUseCase mockCheckEmail;
  late MockRegisterUseCase mockRegister;
  late MockVerifyEmailUseCase mockVerifyEmail;
  late MockResendVerificationUseCase mockResend;
  late MockLoginUseCase mockLogin;
  late MockLogoutUseCase mockLogout;
  late MockLogoutAllUseCase mockLogoutAll;
  late MockForgotPasswordUseCase mockForgotPassword;
  late MockResetPasswordUseCase mockResetPassword;
  late MockDeleteAccountUseCase mockDeleteAccount;
  late MockGoogleSignInService mockGoogle;
  late AuthController controller;

  const tUser = AuthUserEntity(
    id: '1',
    email: 'user@example.com',
    username: 'testuser',
    role: 'LISTENER',
    isVerified: true,
  );

  /// Builds a fresh [AuthController] with all mocks injected.
  ///
  /// Because [MockAuthConfig.useMock] is a compile-time constant we cannot
  /// flip it in tests. The controller is therefore constructed directly
  /// (bypassing the provider tree) so the injected use cases are always
  /// reached regardless of the mock config flag.
  AuthController _build() => AuthController(
    checkEmail: mockCheckEmail,
    register: mockRegister,
    verifyEmail: mockVerifyEmail,
    resendVerification: mockResend,
    login: mockLogin,
    logout: mockLogout,
    logoutAll: mockLogoutAll,
    forgotPassword: mockForgotPassword,
    resetPassword: mockResetPassword,
    deleteAccount: mockDeleteAccount,
    googleSignInService: mockGoogle,
  );

  setUp(() {
    mockCheckEmail = MockCheckEmailUseCase();
    mockRegister = MockRegisterUseCase();
    mockVerifyEmail = MockVerifyEmailUseCase();
    mockResend = MockResendVerificationUseCase();
    mockLogin = MockLoginUseCase();
    mockLogout = MockLogoutUseCase();
    mockLogoutAll = MockLogoutAllUseCase();
    mockForgotPassword = MockForgotPasswordUseCase();
    mockResetPassword = MockResetPasswordUseCase();
    mockDeleteAccount = MockDeleteAccountUseCase();
    mockGoogle = MockGoogleSignInService();
    controller = _build();
  });

  // ── Initial state ──────────────────────────────────────────────────────────

  test('initial state is AsyncData(null)', () {
    expect(
      controller.state,
      equals(const AsyncValue<AuthUserEntity?>.data(null)),
    );
  });

  // ── checkEmail ─────────────────────────────────────────────────────────────

  group('checkEmail', () {
    test('returns true when email exists', () async {
      when(
        mockCheckEmail('existing@example.com'),
      ).thenAnswer((_) async => true);

      final result = await controller.checkEmail('existing@example.com');

      expect(result, isTrue);
    });

    test('returns false when email is new', () async {
      when(mockCheckEmail('new@example.com')).thenAnswer((_) async => false);

      final result = await controller.checkEmail('new@example.com');

      expect(result, isFalse);
    });

    test('sets state to error and returns false on failure', () async {
      when(mockCheckEmail(any)).thenThrow(const NetworkFailure());

      final result = await controller.checkEmail('user@example.com');

      expect(result, isFalse);
      expect(controller.state, isA<AsyncError>());
    });
  });

  // ── login ──────────────────────────────────────────────────────────────────

  group('login', () {
    test('transitions loading → data(user) on success', () async {
      final states = <AsyncValue<AuthUserEntity?>>[];
      controller.addListener((s) => states.add(s), fireImmediately: false);

      when(
        mockLogin('user@example.com', 'Secret1!'),
      ).thenAnswer((_) async => tUser);

      await controller.login('user@example.com', 'Secret1!');

      expect(states.first, isA<AsyncLoading>());
      expect(
        states.last,
        equals(const AsyncValue<AuthUserEntity?>.data(tUser)),
      );
    });

    test(
      'sets state to error(UnauthorizedFailure) on wrong password',
      () async {
        when(mockLogin(any, any)).thenThrow(const UnauthorizedFailure());

        await controller.login('user@example.com', 'wrong');

        expect(
          (controller.state as AsyncError).error,
          isA<UnauthorizedFailure>(),
        );
      },
    );

    test(
      'sets state to error(UnverifiedUserFailure) when unverified',
      () async {
        when(mockLogin(any, any)).thenThrow(const UnverifiedUserFailure());

        await controller.login('user@example.com', 'Secret1!');

        expect(
          (controller.state as AsyncError).error,
          isA<UnverifiedUserFailure>(),
        );
      },
    );
  });

  // ── register ──────────────────────────────────────────────────────────────

  group('register', () {
    test(
      'sets state to data(null) on success (no tokens before verification)',
      () async {
        when(
          mockRegister(
            email: anyNamed('email'),
            username: anyNamed('username'),
            password: anyNamed('password'),
            gender: anyNamed('gender'),
            dateOfBirth: anyNamed('dateOfBirth'),
          ),
        ).thenAnswer((_) async {});

        await controller.register(
          email: 'new@example.com',
          username: 'newuser',
          password: 'Secret1!',
          gender: 'MALE',
          dateOfBirth: '2000-01-01',
        );

        expect(
          controller.state,
          equals(const AsyncValue<AuthUserEntity?>.data(null)),
        );
      },
    );

    test('sets state to error(ConflictFailure) for duplicate email', () async {
      when(
        mockRegister(
          email: anyNamed('email'),
          username: anyNamed('username'),
          password: anyNamed('password'),
          gender: anyNamed('gender'),
          dateOfBirth: anyNamed('dateOfBirth'),
        ),
      ).thenThrow(const ConflictFailure('Email already in use.'));

      await controller.register(
        email: 'dup@example.com',
        username: 'user',
        password: 'Secret1!',
        gender: 'MALE',
        dateOfBirth: '2000-01-01',
      );

      expect((controller.state as AsyncError).error, isA<ConflictFailure>());
    });
  });

  // ── verifyEmail ────────────────────────────────────────────────────────────

  group('verifyEmail', () {
    test('sets state to data(user) on valid token', () async {
      when(
        mockVerifyEmail('user@example.com', 'ABC123'),
      ).thenAnswer((_) async => tUser);

      await controller.verifyEmail('user@example.com', 'ABC123');

      expect(
        controller.state,
        equals(const AsyncValue<AuthUserEntity?>.data(tUser)),
      );
    });

    test('sets state to error for invalid token', () async {
      when(mockVerifyEmail(any, any)).thenThrow(const UnauthorizedFailure());

      await controller.verifyEmail('user@example.com', 'WRONG1');

      expect(controller.state, isA<AsyncError>());
    });
  });

  // ── resendVerification ─────────────────────────────────────────────────────

  group('resendVerification', () {
    test('calls use case without changing auth state', () async {
      when(mockResend(any)).thenAnswer((_) async {});
      final stateBefore = controller.state;

      await controller.resendVerification('user@example.com');

      verify(mockResend('user@example.com')).called(1);
      expect(controller.state, equals(stateBefore));
    });
  });

  // ── logout ─────────────────────────────────────────────────────────────────

  group('logout', () {
    test(
      'resets state to data(null) and calls signOut + Google signOut',
      () async {
        when(mockLogin(any, any)).thenAnswer((_) async => tUser);
        await controller.login('user@example.com', 'Secret1!');

        when(mockLogout()).thenAnswer((_) async {});
        when(mockGoogle.signOut()).thenAnswer((_) async {});

        await controller.logout();

        expect(
          controller.state,
          equals(const AsyncValue<AuthUserEntity?>.data(null)),
        );
        verify(mockLogout()).called(1);
        verify(mockGoogle.signOut()).called(1);
      },
    );
  });

  // ── logoutAll ──────────────────────────────────────────────────────────────

  group('logoutAll', () {
    test('resets state to data(null) and calls signOutAll', () async {
      when(mockLogin(any, any)).thenAnswer((_) async => tUser);
      await controller.login('user@example.com', 'Secret1!');

      when(mockLogoutAll()).thenAnswer((_) async {});
      when(mockGoogle.signOut()).thenAnswer((_) async {});

      await controller.logoutAll();

      expect(
        controller.state,
        equals(const AsyncValue<AuthUserEntity?>.data(null)),
      );
      verify(mockLogoutAll()).called(1);
    });
  });

  // ── forgotPassword ─────────────────────────────────────────────────────────

  group('forgotPassword', () {
    test(
      'does not change state on success (security: never reveal existence)',
      () async {
        when(mockForgotPassword(any)).thenAnswer((_) async {});
        final stateBefore = controller.state;

        await controller.forgotPassword('user@example.com');

        expect(controller.state, equals(stateBefore));
      },
    );

    test('swallows network error without changing state', () async {
      when(mockForgotPassword(any)).thenThrow(const NetworkFailure());

      await expectLater(
        controller.forgotPassword('user@example.com'),
        completes,
      );
      // Error is swallowed — state must not be an error.
      expect(controller.state, isNot(isA<AsyncError>()));
    });
  });

  // ── resetPassword ──────────────────────────────────────────────────────────

  group('resetPassword', () {
    test('sets state to data(null) on success', () async {
      when(
        mockResetPassword(
          email: anyNamed('email'),
          token: anyNamed('token'),
          newPassword: anyNamed('newPassword'),
          confirmPassword: anyNamed('confirmPassword'),
          signoutAll: anyNamed('signoutAll'),
        ),
      ).thenAnswer((_) async {});

      await controller.resetPassword(
        email: 'user@example.com',
        token: 'ABC123',
        newPassword: 'NewSecret1!',
        confirmPassword: 'NewSecret1!',
      );

      expect(
        controller.state,
        equals(const AsyncValue<AuthUserEntity?>.data(null)),
      );
    });

    test('sets state to error for expired token', () async {
      when(
        mockResetPassword(
          email: anyNamed('email'),
          token: anyNamed('token'),
          newPassword: anyNamed('newPassword'),
          confirmPassword: anyNamed('confirmPassword'),
          signoutAll: anyNamed('signoutAll'),
        ),
      ).thenThrow(const UnauthorizedFailure());

      await controller.resetPassword(
        email: 'user@example.com',
        token: 'EXPIRE',
        newPassword: 'NewSecret1!',
        confirmPassword: 'NewSecret1!',
      );

      expect(controller.state, isA<AsyncError>());
    });
  });

  // ── deleteAccount ──────────────────────────────────────────────────────────

  group('deleteAccount', () {
    test('sets state to data(null) on success', () async {
      when(
        mockDeleteAccount(password: anyNamed('password')),
      ).thenAnswer((_) async {});

      await controller.deleteAccount(password: 'Secret1!');

      expect(
        controller.state,
        equals(const AsyncValue<AuthUserEntity?>.data(null)),
      );
      verify(mockDeleteAccount(password: 'Secret1!')).called(1);
    });

    test('sets state to error for wrong password', () async {
      when(
        mockDeleteAccount(password: anyNamed('password')),
      ).thenThrow(const UnauthorizedFailure());

      await controller.deleteAccount(password: 'wrong');

      expect(controller.state, isA<AsyncError>());
    });
  });

  // ── loginWithGoogle ────────────────────────────────────────────────────────

  group('loginWithGoogle', () {
    test('returns false and does not change state when user cancels', () async {
      when(mockGoogle.signIn()).thenAnswer((_) async => null);

      final result = await controller.loginWithGoogle();

      expect(result, isFalse);
      expect(
        controller.state,
        equals(const AsyncValue<AuthUserEntity?>.data(null)),
      );
    });
  });
}
