import 'package:flutter/material.dart';

class PermissionsMetadataSection extends StatelessWidget {
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

  InputDecoration _inputDecoration(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        color: Color(0xFFD0D0D0),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 17),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF464646), width: 1),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF7A7A7A), width: 1),
      ),
      contentPadding: const EdgeInsets.only(top: 6, bottom: 12),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showRegionsField = availabilityType != 'worldwide';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Access settings',
          style: TextStyle(
            color: Color(0xFFD0D0D0),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        _PermissionToggleRow(
          title: 'Enable direct downloads',
          subtitle: 'Allow listeners to download the original audio file.',
          value: allowDownloads,
          onChanged: onAllowDownloadsChanged,
        ),
        _PermissionToggleRow(
          title: 'Offline listening',
          subtitle: 'Allow playback without an internet connection.',
          value: offlineListening,
          onChanged: onOfflineListeningChanged,
        ),
        _PermissionToggleRow(
          title: 'Include in RSS feed',
          subtitle: 'Show this track in your public RSS feed.',
          value: includeInRss,
          onChanged: onIncludeInRssChanged,
        ),
        _PermissionToggleRow(
          title: 'Display embed code',
          subtitle: 'Show public embed code for this track.',
          value: displayEmbedCode,
          onChanged: onDisplayEmbedCodeChanged,
        ),
        _PermissionToggleRow(
          title: 'Enable app playback',
          subtitle: 'Allow playback outside the app shell.',
          value: appPlaybackEnabled,
          onChanged: onAppPlaybackEnabledChanged,
        ),
        const SizedBox(height: 26),
        const Text(
          'Availability',
          style: TextStyle(
            color: Color(0xFFD0D0D0),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        _PermissionRadioRow(
          title: 'Worldwide',
          subtitle: 'Track is available in all regions.',
          selected: availabilityType == 'worldwide',
          onTap: () => onAvailabilityTypeChanged('worldwide'),
        ),
        _PermissionRadioRow(
          title: 'Exclusive regions',
          subtitle: 'Only selected regions can access this track.',
          selected: availabilityType == 'exclusive_regions',
          onTap: () => onAvailabilityTypeChanged('exclusive_regions'),
        ),
        _PermissionRadioRow(
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
            decoration: _inputDecoration(
              'Regions',
              hintText: 'Comma separated ISO codes, e.g. EG, US, DE',
            ),
            onChanged: onAvailabilityRegionsChanged,
          ),
        ],
        const SizedBox(height: 26),
        const Text(
          'Licensing',
          style: TextStyle(
            color: Color(0xFFD0D0D0),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        _PermissionRadioRow(
          title: 'All rights reserved',
          subtitle: 'Other creators are not allowed to reuse your material.',
          selected: licensing == 'all_rights_reserved',
          onTap: () => onLicensingChanged('all_rights_reserved'),
        ),
        _PermissionRadioRow(
          title: 'Creative Commons',
          subtitle: 'Allow limited reuse under a Creative Commons license.',
          selected: licensing == 'creative_commons',
          onTap: () => onLicensingChanged('creative_commons'),
        ),
      ],
    );
  }
}

class _PermissionToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '$title\n$subtitle',
              style: const TextStyle(
                color: Colors.white,
                height: 1.45,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF4A4A4A),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF2F2F2F),
          ),
        ],
      ),
    );
  }
}

class _PermissionRadioRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PermissionRadioRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '$title\n$subtitle',
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.45,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white70, width: 1.5),
                color: selected ? Colors.white : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.black, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
