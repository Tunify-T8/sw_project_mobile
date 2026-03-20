import 'package:flutter/material.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/shared/ui/widgets/app_button.dart';

/// Landing screen shown to unauthenticated users.
///
/// Displays a full-screen background image and offers primary actions to
/// create an account or log in.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  /// Replace this with a local asset path when available.
  /// Free abstract line art: https://unsplash.com/s/photos/abstract-lines-dark
  static const String backgroundImageUrl =
      'https://media.istockphoto.com/id/1974844448/vector/modern-abstract-blue-pink-and-purple-gradient-circle-line-on-dark-black-background-design.jpg?s=612x612&w=0&k=20&c=cTWHagIWLjzyYploCH0NtR5LLwhDA3ivVuddLlU_xCI=';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
          ),
        );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background image ─────────────────────────────────────────────
          Positioned.fill(
            child: Image.network(
              backgroundImageUrl,
              fit: BoxFit.fitHeight,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF0D1B2A)),
            ),
          ),

          // ── Bottom content card ──────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: FadeTransition(
              opacity: _cardFade,
              child: SlideTransition(
                position: _cardSlide,
                child: _BottomCard(
                  onCreateAccount: () =>
                      Navigator.pushNamed(context, AppRoutes.signInOrCreate),
                  onLogIn: () => Navigator.pushNamed(
                    context,
                    AppRoutes.signInOrCreate,
                    arguments: {'mode': 'login'},
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom card ───────────────────────────────────────────────────────────────

/// The sliding card at the bottom of the landing screen.
///
/// Contains the app tagline and primary action buttons.
class _BottomCard extends StatelessWidget {
  /// Called when the user taps "Create an account".
  final VoidCallback onCreateAccount;

  /// Called when the user taps "Log in".
  final VoidCallback onLogIn;

  const _BottomCard({required this.onCreateAccount, required this.onLogIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF5B7FA6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.xl,
        AppSpacing.screenHorizontal,
        AppSpacing.screenBottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App logo placeholder.
          const Icon(Icons.graphic_eq, color: Color(0xFF2C3E50), size: 44),

          const SizedBox(height: AppSpacing.base),

          const Text(
            'Where artists & fans connect.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2433),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          AppButton(
            label: 'Create an account',
            onPressed: onCreateAccount,
            style: AppButtonStyle.primary,
          ),

          const SizedBox(height: AppSpacing.md),

          AppButton(
            label: 'Log in',
            onPressed: onLogIn,
            style: AppButtonStyle.secondary,
          ),
        ],
      ),
    );
  }
}
