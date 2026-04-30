import 'package:flutter/material.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/spacing.dart';

/// Landing screen shown to unauthenticated users.
///
/// Full-screen background image (`assets/images/landing_background.png`)
/// with two pill buttons floating near the bottom of the screen:
///   - "Create an account" — white pill, black text (primary CTA)
///   - "Log in"            — light blue pill (#C6D8F8), black text (secondary)
///
/// No card, no tagline, no logo — just the background art and the two buttons.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _buttonsFade;
  late Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _buttonsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _buttonsSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
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
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // ── Background image — fills entire screen ──────────────────────
          // File: assets/images/landing_background.png
          // Dark abstract art with teal, purple, and orange line shapes.
          Positioned.fill(
            child: Image.asset(
              'assets/images/landing_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF0D0D0D)),
            ),
          ),

          // ── Two buttons, anchored near the bottom ───────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: FadeTransition(
              opacity: _buttonsFade,
              child: SlideTransition(
                position: _buttonsSlide,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    0,
                    AppSpacing.screenHorizontal,
                    35,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Create an account ───────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.signInOrCreate,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Create an account'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Log in ─────────────────────────────────────────
                      // Light blue — original AppColors.buttonSecondary (#C6D8F8)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.signInOrCreate,
                            arguments: {'mode': 'login'},
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC6D8F8),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Log in'),
                        ),
                      ),
                    ],
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
