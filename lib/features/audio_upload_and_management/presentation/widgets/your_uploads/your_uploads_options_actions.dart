// Upload Feature Guide:
// Purpose: Uploads library widget used by YourUploadsScreen.
// Used by: your_uploads_options_sheet
// Concerns: Multi-format support; Track visibility.
import 'package:flutter/material.dart';

class YourUploadsShareButton extends StatelessWidget {
  const YourUploadsShareButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? Colors.white, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class SocialShareButton extends StatelessWidget {
  const SocialShareButton({
    super.key,
    required this.faIcon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  final IconData faIcon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _BrandShareIcon(label: label, color: iconColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandShareIcon extends StatelessWidget {
  const _BrandShareIcon({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final normalized = label.toLowerCase();
    return switch (normalized) {
      'whatsapp' => Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, color: color, size: 26),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(Icons.call_rounded, color: color, size: 12),
            ),
          ],
        ),
      'stories' => CustomPaint(
          size: const Size.square(25),
          painter: _InstagramGlyphPainter(color),
        ),
      'snapchat' => CustomPaint(
          size: const Size.square(25),
          painter: _SnapchatGlyphPainter(color),
        ),
      'facebook' => Text(
          'f',
          style: TextStyle(
            color: color,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 0.95,
          ),
        ),
      'x' => Text(
          'X',
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      'messenger' => Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.chat_bubble_rounded, color: color, size: 26),
            const Icon(Icons.bolt_rounded, color: Color(0xFF2A2A2A), size: 15),
          ],
        ),
      _ => Icon(Icons.public_rounded, color: color, size: 22),
    };
  }
}

class _InstagramGlyphPainter extends CustomPainter {
  const _InstagramGlyphPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(3), const Radius.circular(6)),
      stroke,
    );
    canvas.drawCircle(size.center(Offset.zero), size.width * 0.18, stroke);
    canvas.drawCircle(
      Offset(size.width * 0.70, size.height * 0.30),
      1.6,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _InstagramGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _SnapchatGlyphPainter extends CustomPainter {
  const _SnapchatGlyphPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.50, h * 0.14)
      ..cubicTo(w * 0.28, h * 0.14, w * 0.26, h * 0.34, w * 0.27, h * 0.50)
      ..cubicTo(w * 0.24, h * 0.58, w * 0.17, h * 0.61, w * 0.11, h * 0.63)
      ..cubicTo(w * 0.20, h * 0.69, w * 0.24, h * 0.70, w * 0.27, h * 0.79)
      ..cubicTo(w * 0.35, h * 0.76, w * 0.40, h * 0.86, w * 0.50, h * 0.86)
      ..cubicTo(w * 0.60, h * 0.86, w * 0.65, h * 0.76, w * 0.73, h * 0.79)
      ..cubicTo(w * 0.76, h * 0.70, w * 0.80, h * 0.69, w * 0.89, h * 0.63)
      ..cubicTo(w * 0.83, h * 0.61, w * 0.76, h * 0.58, w * 0.73, h * 0.50)
      ..cubicTo(w * 0.74, h * 0.34, w * 0.72, h * 0.14, w * 0.50, h * 0.14);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SnapchatGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}

class YourUploadsOptionRow extends StatelessWidget {
  const YourUploadsOptionRow({
    super.key,
    required this.icon,
    required this.label,
    this.color = Colors.white,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap ?? () => Navigator.pop(context),
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: TextStyle(color: color, fontSize: 16)),
      dense: true,
    );
  }
}
