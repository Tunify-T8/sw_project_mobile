import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/upload_item.dart';
import '../../providers/library_uploads_provider.dart';
import '../../screens/edit_track_screen.dart';

Future<void> showTrackDetailMoreSheet(
  BuildContext context,
  WidgetRef ref,
  UploadItem item,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF111111),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: Colors.white),
            title: const Text(
              'Edit track',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => EditTrackScreen(item: item),
                    ),
                  )
                  .then((result) {
                    if (result == true) {
                      ref.read(libraryUploadsProvider.notifier).refresh();
                    }
                  });
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text(
              'Delete track',
              style: TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
            onTap: () async {
              Navigator.pop(context);
              await ref
                  .read(libraryUploadsProvider.notifier)
                  .deleteTrack(item.id);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
