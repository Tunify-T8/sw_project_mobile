import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/shared/ui/widgets/app_back_button.dart';

/// Shows body text and a pink-red "Delete account" button.
/// Tapping it opens a confirmation [AlertDialog].
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) => _DeleteDialog(
        onConfirm: () {
          Navigator.of(context).pop(); // close dialog
          _deleteAccount();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    // Invoke the controller to perform the delete request and update state.
    await ref
        .read(authControllerProvider.notifier)
        .deleteAccount(password: null);
  }

  @override
  Widget build(BuildContext context) {
    // Disable the button while an operation is in progress.
    final isLoading = ref.watch(authControllerProvider).isLoading;

    // Listen for controller state changes to handle success/error events.
    ref.listen<AsyncValue<dynamic>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          // Navigate away on successful deletion.
          if (previous?.isLoading == true) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.landing,
              (route) => false,
            );
          }
        },
        error: (e, _) {
          final msg = e is Failure ? e.message : 'Deletion failed.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: AppColors.error),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                0,
              ),
              child: AppBackButtonRow(title: 'Delete account'),
            ),

            const SizedBox(height: AppSpacing.xl),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This will delete your account and all your '
                    'tracks, comments and stats',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Confirmation button for deleting the account.
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _showConfirmDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deleteRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Delete account'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confirmation Dialog ────────────────────────────────────────────

/// AlertDialog:
/// dark surface background, "Delete account" title, body, Cancel | Delete my account.
class _DeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _DeleteDialog({required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Delete account',
        style: TextStyle(
          color: AppColors.onBackground,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: const Text(
        'This will delete your account and all your tracks, comments and stats',
        style: TextStyle(
          color: AppColors.onBackgroundMuted,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.onBackgroundMuted),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text(
            'Delete my account',
            style: TextStyle(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
