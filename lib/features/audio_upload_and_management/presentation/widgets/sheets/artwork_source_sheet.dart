import 'package:flutter/material.dart';

Future<void> showArtworkSourceSheet(
  BuildContext context, {
  required VoidCallback onPickFromGallery,
  required VoidCallback onPickFromCamera,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1C1C1C),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Colors.white,
              ),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                onPickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
              ),
              title: const Text(
                'Take photo',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                onPickFromCamera();
              },
            ),
          ],
        ),
      );
    },
  );
}
