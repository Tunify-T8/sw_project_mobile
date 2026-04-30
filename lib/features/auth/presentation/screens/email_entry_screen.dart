import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/utils/validators.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/shared/ui/widgets/app_back_button.dart';
import 'package:software_project/shared/ui/widgets/app_button.dart';
import 'package:software_project/shared/ui/widgets/app_text_field.dart';
import 'package:software_project/core/utils/url_launcher_util.dart';

/// Email entry sub-screen.
///
/// ── ROUTING LOGIC ────────────────────────────────────────────────────────────
///
/// [mode] == 'create' (user pressed "Create an account" on landing):
///   - Email is NEW      → go to RegisterDetailScreen (happy path)
///   - Email EXISTS      → go to PasswordScreen with "account already exists" notice
///
/// [mode] == 'login' (user pressed "Log in" on landing):
///   - Email EXISTS      → go to PasswordScreen (happy path, no notice)
///   - Email is NEW      → go to RegisterDetailScreen (guide them to create)
///
class EmailEntryScreen extends ConsumerStatefulWidget {
  final String? initialEmail;
  final String mode;

  const EmailEntryScreen({super.key, this.initialEmail, this.mode = 'create'});

  @override
  ConsumerState<EmailEntryScreen> createState() => _EmailEntryScreenState();
}

class _EmailEntryScreenState extends ConsumerState<EmailEntryScreen> {
  late final TextEditingController _emailController;
  bool _isLoading = false;

  // ── Reactive validity ─────────────────────────────────────────────────────
  // Recomputed on every keystroke. Button reads this directly.
  bool get _emailValid => Validators.email(_emailController.text) == null;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    // Rebuild on every keystroke so _emailValid (and therefore the button
    // enabled state) stays in sync without needing a Form/GlobalKey.
    _emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    // Guard is redundant (button is null when !_emailValid) but kept for safety.
    if (!_emailValid) return;
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();

    final exists = await ref
        .read(authControllerProvider.notifier)
        .checkEmail(email);

    if (!mounted) return;
    setState(() => _isLoading = false);

    _navigate(email: email, exists: exists);
  }

  void _navigate({required String email, required bool exists}) {
    final isCreateFlow = widget.mode == 'create';

    if (isCreateFlow) {
      if (exists) {
        Navigator.pushNamed(
          context,
          AppRoutes.password,
          arguments: {'email': email, 'showAccountExistsNotice': true},
        );
      } else {
        Navigator.pushNamed(
          context,
          AppRoutes.registerDetail,
          arguments: {'email': email},
        );
      }
    } else {
      if (exists) {
        Navigator.pushNamed(
          context,
          AppRoutes.password,
          arguments: {'email': email, 'showAccountExistsNotice': false},
        );
      } else {
        Navigator.pushNamed(
          context,
          AppRoutes.registerDetail,
          arguments: {'email': email},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                0,
              ),
              child: AppBackButtonRow(title: 'Sign in or create an account'),
            ),

            const SizedBox(height: AppSpacing.xxl),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key added for test automation (M1-003 assert fix).
                  AppTextField(
                    key: const Key('email_entry_field'),
                    controller: _emailController,
                    hintText: 'Your email address or profile URL',
                    keyboardType: TextInputType.emailAddress,
                    // Keep validator for inline error text feedback.
                    validator: Validators.email,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // onPressed is null (greyed out) until a valid email is typed.
                  // Key added for test automation (M1-004A / M1-003 assert fix).
                  AppButton(
                    key: const Key('email_entry_continue_button'),
                    label: 'Continue',
                    onPressed: _emailValid ? _onContinue : null,
                    style: AppButtonStyle.primary,
                    isLoading: _isLoading,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  GestureDetector(
                    onTap: () => UrlLauncherUtil.open(
                      context,
                      UrlLauncherUtil.helpCenter,
                    ),
                    child: const Text(
                      'Need help?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.link,
                        fontWeight: FontWeight.w400,
                      ),
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
