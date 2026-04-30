import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../domain/entities/upload_item.dart';
import '../upload_artwork_view.dart';

class TrackDetailBackground extends StatelessWidget {
  const TrackDetailBackground({
    super.key,
    required this.item,
    required this.fallbackColor,
    required this.progress,
    required this.isPlaying,
  });

  final UploadItem item;
  final Color fallbackColor;
  final double progress;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final safeProgress = progress.clamp(0.0, 1.0);
            final isDesktopWidth = MediaQuery.sizeOf(context).width >= 900;
            final extraPanWidth = isDesktopWidth
                ? (constraints.maxWidth * 0.18).clamp(0.0, 220.0).toDouble()
                : constraints.maxWidth * 0.68;
            final artworkWidth = constraints.maxWidth + extraPanWidth;
            final translateX = -(extraPanWidth * safeProgress);

            Widget art =
                item.localArtworkPath != null ||
                    (item.artworkUrl?.trim().isNotEmpty == true)
                ? UploadArtworkView(
                    localPath: item.localArtworkPath,
                    remoteUrl: item.artworkUrl,
                    width: artworkWidth,
                    height: constraints.maxHeight,
                    fit: BoxFit.cover,
                    backgroundColor: fallbackColor,
                    borderRadius: BorderRadius.zero,
                    placeholder: _GradientFallback(color: fallbackColor),
                  )
                : _GradientFallback(color: fallbackColor);

            if (!isPlaying) {
              art = ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: art,
              );
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: artworkWidth,
                  maxWidth: artworkWidth,
                  minHeight: constraints.maxHeight,
                  maxHeight: constraints.maxHeight,
                  child: Transform.translate(
                    offset: Offset(translateX, 0),
                    child: SizedBox(
                      width: artworkWidth,
                      height: constraints.maxHeight,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(
                            alpha: isPlaying ? 0.14 : 0.34,
                          ),
                          BlendMode.darken,
                        ),
                        child: art,
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(
                            alpha: isPlaying ? 0.02 : 0.08,
                          ),
                          Colors.transparent,
                          Colors.black.withValues(
                            alpha: isPlaying ? 0.18 : 0.20,
                          ),
                          Colors.black.withValues(alpha: 0.28),
                        ],
                        stops: const [0, 0.36, 0.68, 1],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
          colors: [
            color,
            color.withValues(alpha: 0.72),
            Colors.black.withValues(alpha: 0.9),
          ],
        ),
      ),
    );
  }
}
