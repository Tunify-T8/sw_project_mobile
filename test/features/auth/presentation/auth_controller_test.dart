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
  late MockTokenStorage mockTokenStorage;
  late ProviderContainer container;
  late AuthController ctrl;

  const tUser = AuthUserEntity(
    id: '1',
    email: 'user@example.com',
    username: 'testuser',
    role: 'LISTENER',
    isVerified: true,
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
    mockTokenStorage = MockTokenStorage();

    // AuthController is a Notifier — it reads its dependencies via ref.
    // We override every use-case provider with a mock so the controller
    // gets mocks without any constructor parameters needed.
    container = ProviderContainer(
      overrides: [
        checkEmailUseCaseProvider.overrideWithValue(mockCheckEmail),
        registerUseCaseProvider.overrideWithValue(mockRegister),
        verifyEmailUseCaseProvider.overrideWithValue(mockVerifyEmail),
        resendVerificationUseCaseProvider.overrideWithValue(mockResend),
        loginUseCaseProvider.overrideWithValue(mockLogin),
        logoutUseCaseProvider.overrideWithValue(mockLogout),
        logoutAllUseCaseProvider.overrideWithValue(mockLogoutAll),
        forgotPasswordUseCaseProvider.overrideWithValue(mockForgotPassword),
        resetPasswordUseCaseProvider.overrideWithValue(mockResetPassword),
        deleteAccountUseCaseProvider.overrideWithValue(mockDeleteAccount),
        googleSignInServiceProvider.overrideWithValue(mockGoogle),
        tokenStorageProvider.overrideWithValue(mockTokenStorage),
      ],
    );

    ctrl = container.read(authControllerProvider.notifier);
  });

  tearDown(() => container.dispose());

  // ── Initial state ──────────────────────────────────────────────────────────

  test('initial state is AsyncData(null)', () {
    expect(
      container.read(authControllerProvider),
      equals(const AsyncValue<AuthUserEntity?>.data(null)),
    );
  });

  // ── checkEmail ─────────────────────────────────────────────────────────────

  group('checkEmail', () {
    test('returns true when email exists', () async {
      when(
        mockCheckEmail('existing@example.com'),
      ).thenAnswer((_) async => true);

      final result = await ctrl.checkEmail('existing@example.com');

      expect(result, isTrue);
    });

    test('returns false when email is new', () async {
      when(mockCheckEmail('new@example.com')).thenAnswer((_) async => false);

      final result = await ctrl.checkEmail('new@example.com');

      expect(result, isFalse);
    });

    test('sets state to error and returns false on failure', () async {
      when(mockCheckEmail(any)).thenThrow(const NetworkFailure());

      final result = await ctrl.checkEmail('user@example.com');

      expect(result, isFalse);
      expect(container.read(authControllerProvider), isA<AsyncError>());
    });
  });

  // ── login ──────────────────────────────────────────────────────────────────

  group('login', () {
    test('transitions loading → data(user) on success', () async {
      final states = <AsyncValue<AuthUserEntity?>>[];
      // container.listen is the correct way to observe Notifier state changes.
      container.listen<AsyncValue<AuthUserEntity?>>(
        authControllerProvider,
        (_, next) => states.add(next),
        fireImmediately: false,
      );

      when(
        mockLogin('user@example.com', 'Secret1!'),
      ).thenAnswer((_) async => tUser);

      await ctrl.login('user@example.com', 'Secret1!');

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

        await ctrl.login('user@example.com', 'wrong');

        expect(
          (container.read(authControllerProvider) as AsyncError).error,
          isA<UnauthorizedFailure>(),
        );
      },
    );

    test(
      'sets state to error(UnverifiedUserFailure) when unverified',
      () async {
        when(mockLogin(any, any)).thenThrow(const UnverifiedUserFailure());

        await ctrl.login('user@example.com', 'Secret1!');

        expect(
          (container.read(authControllerProvider) as AsyncError).error,
          isA<UnverifiedUserFailure>(),
        );
      },
    );
  });

  // ── register ──────────────────────────────────────────────────────────────

  group('register', () {
    test('sets state to data(null) on success', () async {
      when(
        mockRegister(
          email: anyNamed('email'),
          username: anyNamed('username'),
          password: anyNamed('password'),
          gender: anyNamed('gender'),
          dateOfBirth: anyNamed('dateOfBirth'),
        ),
      ).thenAnswer((_) async {});

      await ctrl.register(
        email: 'new@example.com',
        username: 'newuser',
        password: 'Secret1!',
        gender: 'MALE',
        dateOfBirth: '2000-01-01',
      );

      expect(
        container.read(authControllerProvider),
        equals(const AsyncValue<AuthUserEntity?>.data(null)),
      );
    });

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

      await ctrl.register(
        email: 'dup@example.com',
        username: 'user',
        password: 'Secret1!',
        gender: 'MALE',
        dateOfBirth: '2000-01-01',
      );

      expect(
        (container.read(authControllerProvider) as AsyncError).error,
        isA<ConflictFailure>(),
      );
    });
  });

  // ── verifyEmail ────────────────────────────────────────────────────────────

  group('verifyEmail', () {
    test('sets state to data(user) on valid token', () async {
      when(
        mockVerifyEmail('user@example.com', 'ABC123'),
      ).thenAnswer((_) async => tUser);

      await ctrl.verifyEmail('user@example.com', 'ABC123');

      expect(
        container.read(authControllerProvider),
        equals(const AsyncValue<AuthUserEntity?>.data(tUser)),
      );
    });

    test('sets state to error for invalid token', () async {
      when(mockVerifyEmail(any, any)).thenThrow(const UnauthorizedFailure());

      await ctrl.verifyEmail('user@example.com', 'WRONG1');

      expect(container.read(authControllerProvider), isA<AsyncError>());
    });
  });

  // ── resendVerification ─────────────────────────────────────────────────────

  group('resendVerification', () {
    test('calls use case without changing auth state', () async {
      when(mockResend(any)).thenAnswer((_) async {});
      final stateBefore = container.read(authControllerProvider);

      await ctrl.resendVerification('user@example.com');

      verify(mockResend('user@example.com')).called(1);
      expect(container.read(authControllerProvider), equals(stateBefore));
    });
  });

  // ── logout ─────────────────────────────────────────────────────────────────

  group('logout', () {
    test(
      'resets state to data(null) and calls signOut + Google signOut',
      () async {
        when(mockLogin(any, any)).thenAnswer((_) async => tUser);
        await ctrl.login('user@example.com', 'Secret1!');

        when(mockLogout()).thenAnswer((_) async {});
        when(mockGoogle.signOut()).thenAnswer((_) async {});

        await ctrl.logout();

        expect(
          container.read(authControllerProvider),
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
      await ctrl.login('user@example.com', 'Secret1!');

      when(mockLogoutAll()).thenAnswer((_) async {});
      when(mockGoogle.signOut()).thenAnswer((_) async {});

      await ctrl.logoutAll();

      expect(
        container.read(authControllerProvider),
        equals(const AsyncValue<AuthUserEntity?>.data(null)),
      );
      verify(mockLogoutAll()).called(1);
    });
  });

  // ── forgotPassword ─────────────────────────────────────────────────────────

  group('forgotPassword', () {
    test('does not change state on success', () async {
      when(mockForgotPassword(any)).thenAnswer((_) async {});
      final stateBefore = container.read(authControllerProvider);

      await ctrl.forgotPassword('user@example.com');

      expect(container.read(authControllerProvider), equals(stateBefore));
    });

    test('swallows NetworkFailure without changing state', () async {
      when(mockForgotPassword(any)).thenThrow(const NetworkFailure());

      await expectLater(ctrl.forgotPassword('user@example.com'), completes);

      expect(container.read(authControllerProvider), isNot(isA<AsyncError>()));
    });

    test('sets state to error for ValidationFailure', () async {
      when(
        mockForgotPassword(any),
      ).thenThrow(const ValidationFailure('Invalid email address format.'));

      await ctrl.forgotPassword('not-an-email');

      expect(
        (container.read(authControllerProvider) as AsyncError).error,
        isA<ValidationFailure>(),
      );
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

      await ctrl.resetPassword(
        email: 'user@example.com',
        token: 'ABC123',
        newPassword: 'NewSecret1!',
        confirmPassword: 'NewSecret1!',
      );

      expect(
        container.read(authControllerProvider),
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

      await ctrl.resetPassword(
        email: 'user@example.com',
        token: 'EXPIRE',
        newPassword: 'NewSecret1!',
        confirmPassword: 'NewSecret1!',
      );

      expect(container.read(authControllerProvider), isA<AsyncError>());
    });
  });

  // ── deleteAccount ──────────────────────────────────────────────────────────

  group('deleteAccount', () {
    test('sets state to data(null) on success', () async {
      when(
        mockDeleteAccount(password: anyNamed('password')),
      ).thenAnswer((_) async {});

      await ctrl.deleteAccount(password: 'Secret1!');

      expect(
        container.read(authControllerProvider),
        equals(const AsyncValue<AuthUserEntity?>.data(null)),
      );
      verify(mockDeleteAccount(password: 'Secret1!')).called(1);
    });

    test('sets state to error for wrong password', () async {
      when(
        mockDeleteAccount(password: anyNamed('password')),
      ).thenThrow(const UnauthorizedFailure());

      await ctrl.deleteAccount(password: 'wrong');

      expect(container.read(authControllerProvider), isA<AsyncError>());
    });
  });

  // ── loginWithGoogle ────────────────────────────────────────────────────────

  group('loginWithGoogle', () {
    test('returns false and does not change state when user cancels', () async {
      when(mockGoogle.signIn()).thenAnswer((_) async => null);

      final result = await ctrl.loginWithGoogle();

      expect(result, isFalse);
      expect(
        container.read(authControllerProvider),
        equals(const AsyncValue<AuthUserEntity?>.data(null)),
      );
    });
  });

  group('syncProfileIdentity', () {
    test('updates the stored authenticated user after profile edits', () async {
      when(mockTokenStorage.getUser()).thenAnswer((_) async => tUser);
      when(mockTokenStorage.saveUser(any)).thenAnswer((_) async {});

      final updated = await ctrl.syncProfileIdentity(
        username: 'artist-updated',
        avatarUrl: 'https://cdn.example.com/avatar.png',
      );

      expect(updated?.username, 'artist-updated');
      expect(updated?.avatarUrl, 'https://cdn.example.com/avatar.png');
      expect(
        container.read(authControllerProvider).value?.username,
        'artist-updated',
      );
      verify(
        mockTokenStorage.saveUser(
          argThat(
            isA<AuthUserEntity>()
                .having((user) => user.username, 'username', 'artist-updated')
                .having(
                  (user) => user.avatarUrl,
                  'avatarUrl',
                  'https://cdn.example.com/avatar.png',
                ),
          ),
        ),
      ).called(1);
    });
  });
}
