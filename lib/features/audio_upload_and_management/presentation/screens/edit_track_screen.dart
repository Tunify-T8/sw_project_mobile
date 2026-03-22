// Upload Feature Guide:
// Purpose: Thin screen wrapper that opens the metadata editor in edit mode for an existing uploaded track.
// Used by: your_uploads_screen, track_detail_more_sheet
// Concerns: Track visibility.
import 'package:flutter/material.dart';

import '../../domain/entities/upload_item.dart';
import 'track_metadata_screen.dart';

class EditTrackScreen extends StatelessWidget {
  const EditTrackScreen({super.key, required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context) {
    return TrackMetadataScreen.edit(item: item);
  }
}
