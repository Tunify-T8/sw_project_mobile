// Upload Feature Guide:
// Purpose: Metadata form widget used inside TrackMetadataScreen and TrackMetadataBody.
// Used by: track_metadata_body
// Concerns: Metadata engine.
import 'package:flutter/material.dart';

import 'metadata_input_decoration.dart';
import 'metadata_permission_rows.dart';
import 'metadata_section_title.dart';

class PermissionsMetadataSection extends StatelessWidget {
  const PermissionsMetadataSection({
    super.key,
    required this.allowDownloads,
    required this.offlineListening,
    required this.includeInRss,
    required this.displayEmbedCode,
    required this.appPlaybackEnabled,
    required this.availabilityType,
    required this.availabilityRegionsController,
    required this.licensing,
    required this.onAllowDownloadsChanged,
    required this.onOfflineListeningChanged,
    required this.onIncludeInRssChanged,
    required this.onDisplayEmbedCodeChanged,
    required this.onAppPlaybackEnabledChanged,
    required this.onAvailabilityTypeChanged,
    required this.onAvailabilityRegionsChanged,
    required this.onLicensingChanged,
  });

  final bool allowDownloads;
  final bool offlineListening;
  final bool includeInRss;
  final bool displayEmbedCode;
  final bool appPlaybackEnabled;
  final String availabilityType;
  final TextEditingController availabilityRegionsController;
  final String licensing;
  final ValueChanged<bool> onAllowDownloadsChanged;
  final ValueChanged<bool> onOfflineListeningChanged;
  final ValueChanged<bool> onIncludeInRssChanged;
  final ValueChanged<bool> onDisplayEmbedCodeChanged;
  final ValueChanged<bool> onAppPlaybackEnabledChanged;
  final ValueChanged<String> onAvailabilityTypeChanged;
  final ValueChanged<String> onAvailabilityRegionsChanged;
  final ValueChanged<String> onLicensingChanged;

  @override
  Widget build(BuildContext context) {
    final showRegionsField = availabilityType != 'worldwide';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MetadataSectionTitle('Access settings'),
        const SizedBox(height: 10),
        MetadataPermissionToggleRow(
          title: 'Enable direct downloads',
          subtitle: 'Allow listeners to download the original audio file.',
          value: allowDownloads,
          onChanged: onAllowDownloadsChanged,
        ),
        MetadataPermissionToggleRow(
          title: 'Offline listening',
          subtitle: 'Allow playback without an internet connection.',
          value: offlineListening,
          onChanged: onOfflineListeningChanged,
        ),
        MetadataPermissionToggleRow(
          title: 'Include in RSS feed',
          subtitle: 'Show this track in your public RSS feed.',
          value: includeInRss,
          onChanged: onIncludeInRssChanged,
        ),
        MetadataPermissionToggleRow(
          title: 'Display embed code',
          subtitle: 'Show public embed code for this track.',
          value: displayEmbedCode,
          onChanged: onDisplayEmbedCodeChanged,
        ),
        MetadataPermissionToggleRow(
          title: 'Enable app playback',
          subtitle: 'Allow playback outside the app shell.',
          value: appPlaybackEnabled,
          onChanged: onAppPlaybackEnabledChanged,
        ),
        const SizedBox(height: 26),
        const MetadataSectionTitle('Availability'),
        const SizedBox(height: 10),
        MetadataPermissionRadioRow(
          title: 'Worldwide',
          subtitle: 'Track is available in all regions.',
          selected: availabilityType == 'worldwide',
          onTap: () => onAvailabilityTypeChanged('worldwide'),
        ),
        MetadataPermissionRadioRow(
          title: 'Exclusive regions',
          subtitle: 'Only selected regions can access this track.',
          selected: availabilityType == 'exclusive_regions',
          onTap: () => onAvailabilityTypeChanged('exclusive_regions'),
        ),
        MetadataPermissionRadioRow(
          title: 'Blocked regions',
          subtitle: 'Selected regions are blocked.',
          selected: availabilityType == 'excluded_regions',
          onTap: () => onAvailabilityTypeChanged('excluded_regions'),
        ),
        if (showRegionsField) ...[
          const SizedBox(height: 12),
          TextField(
            controller: availabilityRegionsController,
            style: const TextStyle(color: Colors.white, fontSize: 17),
            decoration: buildMetadataInputDecoration(
              'Regions',
              hintText: 'Comma separated ISO codes, e.g. EG, US, DE',
            ),
            onChanged: onAvailabilityRegionsChanged,
          ),
        ],
        const SizedBox(height: 26),
        const MetadataSectionTitle('Licensing'),
        const SizedBox(height: 10),
        MetadataPermissionRadioRow(
          title: 'All rights reserved',
          subtitle: 'Other creators are not allowed to reuse your material.',
          selected: licensing == 'all_rights_reserved',
          onTap: () => onLicensingChanged('all_rights_reserved'),
        ),
        MetadataPermissionRadioRow(
          title: 'Creative Commons',
          subtitle: 'Allow limited reuse under a Creative Commons license.',
          selected: licensing == 'creative_commons',
          onTap: () => onLicensingChanged('creative_commons'),
        ),
      ],
    );
  }
}
