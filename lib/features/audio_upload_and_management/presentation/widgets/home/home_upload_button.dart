// Upload Feature Guide:
// Purpose: Home surface widget that exposes upload entry points or upload-related discovery sections.
// Used by: artist_home_header
// Concerns: Multi-format support.
import 'package:flutter/material.dart';

class HomeUploadButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback? onTap;

  const HomeUploadButton({
    super.key,
    required this.isBusy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.cloud_upload_outlined, color: Colors.white),
            if (isBusy)
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(Color(0xFFA855F7)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
