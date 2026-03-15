import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/features/auth/presentation/widgets/auth_form_fields.dart';

/// Email verification screen shown after registration.
///
/// The user enters the 6-character uppercase token sent to their inbox.
/// On success, tokens are stored and the user is navigated to home.
/// Also shown when an unverified user tries to log in.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final List<TextEditingController> _digitControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isResending = false;

  @override
  void dispose() {
    for (final c in _digitControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _token =>
      _digitControllers.map((c) => c.text.toUpperCase()).join();

  Future<void> _onVerify() async {
    if (_token.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the full 6-character code.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .verifyEmail(widget.email, _token);

    if (!mounted) return;

    ref
        .read(authControllerProvider)
        .whenOrNull(
          data: (user) {
            if (user != null) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            }
          },
          error: (e, _) {
            final message = e is Failure
                ? e.message
                : 'Verification failed. Try again.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
              ),
            );
          },
        );
  }

  Future<void> _onResend() async {
    setState(() => _isResending = true);
    await ref
        .read(authControllerProvider.notifier)
        .resendVerification(widget.email);
    if (!mounted) return;
    setState(() => _isResending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification email resent. Please check your inbox.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.onBackground,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.base),
              Text('Verify your email', style: AppTextStyles.screenTitle),
              const SizedBox(height: AppSpacing.md),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMuted,
                  children: [
                    const TextSpan(text: 'We sent a 6-character code to\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Six individual character boxes.
              // Each box is a [TokenDigitField] that handles auto-advance
              // and backspace navigation between boxes.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (i) => TokenDigitField(
                    controller: _digitControllers[i],
                    focusNode: _focusNodes[i],
                    onChanged: (value) {
                      if (value.isNotEmpty && i < 5) {
                        _focusNodes[i + 1].requestFocus();
                      }
                      setState(() {});
                    },
                    onBackspace: () {
                      if (_digitControllers[i].text.isEmpty && i > 0) {
                        _focusNodes[i - 1].requestFocus();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppButton(
                label: 'Verify',
                // Disabled until all 6 boxes are filled.
                onPressed: _token.length == 6 ? _onVerify : null,
                style: AppButtonStyle.primary,
                isLoading: isLoading,
                borderRadius: 4,
              ),
              const SizedBox(height: AppSpacing.lg),

              Center(
                child: _isResending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onBackgroundMuted,
                        ),
                      )
                    : AuthLink(label: 'Resend code', onTap: _onResend),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
