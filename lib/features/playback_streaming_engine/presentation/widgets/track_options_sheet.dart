import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_upload_and_management/data/services/global_track_store.dart';
import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../audio_upload_and_management/presentation/screens/track_detail_screen.dart';
import '../../../audio_upload_and_management/presentation/widgets/upload_artwork_view.dart';
import '../../../audio_upload_and_management/presentation/widgets/your_uploads/your_uploads_options_actions.dart';
import '../../domain/entities/history_track.dart';
import '../providers/listening_history_provider.dart';
import '../providers/player_provider.dart';

/// Lightweight data model used by the shared song options sheet.
///
/// The goal of this object is simple:
/// different screens in the app may know different amounts of information
/// about a song. Some screens know the full [UploadItem], some only know a
/// history item, and some only know a track id plus a title.
///
/// This class gives the bottom sheet one consistent shape to render.
class TrackOptionInfo {
  const TrackOptionInfo({
    required this.trackId,
    required this.title,
    required this.artist,
    this.coverUrl,
    this.localArtworkPath,
    this.isOwned = false,
  });

  final String trackId;
  final String title;
  final String artist;
  final String? coverUrl;
  final String? localArtworkPath;
  final bool isOwned;

  factory TrackOptionInfo.fromUploadItem(UploadItem item) {
    return TrackOptionInfo(
      trackId: item.id,
      title: item.title,
      artist: item.artistDisplay,
      coverUrl: item.artworkUrl,
      localArtworkPath: item.localArtworkPath,
      isOwned: true,
    );
  }

  factory TrackOptionInfo.fromHistory(HistoryTrack track) {
    return TrackOptionInfo(
      trackId: track.trackId,
      title: track.title,
      artist: track.artist.name,
      coverUrl: track.coverUrl,
    );
  }

  /// Resolve a track from local app stores first.
  ///
  /// Why this matters:
  /// - if the song is one of the user's uploaded tracks, we want `isOwned=true`
  ///   so the sheet shows "Edit track"
  /// - if the uploaded track has local artwork, we want to show that too
  /// - if nothing is found locally, we still use the fallback values supplied
  ///   by the caller so the sheet can render correctly from discovery/history
  factory TrackOptionInfo.fromTrackId(
    String trackId,
    WidgetRef ref, {
    String? fallbackTitle,
    String? fallbackArtist,
    String? fallbackCoverUrl,
    String? fallbackLocalArtworkPath,
    bool fallbackIsOwned = false,
  }) {
    final stored = ref.read(globalTrackStoreProvider).find(trackId);
    if (stored != null) {
      return TrackOptionInfo.fromUploadItem(stored);
    }

    final historyTracks =
        ref.read(listeningHistoryProvider).asData?.value.tracks ?? const [];
    for (final track in historyTracks) {
      if (track.trackId == trackId) {
        return TrackOptionInfo.fromHistory(track);
      }
    }

    return TrackOptionInfo(
      trackId: trackId,
      title: fallbackTitle ?? 'Track',
      artist: fallbackArtist ?? '',
      coverUrl: fallbackCoverUrl,
      localArtworkPath: fallbackLocalArtworkPath,
      isOwned: fallbackIsOwned,
    );
  }
}

Future<void> showTrackOptionsSheet(
  BuildContext context, {
  required TrackOptionInfo info,
  required WidgetRef ref,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _TrackOptionsSheetContent(info: info, ref: ref),
  );
}

class _TrackOptionsSheetContent extends StatelessWidget {
  const _TrackOptionsSheetContent({
    required this.info,
    required this.ref,
  });

  final TrackOptionInfo info;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  UploadArtworkView(
                    localPath: info.localArtworkPath,
                    remoteUrl: info.coverUrl,
                    width: 56,
                    height: 56,
                    backgroundColor: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(4),
                    placeholder: const Icon(
                      Icons.music_note,
                      color: Colors.white24,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          info.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SHARE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  YourUploadsShareButton(
                    icon: Icons.send_outlined,
                    label: 'Message',
                  ),
                  YourUploadsShareButton(
                    icon: Icons.copy_outlined,
                    label: 'Copy link',
                  ),
                  YourUploadsShareButton(
                    icon: Icons.qr_code_2,
                    label: 'QR code',
                  ),
                  YourUploadsShareButton(
                    icon: Icons.sms_outlined,
                    label: 'SMS',
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            YourUploadsOptionRow(
              icon: Icons.favorite_border,
              label: 'Like',
              onTap: () => Navigator.pop(context),
            ),
            if (info.isOwned)
              YourUploadsOptionRow(
                icon: Icons.edit_outlined,
                label: 'Edit track',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditTrack(context);
                },
              ),
            const Divider(color: Colors.white12, height: 1),
            YourUploadsOptionRow(
              icon: Icons.queue_play_next,
              label: 'Play next',
              onTap: () {
                ref.read(playerProvider.notifier).addToQueueNext(info.trackId);
                Navigator.pop(context);
              },
            ),
            YourUploadsOptionRow(
              icon: Icons.playlist_play,
              label: 'Play last',
              onTap: () {
                ref.read(playerProvider.notifier).addToQueueLast(info.trackId);
                Navigator.pop(context);
              },
            ),
            YourUploadsOptionRow(
              icon: Icons.playlist_add,
              label: 'Add to playlist',
              onTap: () => Navigator.pop(context),
            ),
            YourUploadsOptionRow(
              icon: Icons.radio,
              label: 'Start station',
              onTap: () => Navigator.pop(context),
            ),
            const Divider(color: Colors.white12, height: 1),
            YourUploadsOptionRow(
              icon: Icons.graphic_eq,
              label: 'Behind this track',
              onTap: () => Navigator.pop(context),
            ),
            YourUploadsOptionRow(
              icon: Icons.comment_outlined,
              label: 'View comments',
              onTap: () => Navigator.pop(context),
            ),
            if (info.isOwned)
              YourUploadsOptionRow(
                icon: Icons.delete_outline,
                label: 'Delete track',
                color: Colors.redAccent,
                onTap: () => Navigator.pop(context),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _navigateToEditTrack(BuildContext context) {
    final stored = ref.read(globalTrackStoreProvider).find(info.trackId);
    if (stored == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrackDetailScreen(item: stored),
      ),
    );
  }
}
