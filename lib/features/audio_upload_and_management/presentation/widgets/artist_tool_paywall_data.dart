// Upload Feature Guide:
// Purpose: Artist tools/paywall widget used around upload quotas and upgrade prompts.
// Used by: upload_flow_controller, artist_home_credits_section, artist_tool_paywall_sheet, and 1 more upload files.
// Concerns: Supporting UI and infrastructure for upload and track management.
import 'package:flutter/material.dart';

enum ArtistToolKind { amplify, uploadTime, replaceFile }

ArtistToolSheetData artistToolSheetData(
  ArtistToolKind kind, {
  int? uploadMinutesRemaining,
  int? uploadMinutesLimit,
}) {
  switch (kind) {
    case ArtistToolKind.amplify:
      return const ArtistToolSheetData(
        eyebrow: 'AMPLIFY',
        title: 'Reach more listeners.',
        body:
            'With Artist Pro, you can get your tracks analyzed and recommended to the right listeners without limits.',
        icon: Icons.bolt_rounded,
        iconColor: Color(0xFFB873FF),
      );
    case ArtistToolKind.uploadTime:
      return ArtistToolSheetData(
        eyebrow: 'UPLOAD',
        title: 'You have limited\nupload time',
        body: '',
        icon: Icons.cloud_upload_outlined,
        iconColor: const Color(0xFF7CB4FF),
        subBody: uploadMinutesRemaining != null && uploadMinutesLimit != null
            ? '$uploadMinutesRemaining/$uploadMinutesLimit mins remaining'
            : null,
      );
    case ArtistToolKind.replaceFile:
      return const ArtistToolSheetData(
        eyebrow: 'REPLACE FILE',
        title: 'Enjoy unlimited file\nreplacements.',
        body: 'With Artist Pro, you can replace files without limits.',
        icon: Icons.swap_horiz_rounded,
        iconColor: Color(0xFF7CB4FF),
      );
  }
}

class ArtistToolSheetData {
  const ArtistToolSheetData({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
    required this.iconColor,
    this.subBody,
  });

  final String eyebrow;
  final String title;
  final String body;
  final String? subBody;
  final IconData icon;
  final Color iconColor;
}
