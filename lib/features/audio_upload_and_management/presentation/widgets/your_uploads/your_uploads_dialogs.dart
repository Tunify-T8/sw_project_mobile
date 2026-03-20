import 'package:flutter/material.dart';

import '../../../domain/entities/upload_item.dart';

Future<bool> confirmYourUploadsDeletion(
  BuildContext context,
  UploadItem item,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text(
            'Delete track?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Delete "${item.title}"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ) ??
      false;
}
