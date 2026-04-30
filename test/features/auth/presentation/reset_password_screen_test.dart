/// Widget tests for [ResetPasswordScreen].
///
/// Covers:
///   Valid token + valid password → navigates to PasswordResetSuccessScreen.
///   Invalid/expired token shows error snackbar; user stays on screen.
///   Invalid new password (too weak) is blocked by the form validator.
///   Password mismatch blocked by confirm-password validator.
///
/// ── WHY setScreenSize ────────────────────────────────────────────────────────
/// ResetPasswordScreen contains many fields (email, token, password, confirm,
/// checkbox) plus a banner — the form is taller than the default test viewport
/// of 800×600. The save button renders off-screen at ~y=719, making tap() fail
/// with "offset outside bounds". Setting the surface to 800×1200 keeps
/// everything visible without needing to scroll.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/features/auth/presentation/screens/reset_password_screen.dart';

import '../../../helpers/mocks.mocks.dart';
import '../helpers/auth_selectors.dart';

// ── Helpers ──────────────────────────────────────────────────────────

/// Pumps [ResetPasswordScreen] inside a [ProviderScope] with a mocked repo.
///
/// The test surface is forced to 800×1200 so the Save button (which renders
/// below the fold on the default 800×600 viewport) is on-screen and tappable.
Future<void> pumpScreen(
  WidgetTester tester, {
  required MockAuthRepository mockRepo,
}) async {
  // Expand the logical viewport so the full form fits without scrolling.
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      child: MaterialApp(
        home: ResetPasswordScreen(email: 'user@example.com', resetToken: null),
        routes: {
          '/password-reset-success': (_) =>
              const Scaffold(body: Text('ResetSuccessScreen')),
          '/landing': (_) => const Scaffold(body: Text('LandingScreen')),
        },
      ),
    ),
  );
}

/// Fills the token, new password, and confirm password fields.
Future<void> fillForm(
  WidgetTester tester, {
  String token = 'ABC123',
  String password = 'NewValid1!',
  String confirm = 'NewValid1!',
}) async {
  await tester.enterText(AuthFinders.resetTokenField, token);
  await tester.pump();
  await tester.enterText(AuthFinders.resetNewPasswordField, password);
  await tester.pump();
  await tester.enterText(AuthFinders.resetConfirmPasswordField, confirm);
  await tester.pump();
}

/// Scrolls the save button into view and taps it.
Future<void> tapSave(WidgetTester tester) async {
  await tester.ensureVisible(AuthFinders.resetSaveButton);
  await tester.pump();
  await tester.tap(AuthFinders.resetSaveButton);
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  // ── valid token + password → success screen ───────────────────────

  testWidgets('valid token and password navigate to success screen', (
    tester,
  ) async {
    when(
      mockRepo.resetPassword(
        email: 'user@example.com',
        token: 'ABC123',
        newPassword: 'NewValid1!',
        confirmPassword: 'NewValid1!',
        signoutAll: anyNamed('signoutAll'),
      ),
    ).thenAnswer((_) async {});

    await pumpScreen(tester, mockRepo: mockRepo);
    await fillForm(tester);
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.text('ResetSuccessScreen'), findsOneWidget);
  });

  // ── invalid / expired token → error snackbar ─────────────────────

  testWidgets('expired token shows error snackbar', (tester) async {
    when(
      mockRepo.resetPassword(
        email: anyNamed('email'),
        token: anyNamed('token'),
        newPassword: anyNamed('newPassword'),
        confirmPassword: anyNamed('confirmPassword'),
        signoutAll: anyNamed('signoutAll'),
      ),
    ).thenThrow(const UnauthorizedFailure());

    await pumpScreen(tester, mockRepo: mockRepo);
    await fillForm(tester, token: 'EXPIRE');
    await tapSave(tester);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
  });

  // ── weak new password → validation error, no network call ─────────

  testWidgets('weak new password is blocked by validator', (tester) async {
    await pumpScreen(tester, mockRepo: mockRepo);

    await fillForm(tester, password: 'weak', confirm: 'weak');
    await tapSave(tester);
    await tester.pump();

    verifyNever(
      mockRepo.resetPassword(
        email: anyNamed('email'),
        token: anyNamed('token'),
        newPassword: anyNamed('newPassword'),
        confirmPassword: anyNamed('confirmPassword'),
        signoutAll: anyNamed('signoutAll'),
      ),
    );
  });

  // ── Password mismatch → validation error ──────────────────────────────────

  testWidgets('password mismatch is blocked by confirm-password validator', (
    tester,
  ) async {
    await pumpScreen(tester, mockRepo: mockRepo);

    await fillForm(tester, password: 'NewValid1!', confirm: 'DifferentPass1!');
    await tapSave(tester);
    await tester.pump();

    verifyNever(
      mockRepo.resetPassword(
        email: anyNamed('email'),
        token: anyNamed('token'),
        newPassword: anyNamed('newPassword'),
        confirmPassword: anyNamed('confirmPassword'),
        signoutAll: anyNamed('signoutAll'),
      ),
    );
  });
}
