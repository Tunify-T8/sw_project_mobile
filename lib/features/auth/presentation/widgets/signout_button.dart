import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';

/// A full-width "Sign out" button that handles the confirmation dialog
/// and logout flow internally.
///
/// Place this widget wherever a sign-out action is needed — currently
/// in [AccountScreen] and available for the Settings screen.
///
/// Tapping the button shows an [AlertDialog] asking "Clear user data?"
/// with Cancel and OK options. Pressing OK:
///   1. Calls [AuthController.logout] to revoke the refresh token
///      and clear stored credentials.
///   2. Navigates to [AppRoutes.landing] and clears the back stack
///      so the user cannot navigate back to authenticated screens.
///
/// Usage:
/// ```dart
/// const SignOutButton()
/// ```
class SignOutButton extends ConsumerWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showConfirmationDialog(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceHigh,
          foregroundColor: AppColors.onBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        child: const Text('Sign out'),
      ),
    );
  }

  /// Shows the "Clear user data?" confirmation dialog.
  void _showConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Clear user data?',
          style: TextStyle(
            color: AppColors.onBackground,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'You will have to reconnect your SoundCloud account.',
          style: TextStyle(
            color: AppColors.onBackgroundMuted,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.onBackgroundMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.landing,
                  (route) => false,
                );
              }
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
