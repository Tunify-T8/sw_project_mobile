import 'dart:ui';

import 'package:flutter/material.dart';

import 'colors.dart';

/// A beautiful frosted-glass loading overlay.
///
/// Use [AppLoadingSpinner.overlay] to stack it on top of existing content,
/// or use [AppLoadingSpinner] as a centered full-area loader.
class AppLoadingSpinner extends StatefulWidget {
  const AppLoadingSpinner({
    super.key,
    this.label,
    this.sublabel,
    this.size = 44,
  });

  /// Optional primary label shown below the spinner.
  final String? label;

  /// Optional secondary label shown below [label].
  final String? sublabel;

  /// Diameter of the spinner ring. Defaults to 44.
  final double size;

  /// Wraps [child] in a Stack and places a blurred loading overlay on top.
  static Widget overlay({
    required Widget child,
    required bool isLoading,
    String? label,
    String? sublabel,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: _FrostedOverlay(label: label, sublabel: sublabel),
          ),
      ],
    );
  }

  @override
  State<AppLoadingSpinner> createState() => _AppLoadingSpinnerState();
}

class _AppLoadingSpinnerState extends State<AppLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _glow,
          builder: (context, child) => Container(
            width: widget.size + 20,
            height: widget.size + 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28 * _glow.value),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: child,
          ),
          child: SizedBox(
            width: widget.size + 20,
            height: widget.size + 20,
            child: Center(
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.8,
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.label!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
        if (widget.sublabel != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.sublabel!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}

/// Blurred frosted-glass overlay with centered spinner.
class _FrostedOverlay extends StatelessWidget {
  const _FrostedOverlay({this.label, this.sublabel});

  final String? label;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: Colors.black.withValues(alpha: 0.55),
          child: Center(
            child: AppLoadingSpinner(label: label, sublabel: sublabel),
          ),
        ),
      ),
    );
  }
}
