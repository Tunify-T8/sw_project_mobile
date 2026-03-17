import 'package:flutter/material.dart';

class YourUploadsEmptyState extends StatelessWidget {
  const YourUploadsEmptyState({super.key, required this.onUpload});

  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'No uploads yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your uploads will show up here.',
            style: TextStyle(color: Colors.white54, fontSize: 15),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onUpload,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload a track',
                  style: TextStyle(color: Colors.white54, fontSize: 15),
                ),
                SizedBox(height: 8),
                Icon(
                  Icons.cloud_upload_outlined,
                  color: Colors.white54,
                  size: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
