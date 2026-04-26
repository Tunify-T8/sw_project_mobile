import 'package:flutter/material.dart';

class AdaptiveBreakpoints {
  const AdaptiveBreakpoints._();

  static const double medium = 720;
  static const double expanded = 1024;
  static const double wide = 1280;

  static bool isMedium(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= expanded;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wide;

  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= wide) return 1180;
    if (width >= expanded) return 980;
    if (width >= medium) return 760;
    return double.infinity;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= wide) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
    }
    if (width >= expanded) {
      return const EdgeInsets.symmetric(horizontal: 28, vertical: 20);
    }
    if (width >= medium) {
      return const EdgeInsets.symmetric(horizontal: 22, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }
}

class AdaptiveCenter extends StatelessWidget {
  const AdaptiveCenter({
    super.key,
    required this.child,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double? maxWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final resolvedMaxWidth =
        maxWidth ?? AdaptiveBreakpoints.contentMaxWidth(context);
    if (resolvedMaxWidth == double.infinity) return child;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
        child: child,
      ),
    );
  }
}

