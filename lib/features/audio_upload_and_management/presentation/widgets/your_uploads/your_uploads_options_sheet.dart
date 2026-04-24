// Upload Feature Guide:
// Purpose: Uploads library widget used by YourUploadsScreen.
// Used by: your_uploads_screen
// Concerns: Multi-format support; Track visibility.
//
// This file is now a thin forwarder onto the shared track options sheet used
// by Artist Home, so Your Uploads and Artist Home stay visually/behaviourally
// in sync while still threading the upload-specific edit/delete callbacks.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/network/api_endpoints.dart';

import '../../../../playback_streaming_engine/presentation/widgets/track_options_sheet.dart';
import '../../../domain/entities/upload_item.dart';

Future<void> showYourUploadsOptionsSheet(
  BuildContext context, {
  required WidgetRef ref,
  required UploadItem item,
  required VoidCallback onEditTap,
  required VoidCallback onDeleteTap,
}) {
  return showTrackOptionsSheet(
    context,
    ref: ref,
    info: TrackOptionInfo.fromUploadItem(item),
    onEditTap: onEditTap,
    onDeleteTap: onDeleteTap,
  );
}
