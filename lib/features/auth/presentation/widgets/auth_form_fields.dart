/// Barrel file — import this single file in any auth screen to access
/// all widgets used in the auth feature.
// ignore_for_file: unnecessary_library_directive
library;

///
/// ── Shared widgets (domain-agnostic, reusable by any feature) ────────────────
///   [AppButton]        — full-width button with four styles and loading state
///   [AppTextField]     — text input with consistent dark styling and white cursor
///   [AppBackButtonRow] — grey-circle back chevron + page title on the same row
///
/// ── Auth-specific widgets (only used inside the auth feature) ─────────────────
///   [VisibilityToggle]    — show/hide icon for password fields
///   [AuthLink]            — tappable blue text link ("Need help?", "Forgot password?")
///   [AuthEmailDisplay]    — email label + value as plain text (not in an input field)
///   [AuthDropdownField]   — styled dropdown for DOB and gender fields
///   [TokenDigitField]     — single character box for 6-digit token entry
///   [SignOutButton]       — "Sign out" button with confirmation dialog and logout logic

// ── Shared ────────────────────────────────────────────────────────────────────
export 'package:software_project/shared/ui/widgets/app_button.dart';
export 'package:software_project/shared/ui/widgets/app_text_field.dart';
export 'package:software_project/shared/ui/widgets/app_back_button.dart';

// ── Auth-specific ─────────────────────────────────────────────────────────────
export 'visibility_toggle.dart';
export 'auth_link.dart';
export 'auth_email_display.dart';
export 'auth_dropdown_field.dart';
export 'token_digit_field.dart';
export 'signout_button.dart';
