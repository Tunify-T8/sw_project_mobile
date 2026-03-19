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
    final label = isPreparingUpload
        ? 'PREPARING TO UPLOAD'
        : isUploading
        ? 'UPLOADING ${(progress * 100).toStringAsFixed(0)}%'
        : 'UPLOADING 100%';

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF0C5F3B),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: isPreparingUpload ? 0.15 : progress.clamp(0, 1),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF11A85B),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onCancel,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
