import 'package:flutter/material.dart';
import 'package:software_project/core/design_system/colors.dart';

/// Splash screen shown immediately after app startup.
///
/// Displays a brief animation then navigates to [destination] (provided by
/// [AuthGate] via route arguments).
///
/// The logo is loaded from `assets/images/soundcloud_logo.png`.
/// The glow animation (fade-in → pulse dim-to-bright-to-dim) is unchanged.
class SplashScreen extends StatefulWidget {
  final String destination;
  const SplashScreen({super.key, required this.destination});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Logo fades in during the first 25 % of the animation.
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    // Glow pulses dim → bright → dim, matching the real SoundCloud splash.
    _glow =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.1, end: 0.25), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 0.25, end: 0.1), weight: 50),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 1.0, curve: Curves.easeInOut),
          ),
        );

    _controller.forward();
    _navigateAfterAnimation();
  }

  Future<void> _navigateAfterAnimation() async {
    // Wait for the full animation + a small hold so the logo is visible.
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, widget.destination);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // #0D0D0D — pure dark
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => FadeTransition(
            opacity: _fadeIn,
            child: _LogoWithGlow(glowOpacity: _glow.value),
          ),
        ),
      ),
    );
  }
}

// ── Logo with animated glow ───────────────────────────────────────────────────

/// Renders the logo image with a pulsing white glow halo behind it.
class _LogoWithGlow extends StatelessWidget {
  /// Current glow intensity — driven by the parent [AnimationController].
  final double glowOpacity;

  const _LogoWithGlow({required this.glowOpacity});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Soft glow halo ────────────────────────────────────────────────
        // Sized generously so the blur bleeds well beyond the logo edges.
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: glowOpacity),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
        ),

        // ── Logo image ────────────────────────────────────────────────────
        // Place the file at: assets/images/soundcloud_logo.png
        // and register it in pubspec.yaml under flutter › assets.
        Image.asset(
          'assets/images/soundcloud_logo.png',
          width: 250,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.graphic_eq, color: Colors.white, size: 120);
          },
        ),
      ],
    );
  }
}
