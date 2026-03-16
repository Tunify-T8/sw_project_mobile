import 'package:flutter/material.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';

/// Splash screen shown immediately after app startup.
///
/// Displays a brief animation and then navigates to [destination], which is
/// passed via route arguments (typically by [AuthGate]).
///
/// If no destination is provided (e.g. in unit tests), it falls back to
/// [AppRoutes.landing].
///
/// The logo is currently rendered using [CustomPaint]; replace it with
/// an asset image when an official logo file is available.
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
      duration: const Duration(milliseconds: 1800),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    // Glow pulses: dim → bright → dim, matching the real SoundCloud splash.
    _glow =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.15, end: 0.55), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 0.55, end: 0.15), weight: 50),
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

    // Navigate to the destination provided by the caller.
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
      backgroundColor: AppColors.background,
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

// ── Logo with glow ────────────────────────────────────────────────────────────

class _LogoWithGlow extends StatelessWidget {
  final double glowOpacity;
  const _LogoWithGlow({required this.glowOpacity});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Soft white glow halo behind the logo
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: glowOpacity * 0.3),
                blurRadius: 80,
                spreadRadius: 20,
              ),
            ],
          ),
        ),

        // White SoundCloud waveform + cloud logo (CustomPaint replica).
        // Swap this widget for Image.asset once you have the PNG:
        //   Image.asset('assets/images/soundcloud_logo_white.png', width: 120)
        const _SoundCloudWavemark(),
      ],
    );
  }
}

/// Paints the SoundCloud waveform-and-cloud mark in white.
///
/// Replace with an Image.asset once the official PNG/SVG is added to assets/.
class _SoundCloudWavemark extends StatelessWidget {
  const _SoundCloudWavemark();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(120, 72), painter: _WavemarkPainter());
  }
}

class _WavemarkPainter extends CustomPainter {
  const _WavemarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Bar heights as fractions — matches the real SoundCloud waveform shape.
    const heights = [0.25, 0.4, 0.62, 0.45, 0.88, 0.62, 1.0, 0.78, 0.52, 0.68];
    const barWidth = 8.0;
    const gap = 4.5;

    for (int i = 0; i < heights.length; i++) {
      final barH = size.height * heights[i];
      final x = i * (barWidth + gap);
      final top = size.height - barH;
      canvas.drawRRect(
        RRect.fromLTRBR(
          x,
          top,
          x + barWidth,
          size.height,
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavemarkPainter old) => false;
}
