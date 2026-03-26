// Upload Feature Guide:
// Purpose: Keeps the selected metadata tab state separate per track while editing.
// Used by: track_metadata_screen
// Concerns: Metadata engine.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/metadata/upload_metadata_tab.dart';

class TrackMetadataTabNotifier extends Notifier<UploadMetadataTab> {
  TrackMetadataTabNotifier(this.trackId);

  final String trackId;

  @override
  UploadMetadataTab build() => UploadMetadataTab.trackInfo;

  void setTab(UploadMetadataTab tab) => state = tab;
}

final trackMetadataTabProvider = NotifierProvider.autoDispose
    .family<TrackMetadataTabNotifier, UploadMetadataTab, String>(
      TrackMetadataTabNotifier.new,
    );
