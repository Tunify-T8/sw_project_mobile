import 'playback_status.dart';

/// Describes whether & how the authenticated user can play this track.
class PlayabilityInfo {
  const PlayabilityInfo({
    required this.status,
    required this.regionBlocked,
    required this.tierBlocked,
    required this.requiresSubscription,
    this.blockedReason,
  });

  final PlaybackStatus status;
  final bool regionBlocked;
  final bool tierBlocked;
  final bool requiresSubscription;
  final BlockedReason? blockedReason;

  bool get canPlayFull => status == PlaybackStatus.playable;
  bool get isPreviewOnly => status == PlaybackStatus.preview;
  bool get isBlocked => status == PlaybackStatus.blocked;
}
