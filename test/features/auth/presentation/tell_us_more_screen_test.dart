/// Widget tests for [TellUsMoreScreen].
///
/// Covers:
///   Continue button is disabled when ALL required fields are missing.
///   Disabled when Display Name is missing.
///   Disabled when Month is missing.
///   Disabled when Day is missing.
///   Disabled when Year is missing.
///   Disabled when Gender is missing.
///   Happy path — button enabled when all five fields are filled.
///
/// ── WHY AuthDropdownField NOT DropdownButton ──────────────────────────────────
/// The dropdowns use a custom [AuthDropdownField<T>] wrapper widget, not a raw
/// [DropdownButton<T>]. Finding by key returns [AuthDropdownField], so we must
/// cast to that type and call its [onChanged] directly.
/// Casting to [DropdownButton] fails with a type error because [AuthDropdownField]
/// is a [StatelessWidget] whose [DropdownButton] lives one level deeper in the tree.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/features/auth/presentation/screens/tell_us_more_screen.dart';
import 'package:software_project/features/auth/presentation/widgets/auth_dropdown_field.dart';

import '../../../helpers/mocks.mocks.dart';
import '../helpers/auth_selectors.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Future<void> pumpScreen(
  WidgetTester tester, {
  required MockAuthRepository mockRepo,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      child: MaterialApp(
        home: TellUsMoreScreen(
          email: 'test@example.com',
          password: 'ValidPass1!',
        ),
        routes: {
          '/verify-email': (_) =>
              const Scaffold(body: Text('VerifyEmailScreen')),
        },
      ),
    ),
  );
}

/// Returns the [onPressed] value of the Continue [AppButton].
VoidCallback? _continueOnPressed(WidgetTester tester) {
  // AppButton wraps an ElevatedButton — descend into it to read onPressed.
  final btnKey = find.byKey(AuthKeys.tellUsMoreContinueButton);
  final inner = find.descendant(
    of: btnKey,
    matching: find.byType(ElevatedButton),
  );
  if (tester.any(inner)) {
    return tester.widget<ElevatedButton>(inner).onPressed;
  }
  return tester.widget<ElevatedButton>(btnKey).onPressed;
}

/// Sets an [AuthDropdownField<T>] value by invoking its [onChanged] directly.
///
/// The key resolves to an [AuthDropdownField] widget (not a raw [DropdownButton]),
/// so we cast to [AuthDropdownField<T>] and call onChanged — exactly what a
/// real user tap would do, without the overlay rendering issues of tap().
void _setDropdown<T>(WidgetTester tester, Key key, T value) {
  final widget = tester.widget<AuthDropdownField<T>>(find.byKey(key));
  widget.onChanged(value);
}

/// Fills every required field except the one named by [skip].
/// Pass an empty string (or any non-matching string) to fill all fields.
Future<void> fillAllExcept(WidgetTester tester, {required String skip}) async {
  if (skip != 'displayName') {
    // Use a valid username (no spaces — backend rule [a-zA-Z0-9_]).
    await tester.enterText(AuthFinders.displayNameField, 'TestUser');
    await tester.pump();
  }

  if (skip != 'month') {
    _setDropdown<String>(tester, AuthKeys.dobMonthDropdown, 'January');
    await tester.pump();
  }

  if (skip != 'day') {
    _setDropdown<int>(tester, AuthKeys.dobDayDropdown, 1);
    await tester.pump();
  }

  if (skip != 'year') {
    // Pick a year definitely in the list (current year minus 20 = at least 13).
    final year = DateTime.now().year - 20;
    _setDropdown<int>(tester, AuthKeys.dobYearDropdown, year);
    await tester.pump();
  }

  if (skip != 'gender') {
    _setDropdown<String>(tester, AuthKeys.genderDropdown, 'Male');
    await tester.pump();
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  // ── all fields missing ────────────────────────────────────────────

  testWidgets('button disabled when all required fields are missing', (
    tester,
  ) async {
    await pumpScreen(tester, mockRepo: mockRepo);
    expect(_continueOnPressed(tester), isNull);
  });

  // ── display name missing ────────────────────────────────────────

  testWidgets('button disabled when Display Name is missing', (tester) async {
    await pumpScreen(tester, mockRepo: mockRepo);
    await fillAllExcept(tester, skip: 'displayName');
    expect(_continueOnPressed(tester), isNull);
  });

  // ── month missing ────────────────────────────────────────────────

  testWidgets('button disabled when Month is missing', (tester) async {
    await pumpScreen(tester, mockRepo: mockRepo);
    await fillAllExcept(tester, skip: 'month');
    expect(_continueOnPressed(tester), isNull);
  });

  // ── day missing ──────────────────────────────────────────────────

  testWidgets('button disabled when Day is missing', (tester) async {
    await pumpScreen(tester, mockRepo: mockRepo);
    await fillAllExcept(tester, skip: 'day');
    expect(_continueOnPressed(tester), isNull);
  });

  // ── year missing ─────────────────────────────────────────────────

  testWidgets('button disabled when Year is missing', (tester) async {
    await pumpScreen(tester, mockRepo: mockRepo);
    await fillAllExcept(tester, skip: 'year');
    expect(_continueOnPressed(tester), isNull);
  });

  // ── gender missing ───────────────────────────────────────────────

  testWidgets('button disabled when Gender is missing', (tester) async {
    await pumpScreen(tester, mockRepo: mockRepo);
    await fillAllExcept(tester, skip: 'gender');
    expect(_continueOnPressed(tester), isNull);
  });

  // ── Happy path: all fields filled → button enabled ────────────────────────

  testWidgets('button is enabled when all five required fields are filled', (
    tester,
  ) async {
    await pumpScreen(tester, mockRepo: mockRepo);
    await fillAllExcept(tester, skip: '');
    expect(_continueOnPressed(tester), isNotNull);
  });
}
