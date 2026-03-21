/// Central configuration for mock testing.
///
/// ── HOW TO USE ────────────────────────────────────────────────────────────────
/// 1. Keep [useMock] = true while the backend is not ready.
/// 2. Change ONE scenario value below to test a specific flow.
/// 3. Hot-restart the app — no other files need to change.
/// 4. Set [useMock] = false to switch to the real backend.
///
/// ── SCENARIO QUICK REFERENCE ─────────────────────────────────────────────────
///
/// EMAIL CHECK (controls where "Continue" goes after email entry)
///   MockEmailScenario.existingAccount  → email is registered → login path
///   MockEmailScenario.newAccount       → email is new        → register path
///
/// LOGIN
///   MockLoginScenario.success          → logs in, goes to home
///   MockLoginScenario.wrongPassword    → shows "Invalid credentials" error
///   MockLoginScenario.unverified       → shows "Please verify your email" → verify-email screen
///
/// REGISTER
///   MockRegisterScenario.success       → registration succeeds → verify-email screen
///   MockRegisterScenario.emailTaken    → shows "This email is already in use."
///   MockRegisterScenario.usernameTaken → shows "This username is already taken."
///
/// VERIFY EMAIL
///   MockVerifyScenario.success         → verified, goes to home
///   MockVerifyScenario.invalidToken    → shows "Invalid or expired code" error
///
/// FORGOT PASSWORD
///   MockForgotScenario.success         → navigates to check-your-email screen
///   MockForgotScenario.invalidEmail    → shows validation error (400)
///
/// RESET PASSWORD
///   MockResetScenario.success          → password reset, goes to landing
///   MockResetScenario.invalidToken     → shows "Token invalid or expired" error
///   MockResetScenario.passwordMismatch → shows "Passwords do not match" error
///
/// DELETE ACCOUNT
///   MockDeleteScenario.success         → account deleted, goes to landing
///   MockDeleteScenario.wrongPassword   → shows "Invalid password" error
///   MockDeleteScenario.banned          → shows "Banned accounts cannot be deleted" error
///
/// LOGOUT
///   MockLogoutScenario.success         → tokens cleared, goes to landing
class MockAuthConfig {
  MockAuthConfig._();

  // ── Master switch ──────────────────────────────────────────────────────────
  /// Set to false to use the real backend instead of mock data.
  //static const bool useMock = true;
  static const bool useMock = false;

  // ── Active scenarios ───────────────────────────────────────────────────────
  static const MockEmailScenario emailScenario = MockEmailScenario.newAccount;
  static const MockLoginScenario loginScenario = MockLoginScenario.success;
  static const MockRegisterScenario registerScenario =
      MockRegisterScenario.success;
  static const MockVerifyScenario verifyScenario = MockVerifyScenario.success;
  static const MockForgotScenario forgotScenario = MockForgotScenario.success;
  static const MockResetScenario resetScenario = MockResetScenario.success;
  static const MockDeleteScenario deleteScenario = MockDeleteScenario.success;
  static const MockLogoutScenario logoutScenario = MockLogoutScenario.success;

  /// Simulated network delay so loading states are visible during testing.
  static const Duration delay = Duration(milliseconds: 700);
}

// ── Scenario enums ─────────────────────────────────────────────────────────────

enum MockEmailScenario { existingAccount, newAccount }

enum MockLoginScenario { success, wrongPassword, unverified }

enum MockRegisterScenario { success, emailTaken, usernameTaken }

enum MockVerifyScenario { success, invalidToken }

enum MockForgotScenario { success, invalidEmail }

enum MockResetScenario { success, invalidToken, passwordMismatch }

enum MockDeleteScenario { success, wrongPassword, banned }

enum MockLogoutScenario { success }
