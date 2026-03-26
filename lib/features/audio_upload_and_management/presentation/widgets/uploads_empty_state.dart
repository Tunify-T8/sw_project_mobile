// Upload Feature Guide:
// Purpose: Presentational helper widget for the uploads library search or empty-state surface.
// Used by: Referenced by nearby upload feature files.
// Concerns: Multi-format support.
import 'package:flutter/material.dart';

class UploadsEmptyState extends StatelessWidget {
  const UploadsEmptyState({super.key, required this.onUploadTap});

  final VoidCallback onUploadTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No uploads yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Your uploads will show up here.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 19,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Upload a track',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            InkWell(
              onTap: onUploadTap,
              borderRadius: BorderRadius.circular(28),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
