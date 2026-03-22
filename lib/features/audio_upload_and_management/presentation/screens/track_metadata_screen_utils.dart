// Upload Feature Guide:
// Purpose: Small UI helpers for TrackMetadataScreen text, labels, and save-button decisions.
// Used by: track_metadata_screen
// Concerns: Metadata engine.
import '../providers/track_metadata_state.dart';

String buildTrackMetadataSaveButtonText(
  TrackMetadataState state, {
  required bool isEditMode,
  required bool uploadFinished,
}) {
  final isSaveBusy = state.isSaving || state.isPolling;
  if (isEditMode) return isSaveBusy ? 'Saving...' : 'Save';
  if (isSaveBusy) return state.isPolling ? 'Processing...' : 'Saving...';
  return uploadFinished ? 'Save' : 'Uploading...';
}

String formatTrackMetadataDate(DateTime? date) {
  if (date == null) return 'Select date';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}
