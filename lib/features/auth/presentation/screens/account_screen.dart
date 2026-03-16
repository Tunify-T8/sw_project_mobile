import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/features/auth/presentation/widgets/auth_form_fields.dart';

/// Account settings screen — accessible from Settings → Account.
///
/// Shows the authenticated user's email address, a "Sign out" button,
/// and a "Delete account" row that navigates to [DeleteAccountScreen].
///
/// The "Sign out" button reuses [SignOutButton] which handles the
/// "Clear user data?" confirmation dialog and the logout logic.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the current user from provider state.
    // If state is null (unauthenticated) the email falls back to empty.
    final user = ref.watch(authControllerProvider).value;
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: grey-circle back button + "Account" title ──────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                0,
              ),
              child: AppBackButtonRow(title: 'Account'),
            ),

            const SizedBox(height: AppSpacing.xxl),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Email address ─────────────────────────────────────────
                  Text('Email address', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.xs),
                  Text(email, style: AppTextStyles.body),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Sign out button ───────────────────────────────────────
                  // SignOutButton handles the "Clear user data?" dialog,
                  // the logout call, and navigation to landing internally.
                  // No need to duplicate that logic here.
                  const SignOutButton(),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            const Divider(color: AppColors.border, height: 1),

            // ── Delete account row ────────────────────────────────────────
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              title: Text('Delete account', style: AppTextStyles.body),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.onBackgroundMuted,
              ),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.deleteAccount),
            ),

            const Divider(color: AppColors.border, height: 1),
          ],
        ),
      ),
    );
  }
}
