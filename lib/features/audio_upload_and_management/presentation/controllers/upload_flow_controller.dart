// Upload Feature Guide:
// Purpose: Reusable flow helpers that load upload data, start the upload flow, and show quota/paywall prompts.
// Used by: artist_home_screen, home_screen, upload_entry_screen, and 1 more upload files.
// Concerns: Multi-format support.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/library_uploads_provider.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/upload_dependencies_provider.dart';
import '../providers/upload_provider.dart';
import '../utils/upload_auth_guard.dart';
import '../screens/track_metadata_screen.dart';
import '../widgets/artist_tool_paywall_data.dart';
import '../widgets/artist_tool_paywall_sheet.dart';

Future<void> loadArtistDashboardData(WidgetRef ref) async {
  final userId = ref.read(currentUploadUserIdProvider);
  await Future.wait([
    ref.read(uploadProvider.notifier).loadQuota(userId),
    ref.read(libraryUploadsProvider.notifier).load(),
  ]);
}

Future<void> loadUploadsLibraryData(WidgetRef ref) {
  return ref.read(libraryUploadsProvider.notifier).load();
}

Future<bool> maybeShowUploadQuotaLimitPrompt(
  BuildContext context,
  WidgetRef ref,
) async {
  final uploadState = ref.read(uploadProvider);
  final blockedMinutes = uploadState.blockedUploadMinutes;
  final quota = uploadState.quota;

  if (blockedMinutes == null) {
    return false;
  }

  final remainingMinutes = quota?.uploadMinutesRemaining ?? 0;

  final shouldUpgrade = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF1C1C1C),
      title: const Text(
        'Upload limit reached',
        style: TextStyle(color: Colors.white),
      ),
      content: Text(
        'This file needs $blockedMinutes minute${blockedMinutes == 1 ? '' : 's'}, '
        'but you only have $remainingMinutes minute${remainingMinutes == 1 ? '' : 's'} left.',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF5500),
          ),
          child: const Text('Upgrade to Artist Pro'),
        ),
      ],
    ),
  );

  ref.read(uploadProvider.notifier).clearQuotaLimitPrompt();

  if (shouldUpgrade == true && context.mounted) {
    await showArtistToolPaywallSheet(
      context: context,
      kind: ArtistToolKind.uploadTime,
      uploadMinutesRemaining: quota?.uploadMinutesRemaining,
      uploadMinutesLimit: quota?.uploadMinutesLimit,
    );
  }

  return true;
}

Future<void> startUploadFlow(BuildContext context, WidgetRef ref) async {
  final canUpload = await ensureUploadAuthenticated(context, ref);
  if (!canUpload) return;

  final userId = ref.read(currentUploadUserIdProvider);
  final track = await ref
      .read(uploadProvider.notifier)
      .pickAudioCreateDraftAndStartUpload(userId);

  if (!context.mounted) return;

  if (track == null) {
    await maybeShowUploadQuotaLimitPrompt(context, ref);
    return;
  }

  ref
      .read(trackMetadataProvider.notifier)
      .prepareForNewUpload(
        ref.read(uploadProvider).selectedAudio?.name ?? 'Audio file',
      );

  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => TrackMetadataScreen(
        trackId: track.trackId,
        fileName: ref.read(uploadProvider).selectedAudio?.name ?? 'Audio file',
      ),
    ),
  );

  if (result == true && context.mounted) {
    await ref.read(libraryUploadsProvider.notifier).refresh();
  }
}
