import 'package:flutter/material.dart';

/// Central color palette for the Tunify / SoundCloud clone.
/// Every color in the app must come from here — never hard-code elsewhere.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFFF5500);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceHigh = Color(0xFF2A2A2A);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color border = Color(0xFF2A2A2A);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onBackgroundMuted = Color(0xFF888888);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Landing buttons ───────────────────────────────────────────────────────
  /// "Create an account" — white pill
  static const Color buttonPrimary = Color(0xFFFFFFFF);
  static const Color buttonPrimaryText = Color(0xFF000000);

  /// "Log in" — soft blue pill (#C6D8F8)
  static const Color buttonSecondary = Color(0xFFC6D8F8);
  static const Color buttonSecondaryText = Color(0xFF000000);

  // ── OAuth buttons ─────────────────────────────────────────────────────────
  static const Color facebookBlue = Color(0xFF1877F2);
  static const Color googleGrey = Color(0xFF3C3C3C);
  static const Color appleBlack = Color(0xFF000000);

  // ── Links ─────────────────────────────────────────────────────────────────
  static const Color link = Color(0xFF4A90D9);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF4444);

  /// Bright pink-red used for the "Delete account" button (matches screenshot)
  static const Color deleteRed = Color(0xFFE8336D);
}
