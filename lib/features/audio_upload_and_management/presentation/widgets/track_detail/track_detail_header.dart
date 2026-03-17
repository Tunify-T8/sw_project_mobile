import 'package:flutter/material.dart';

import '../../../domain/entities/upload_item.dart';

class TrackDetailHeader extends StatelessWidget {
  const TrackDetailHeader({
    super.key,
    required this.item,
    required this.onDismiss,
  });

  final UploadItem item;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(
                    text: item.title,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 2),
                  _Label(text: item.artistDisplay, fontSize: 13),
                  const SizedBox(height: 4),
                  const _BehindTrackTag(),
                ],
              ),
            ),
            Column(
              children: const [
                SizedBox(height: 16),
                Icon(Icons.devices_other, color: Colors.white70, size: 24),
              ],
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.text,
    required this.fontSize,
    this.fontWeight = FontWeight.w400,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

class _BehindTrackTag extends StatelessWidget {
  const _BehindTrackTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.graphic_eq, color: Colors.white70, size: 14),
          SizedBox(width: 4),
          Text(
            'Behind this track',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
