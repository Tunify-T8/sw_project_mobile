import 'package:flutter/material.dart';

import '../../../domain/entities/upload_item.dart';

class TrackDetailHeader extends StatelessWidget {
  const TrackDetailHeader({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.onArtistTap,
    required this.onTrackInfoTap,
  });

  final UploadItem item;
  final VoidCallback onDismiss;
  final VoidCallback onArtistTap;
  final VoidCallback onTrackInfoTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BlackTag(
                    text: item.title,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    onTap: onTrackInfoTap,
                  ),
                  const SizedBox(height: 4),
                  _BlackTag(
                    key: const Key('track_detail_artist_tap'),
                    text: item.artistDisplay,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    onTap: onArtistTap,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTrackInfoTap,
                    child: Container(
                      color: Colors.black.withOpacity(0.82),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.graphic_eq, color: Colors.white70, size: 17),
                          SizedBox(width: 8),
                          Text(
                            'Behind this track',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                _CircleAction(
                  size: 58,
                  backgroundColor: Colors.black,
                  icon: Icons.keyboard_arrow_down_rounded,
                  iconSize: 34,
                  onTap: onDismiss,
                ),
                const SizedBox(height: 28),
                const _SideIcon(icon: Icons.person_add_alt_1_outlined),
                const SizedBox(height: 28),
                const _SideIcon(icon: Icons.devices_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlackTag extends StatelessWidget {
  const _BlackTag({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.onTap,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: Colors.black.withOpacity(0.82),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.size,
    required this.backgroundColor,
    required this.icon,
    required this.iconSize,
    required this.onTap,
  });

  final double size;
  final Color backgroundColor;
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}

class _SideIcon extends StatelessWidget {
  const _SideIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Colors.white70, size: 34);
  }
}
