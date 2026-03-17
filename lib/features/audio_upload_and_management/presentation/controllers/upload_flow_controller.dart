import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/library_uploads_provider.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/upload_dependencies_provider.dart';
import '../providers/upload_provider.dart';
import '../utils/upload_auth_guard.dart';
import '../screens/track_metadata_screen.dart';

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

Future<void> startUploadFlow(BuildContext context, WidgetRef ref) async {
  final canUpload = await ensureUploadAuthenticated(context, ref);
  if (!canUpload) return;

  final userId = ref.read(currentUploadUserIdProvider);
  final track = await ref
      .read(uploadProvider.notifier)
      .pickAudioCreateDraftAndStartUpload(userId);

  if (!context.mounted || track == null) return;

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
