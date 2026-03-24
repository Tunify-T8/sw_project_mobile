import 'package:flutter/material.dart';

import '../../domain/entities/playback_status.dart';

/// Shown inside the player when a track is blocked for the current user.
class BlockedTrackView extends StatelessWidget {
  const BlockedTrackView({super.key, this.blockedReason});

  final BlockedReason? blockedReason;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _icon,
              color: Colors.white38,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              _title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (blockedReason == BlockedReason.tierRestricted) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Navigate to subscription screen — handled by router
                },
                child: const Text('Upgrade to Pro'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    switch (blockedReason) {
      case BlockedReason.regionRestricted:
        return Icons.public_off;
      case BlockedReason.tierRestricted:
        return Icons.lock;
      case BlockedReason.scheduledRelease:
        return Icons.schedule;
      case BlockedReason.deleted:
        return Icons.delete_outline;
      case BlockedReason.privateNoToken:
        return Icons.visibility_off;
      case BlockedReason.copyright:
        return Icons.copyright;
      default:
        return Icons.block;
    }
  }

  String get _title {
    switch (blockedReason) {
      case BlockedReason.regionRestricted:
        return 'Not Available in Your Region';
      case BlockedReason.tierRestricted:
        return 'Pro Subscription Required';
      case BlockedReason.scheduledRelease:
        return 'Not Released Yet';
      case BlockedReason.deleted:
        return 'Track Unavailable';
      case BlockedReason.privateNoToken:
        return 'Private Track';
      case BlockedReason.copyright:
        return 'Copyright Restricted';
      default:
        return 'Track Unavailable';
    }
  }

  String get _subtitle {
    switch (blockedReason) {
      case BlockedReason.regionRestricted:
        return 'This track is not available in your country.';
      case BlockedReason.tierRestricted:
        return 'Upgrade to Pro to listen to this track.';
      case BlockedReason.scheduledRelease:
        return 'This track has not been released yet. Check back later.';
      case BlockedReason.deleted:
        return 'This track has been removed by the artist.';
      case BlockedReason.privateNoToken:
        return 'You need a private link to access this track.';
      case BlockedReason.copyright:
        return 'This track is restricted due to a copyright claim.';
      default:
        return 'This track cannot be played right now.';
    }
  }
}
