import 'package:flutter/material.dart';
import 'colors.dart';

/// Centralized text style definitions for the Tunify app.
///
/// All text styles used across the app must come from here.
/// Do NOT hard-code TextStyle instances in individual widgets or screens.
class AppTextStyles {
  AppTextStyles._();

  // ── Display ───────────────────────────────────────────────────────────────

  /// Large screen title, e.g. "Sign in or create\nan account".
  static const TextStyle screenTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.onBackground,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Medium section heading, e.g. "Check your email".
  static const TextStyle sectionHeading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.onBackground,
  );

  // ── Body ──────────────────────────────────────────────────────────────────

  /// Standard body text.
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackground,
    height: 1.5,
  );

  /// Muted body text, for subtitles and help copy.
  static const TextStyle bodyMuted = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackgroundMuted,
    height: 1.5,
  );

  /// Small caption / footnote text.
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackgroundMuted,
    height: 1.5,
  );

  // ── Form ──────────────────────────────────────────────────────────────────

  /// Field label above form inputs.
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackgroundMuted,
  );

  /// Input text inside form fields.
  static const TextStyle inputText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackground,
  );

  /// Hint / placeholder text inside form fields.
  static const TextStyle inputHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackgroundMuted,
  );

  /// Validation error message below form fields.
  static const TextStyle inputError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
  );

  // ── Buttons ───────────────────────────────────────────────────────────────

  /// Primary button label.
  static const TextStyle buttonLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );

  /// Underlined inline link text.
  static const TextStyle link = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackgroundMuted,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.onBackgroundMuted,
  );
}
