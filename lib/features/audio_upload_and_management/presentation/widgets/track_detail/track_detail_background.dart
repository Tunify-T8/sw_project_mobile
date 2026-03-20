import 'package:flutter/material.dart';

import '../../../domain/entities/upload_item.dart';
import '../upload_artwork_view.dart';

class TrackDetailBackground extends StatelessWidget {
  const TrackDetailBackground({
    super.key,
    required this.item,
    required this.fallbackColor,
  });

  final UploadItem item;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: item.localArtworkPath != null || item.artworkUrl != null
          ? ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.15),
                BlendMode.darken,
              ),
              child: UploadArtworkView(
                localPath: item.localArtworkPath,
                remoteUrl: item.artworkUrl,
                width: double.infinity,
                height: double.infinity,
                backgroundColor: fallbackColor,
                borderRadius: BorderRadius.zero,
                placeholder: _GradientFallback(color: fallbackColor),
              ),
            )
          : _GradientFallback(color: fallbackColor),
    );
  }
}

class _GradientFallback extends StatelessWidget {
  const _GradientFallback({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.4)],
        ),
      ),
    );
  }
}
