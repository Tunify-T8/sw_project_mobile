import 'package:flutter/material.dart';

Future<bool> confirmTrackMetadataCancel(BuildContext context) async {
  final shouldCancel = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF1C1C1E),
      title: const Text(
        'Cancel upload?',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'If you cancel now, this upload will be discarded. Continue editing instead?',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text(
            'Continue editing',
            style: TextStyle(color: Colors.white54),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text(
            'Cancel upload',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );

  return shouldCancel ?? false;
}
