// Upload Feature Guide:
// Purpose: Thin screen wrapper that opens the metadata editor in edit mode for an existing uploaded track.
// Used by: your_uploads_screen, track_detail_more_sheet
// Concerns: Track visibility.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_item.dart';
import '../providers/track_detail_item_provider.dart';
import 'track_metadata_screen.dart';

class EditTrackScreen extends ConsumerWidget {
  const EditTrackScreen({super.key, required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedItemAsync = ref.watch(trackDetailItemProvider(item));

    return resolvedItemAsync.when(
      data: (resolvedItem) => TrackMetadataScreen.edit(item: resolvedItem),
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF111111),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (_, __) => TrackMetadataScreen.edit(item: item),
    );
  }
}
