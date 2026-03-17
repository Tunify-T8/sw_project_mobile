import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class UploadsSearchHeader extends StatelessWidget {
  const UploadsSearchHeader({
    super.key,
    required this.controller,
    required this.trackCount,
    required this.onChanged,
    required this.onBackTap,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final int trackCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: topInset + 210,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _UploadsHeaderPainter()),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, topInset + 10, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CircleHeaderButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: onBackTap,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                onChanged: onChanged,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                ),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search $trackCount tracks',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 19,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _CircleHeaderButton(
                      icon: Icons.tune_rounded,
                      onTap: onFilterTap,
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Your uploads',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 33,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleHeaderButton extends StatelessWidget {
  const _CircleHeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _UploadsHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glowRect = Rect.fromCircle(
      center: Offset(size.width * 0.76, size.height * 0.26),
      radius: size.width * 0.32,
    );

    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        glowRect.center,
        glowRect.width * 0.55,
        [const Color(0xAA9B4DFF), const Color(0x449B4DFF), Colors.transparent],
        const [0, 0.45, 1],
      );

    canvas.drawCircle(glowRect.center, glowRect.width * 0.55, glowPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF8F45FF).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 8; i++) {
      final left = -26 + (i * 42.0);
      final top = -16 + (i * 12.0);
      final width = size.width * 0.82;
      final height = size.height * 0.95;

      canvas.drawRect(Rect.fromLTWH(left, top, width, height), linePaint);
    }

    final accentPaint = Paint()
      ..color = const Color(0xFFFF9E2C)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.12),
      4,
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
