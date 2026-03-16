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