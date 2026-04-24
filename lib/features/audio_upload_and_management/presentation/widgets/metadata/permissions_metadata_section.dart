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
    this.isPro = false,
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
  final bool isPro;

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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const MetadataSectionTitle('Availability'),
            const Spacer(),
            if (!isPro) const _ArtistProBadge(),
          ],
        ),
        const SizedBox(height: 10),
        MetadataPermissionRadioRow(
          title: 'Worldwide',
          subtitle: 'Track is available in all regions.',
          selected: availabilityType == 'worldwide',
          onTap: isPro ? () => onAvailabilityTypeChanged('worldwide') : null,
          disabled: !isPro,
        ),
        MetadataPermissionRadioRow(
          title: 'Exclusive regions',
          subtitle: 'Only selected regions can access this track.',
          selected: availabilityType == 'exclusive_regions',
          onTap: isPro
              ? () => onAvailabilityTypeChanged('exclusive_regions')
              : null,
          disabled: !isPro,
        ),
        MetadataPermissionRadioRow(
          title: 'Blocked regions',
          subtitle: 'Selected regions are blocked.',
          selected: availabilityType == 'excluded_regions',
          onTap: isPro
              ? () => onAvailabilityTypeChanged('excluded_regions')
              : null,
          disabled: !isPro,
        ),
        if (showRegionsField && isPro) ...[
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

class _ArtistProBadge extends StatelessWidget {
  const _ArtistProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB88746), Color(0xFFD9B36A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.workspace_premium, color: Colors.black, size: 14),
          SizedBox(width: 6),
          Text(
            'Unlock with Artist Pro',
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
