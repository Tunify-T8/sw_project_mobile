import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/utils/validators.dart';
import 'package:software_project/features/auth/data/mock/mock_auth_config.dart';
import 'package:software_project/features/auth/data/mock/mock_auth_service.dart';
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
/// ── TESTING ──────────────────────────────────────────────────────────────────
/// Change [MockAuthConfig.emailScenario] to simulate existing/new email.
class EmailEntryScreen extends ConsumerStatefulWidget {
  /// Email pre-filled from the sign-in screen.
  final String? initialEmail;

  /// The flow that triggered this screen: `'create'` or `'login'`.
  final String mode;

  const EmailEntryScreen({super.key, this.initialEmail, this.mode = 'create'});

  @override
  ConsumerState<EmailEntryScreen> createState() => _EmailEntryScreenState();
}

class _EmailEntryScreenState extends ConsumerState<EmailEntryScreen> {
  late final TextEditingController _emailController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();

    final bool exists;
    if (MockAuthConfig.useMock) {
      exists = await MockAuthService.checkEmail(email);
    } else {
      exists = await ref
          .read(authControllerProvider.notifier)
          .checkEmail(email);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    _navigate(email: email, exists: exists);
  }

  /// Applies the routing rules based on [mode] and [exists].
  void _navigate({required String email, required bool exists}) {
    final isCreateFlow = widget.mode == 'create';

    if (isCreateFlow) {
      // ── "Create an account" flow ──────────────────────────────────────────
      if (exists) {
        // Email already registered — show login screen with the notice banner.
        Navigator.pushNamed(
          context,
          AppRoutes.password,
          arguments: {'email': email, 'showAccountExistsNotice': true},
        );
      } else {
        // New email — proceed with registration.
        Navigator.pushNamed(
          context,
          AppRoutes.registerDetail,
          arguments: {'email': email},
        );
      }
    } else {
      // ── "Log in" flow ─────────────────────────────────────────────────────
      if (exists) {
        // Email registered — go to login. No notice needed.
        Navigator.pushNamed(
          context,
          AppRoutes.password,
          arguments: {'email': email, 'showAccountExistsNotice': false},
        );
      } else {
        // Email not found — guide user to register instead.
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
        child: Form(
          key: _formKey,
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
                    AppTextField(
                      controller: _emailController,
                      hintText: 'Your email address or profile URL',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppButton(
                      label: 'Continue',
                      onPressed: _onContinue,
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
                        style: TextStyle(fontSize: 14, color: AppColors.link),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
