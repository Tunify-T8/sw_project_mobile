import 'package:flutter/material.dart';

class UploadProgressPill extends StatelessWidget {
  const UploadProgressPill({
    super.key,
    required this.isPreparingUpload,
    required this.isUploading,
    required this.progress,
    required this.onCancel,
  });

  final bool isPreparingUpload;
  final bool isUploading;
  final double progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final double safeProgress = progress.clamp(0.0, 1.0);
    final int percent = (safeProgress * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;

        // This is the SAME idea you wanted:
        // the green pill itself grows as upload progresses.
        // We are NOT drawing a fixed full-width progress bar behind it.
        final double widthFactor = isPreparingUpload ? 0.15 : safeProgress;

        // Keep a minimum width so the pill doesn't become visually broken.
        final double pillWidth = (maxWidth * widthFactor).clamp(48.0, maxWidth);

        final _PillContent content = _buildContent(
          pillWidth: pillWidth,
          isPreparingUpload: isPreparingUpload,
          isUploading: isUploading,
          percent: percent,
        );

        return Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            width: pillWidth,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF18C06B),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pillWidth < 72 ? 8 : 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: content.label.isEmpty
                          ? const SizedBox.shrink()
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                content.label,
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: content.fontSize,
                                  letterSpacing: content.letterSpacing,
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (content.showClose) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onCancel,
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _PillContent _buildContent({
    required double pillWidth,
    required bool isPreparingUpload,
    required bool isUploading,
    required int percent,
  }) {
    // PREPARING state
    if (isPreparingUpload) {
      if (pillWidth >= 150) {
        return const _PillContent(
          label: 'PREPARING',
          showClose: true,
          fontSize: 12,
          letterSpacing: 0.8,
        );
      }

      if (pillWidth >= 92) {
        return const _PillContent(
          label: 'PREP',
          showClose: false,
          fontSize: 11,
          letterSpacing: 0.6,
        );
      }

      return const _PillContent.empty();
    }
    

    // UPLOADING state
    if (isUploading) {
      // Very wide: full text + %
      if (pillWidth >= 150) {
        return _PillContent(
          label: 'UPLOADING $percent%',
          showClose: true,
          fontSize: 11,
          letterSpacing: 0.6,
        );
      }

      // Medium width: shorter text + %
      if (pillWidth >= 105) {
        return _PillContent(
          label: 'UPLOAD $percent%',
          showClose: false,
          fontSize: 11,
          letterSpacing: 0.4,
        );
      }

      // Smaller width: very short text + %
      if (pillWidth >= 78) {
        return _PillContent(
          label: 'UP $percent%',
          showClose: false,
          fontSize: 11,
          letterSpacing: 0.2,
        );
      }

      // Tiny width: show just the percentage early
      if (pillWidth >= 52) {
        return _PillContent(
          label: '$percent%',
          showClose: false,
          fontSize: 11,
          letterSpacing: 0,
        );
      }

      return const _PillContent.empty();
    }

    // Finished/fallback
    if (pillWidth >= 120) {
      return const _PillContent(
        label: 'DONE',
        showClose: false,
        fontSize: 11,
        letterSpacing: 0.4,
      );
    }

    if (pillWidth >= 52) {
      return const _PillContent(
        label: '100%',
        showClose: false,
        fontSize: 11,
        letterSpacing: 0,
      );
    }

    return const _PillContent.empty();
  }
}

class _PillContent {
  const _PillContent({
    required this.label,
    required this.showClose,
    required this.fontSize,
    required this.letterSpacing,
  });

  const _PillContent.empty()
      : label = '',
        showClose = false,
        fontSize = 11,
        letterSpacing = 0;

  final String label;
  final bool showClose;
  final double fontSize;
  final double letterSpacing;
}