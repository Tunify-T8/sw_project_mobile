// Upload Feature Guide:
// Purpose: Uploads library widget used by YourUploadsScreen.
// Used by: your_uploads_screen
// Concerns: Multi-format support; Track visibility.
import 'package:flutter/material.dart';

class YourUploadsEmptyState extends StatelessWidget {
  const YourUploadsEmptyState({super.key, required this.onUpload});

  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No uploads yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Your uploads will show up here.',
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.45),
          ),
          const SizedBox(height: 34),
          GestureDetector(
            onTap: onUpload,
            behavior: HitTestBehavior.opaque,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload a track',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Icon(
                  Icons.cloud_upload_outlined,
                  color: Colors.white70,
                  size: 34,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
