// Upload Feature Guide:
// Purpose: Uploads library widget used by YourUploadsScreen.
// Used by: your_uploads_screen
// Concerns: Multi-format support; Track visibility.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/upload_item.dart';
import '../../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../providers/track_detail_item_provider.dart';
import '../upload_artwork_view.dart';
import 'your_uploads_options_actions.dart';

part 'your_uploads_options_sheet_body.dart';

Future<void> showYourUploadsOptionsSheet(
  BuildContext context, {
  required UploadItem item,
  required VoidCallback onEditTap,
  required VoidCallback onDeleteTap,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _TrackOptionsSheet(
      item: item,
      onEditTap: onEditTap,
      onDeleteTap: onDeleteTap,
    ),
  );
}
