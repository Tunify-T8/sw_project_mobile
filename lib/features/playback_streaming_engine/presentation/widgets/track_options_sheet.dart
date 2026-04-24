import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_endpoints.dart';

import '../../../audio_upload_and_management/data/services/global_track_store.dart';
import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../audio_upload_and_management/presentation/providers/upload_repository_provider.dart';
import '../../../audio_upload_and_management/presentation/screens/track_detail_screen.dart';
import '../../../audio_upload_and_management/presentation/screens/track_info_screen.dart';
import '../../../audio_upload_and_management/presentation/utils/track_link_helper.dart';
import '../../../audio_upload_and_management/presentation/widgets/upload_artwork_view.dart';
import '../../../audio_upload_and_management/presentation/widgets/your_uploads/your_uploads_options_actions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/screens/other_user_profile_screen.dart';
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
    this.artistId,
    this.isPrivate = false,
    this.privateToken,
  });

  final String trackId;
  final String title;
  final String artist;
  final String? coverUrl;
  final String? localArtworkPath;

  /// Signal from the caller that this track is locally known to belong to
  /// the current user (e.g. it's in the uploads store). The sheet cross-
  /// checks this against the signed-in user too, so callers can pass false
  /// and still get the owner layout if the identities match.
  final bool isOwned;
  final String? privateToken;

  /// The uploader's user id, when known. Required for the non-owner sheet
  /// so "Go to profile" can navigate to the correct profile.
  final String? artistId;

  /// Whether the track's visibility is private. Drives which "Copy link"
  /// label to show and whether a private token is needed for the link.
  final bool isPrivate;

  /// Token for building a shareable private-track link. Only meaningful for
  /// owners (or anyone who already has access).
  final String? privateToken;

  factory TrackOptionInfo.fromUploadItem(UploadItem item, {String? artistId}) {
    return TrackOptionInfo(
      trackId: item.id,
      title: item.title,
      artist: item.artistDisplay,
      coverUrl: item.artworkUrl,
      localArtworkPath: item.localArtworkPath,
      isOwned: true,
      artistId: artistId,
      isPrivate: item.visibility == UploadVisibility.private,
      privateToken: item.privateToken,
    );
  }

  factory TrackOptionInfo.fromHistory(HistoryTrack track) {
    return TrackOptionInfo(
      trackId: track.trackId,
      title: track.title,
      artist: track.artist.name,
      coverUrl: track.coverUrl,
      artistId: track.artist.id.isNotEmpty ? track.artist.id : null,
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
    String? fallbackArtistId,
    String? fallbackPrivateToken,
  }) {
    final stored = ref.read(globalTrackStoreProvider).find(trackId);
    if (stored != null) {
      return TrackOptionInfo.fromUploadItem(
        stored,
        artistId: fallbackArtistId,
      );
    }

    final historyTracks =
        ref.read(listeningHistoryProvider).asData?.value.tracks ?? const [];
    for (final track in historyTracks) {
      if (track.trackId == trackId) {
        return TrackOptionInfo.fromHistory(track);
      }
    }

    // Playing bundle is a last-resort lookup for tracks we don't know about
    // locally — e.g. opened from search then we reopen the sheet elsewhere.
    final playingBundle = ref.read(playerProvider).asData?.value.bundle;
    if (playingBundle != null && playingBundle.trackId == trackId) {
      return TrackOptionInfo(
        trackId: trackId,
        title: playingBundle.title,
        artist: playingBundle.artist.name,
        coverUrl: playingBundle.coverUrl,
        artistId: playingBundle.artist.id.isNotEmpty
            ? playingBundle.artist.id
            : fallbackArtistId,
      );
    }

    return TrackOptionInfo(
      trackId: trackId,
      title: fallbackTitle ?? 'Track',
      artist: fallbackArtist ?? '',
      coverUrl: fallbackCoverUrl,
      localArtworkPath: fallbackLocalArtworkPath,
      isOwned: fallbackIsOwned,
      artistId: fallbackArtistId,
      isPrivate: fallbackPrivateToken != null &&
          fallbackPrivateToken.trim().isNotEmpty,
      privateToken: fallbackPrivateToken,
    );
  }
}

/// Shared bottom sheet used by Artist Home, Your Uploads, Track Detail, etc.
///
/// [onEditTap] / [onDeleteTap] are optional hooks used by the Your Uploads
/// surface so the sheet can wire the existing edit/delete flow without
/// duplicating the UI.
Future<void> showTrackOptionsSheet(
  BuildContext context, {
  required TrackOptionInfo info,
  required WidgetRef ref,
  VoidCallback? onEditTap,
  VoidCallback? onDeleteTap,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _TrackOptionsSheetContent(
      info: info,
      ref: ref,
      onEditTap: onEditTap,
      onDeleteTap: onDeleteTap,
    ),
  );
}

class _TrackOptionsSheetContent extends StatelessWidget {
  const _TrackOptionsSheetContent({
    required this.info,
    required this.ref,
    this.onEditTap,
    this.onDeleteTap,
  });

  final TrackOptionInfo info;
  final WidgetRef ref;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  /// Combine the caller's hint with the current authenticated user id.
  /// If the signed-in user IS the uploader, the sheet always shows the
  /// owner layout — even if the caller didn't know (e.g. opened from a
  /// discovery feed where the track isn't in the local store yet).
  bool _resolveIsOwned() {
    if (info.isOwned) return true;

    final uploaderId = info.artistId?.trim();
    if (uploaderId == null || uploaderId.isEmpty) return false;

    final currentUserId = ref
        .read(authControllerProvider)
        .asData
        ?.value
        ?.id
        .trim();
    if (currentUserId == null || currentUserId.isEmpty) return false;

    return currentUserId == uploaderId;
  }

  @override
  Widget build(BuildContext context) {
    final isOwned = _resolveIsOwned();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
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
            ),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const YourUploadsShareButton(
                    icon: Icons.send_outlined,
                    label: 'Message',
                  ),
                  YourUploadsShareButton(
                    icon: Icons.copy_outlined,
                    label: 'Copy link',
                    onTap: () async {
                      final url = await _buildTrackOptionShareUrl(
                        context,
                        info,
                        ref,
                      );
                      if (url == null) return;
                      await Clipboard.setData(ClipboardData(text: url));
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const YourUploadsShareButton(
                    icon: Icons.qr_code_2,
                    label: 'QR code',
                  ),
                  YourUploadsShareButton(
                    icon: Icons.chat_outlined,
                    label: 'WhatsApp',
                    onTap: () async {
                      final url = await _buildTrackOptionShareUrl(
                        context,
                        info,
                        ref,
                      );
                      if (url == null) return;
                      final msg = Uri.encodeComponent(
                        'Check out "${info.title}" on Tunify: $url',
                      );
                      await launchUrl(
                        Uri.parse('https://wa.me/?text=$msg'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                  const YourUploadsShareButton(
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

  List<Widget> _buildOwnerRows(BuildContext context) {
    return [
      YourUploadsOptionRow(
        icon: Icons.favorite_border,
        label: 'Like',
        onTap: () => Navigator.pop(context),
      ),
      YourUploadsOptionRow(
        icon: Icons.edit_outlined,
        label: 'Edit track',
        onTap: () {
          if (onEditTap != null) {
            onEditTap!();
          } else {
            Navigator.pop(context);
            _navigateToEditTrack(context);
          }
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
        onTap: () {
          Navigator.pop(context);
          _navigateToBehindThisTrack(context);
        },
      ),
      YourUploadsOptionRow(
        icon: Icons.comment_outlined,
        label: 'View comments',
        onTap: () => Navigator.pop(context),
      ),
      YourUploadsOptionRow(
        icon: Icons.delete_outline,
        label: 'Delete track',
        color: Colors.redAccent,
        onTap: () {
          if (onDeleteTap != null) {
            onDeleteTap!();
          } else {
            Navigator.pop(context);
          }
        },
      ),
    ];
  }

  List<Widget> _buildNonOwnerRows(BuildContext context) {
    return [
      YourUploadsOptionRow(
        icon: Icons.favorite_border,
        label: 'Like',
        onTap: () => Navigator.pop(context),
      ),
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
        icon: Icons.person_outline,
        label: 'Go to profile',
        onTap: () {
          Navigator.pop(context);
          _navigateToUploaderProfile(context);
        },
      ),
      YourUploadsOptionRow(
        icon: Icons.comment_outlined,
        label: 'View comments',
        onTap: () => Navigator.pop(context),
      ),
      YourUploadsOptionRow(
        icon: Icons.repeat,
        label: 'Repost',
        onTap: () => Navigator.pop(context),
      ),
      const Divider(color: Colors.white12, height: 1),
      YourUploadsOptionRow(
        icon: Icons.graphic_eq,
        label: 'Behind this track',
        onTap: () {
          Navigator.pop(context);
          _navigateToBehindThisTrack(context);
        },
      ),
      YourUploadsOptionRow(
        icon: Icons.flag_outlined,
        label: 'Report',
        onTap: () => Navigator.pop(context),
      ),
    ];
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

  void _navigateToUploaderProfile(BuildContext context) {
    // Prefer the id the caller supplied; otherwise try to resolve it from
    // the currently playing bundle (same track), and finally from the
    // local store's owner mapping.
    String? userId = info.artistId?.trim();

    if (userId == null || userId.isEmpty) {
      final bundle = ref.read(playerProvider).asData?.value.bundle;
      if (bundle != null && bundle.trackId == info.trackId) {
        final id = bundle.artist.id.trim();
        if (id.isNotEmpty) userId = id;
      }
    }

    if (userId == null || userId.isEmpty) {
      final storeOwner = ref
          .read(globalTrackStoreProvider)
          .ownerUserIdForTrack(info.trackId);
      if (storeOwner != null &&
          storeOwner.isNotEmpty &&
          storeOwner != '__global__') {
        userId = storeOwner;
      }
    }

    if (userId == null || userId.isEmpty) {
      // Without an id we cannot open the profile — surface a hint instead
      // of navigating to a broken screen.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uploader profile is not available for this track'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtherUserProfileScreen(userId: userId!),
      ),
    );
  }

  void _navigateToBehindThisTrack(BuildContext context) {
    final store = ref.read(globalTrackStoreProvider);
    final stored = store.find(info.trackId);
    final item = stored ??
        UploadItem(
          id: info.trackId,
          title: info.title,
          artistDisplay: info.artist,
          durationLabel: '',
          durationSeconds: 0,
          audioUrl: null,
          waveformUrl: null,
          artworkUrl: info.coverUrl,
          localArtworkPath: info.localArtworkPath,
          localFilePath: null,
          description: '',
          visibility: info.isPrivate
              ? UploadVisibility.private
              : UploadVisibility.public,
          status: UploadProcessingStatus.finished,
          isExplicit: false,
          privateToken: info.privateToken,
          createdAt: DateTime.now(),
        );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrackInfoScreen(item: item),
      ),
    );
  }
}

class _TrackHeader extends StatelessWidget {
  const _TrackHeader({required this.info});

  final TrackOptionInfo info;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class _ShareLabel extends StatelessWidget {
  const _ShareLabel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
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
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.info});

  final TrackOptionInfo info;

  @override
  Widget build(BuildContext context) {
    final hasToken =
        info.privateToken != null && info.privateToken!.trim().isNotEmpty;
    final useTokenInLink = info.isPrivate && hasToken;

    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const YourUploadsShareButton(
            icon: Icons.send_outlined,
            label: 'Message',
          ),
          YourUploadsShareButton(
            icon: Icons.copy_outlined,
            label: useTokenInLink ? 'Copy private link' : 'Copy link',
            onTap: () async {
              await TrackLinkHelper.copyTrackLink(
                context,
                trackId: info.trackId,
                privateToken: useTokenInLink ? info.privateToken : null,
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const YourUploadsShareButton(
            icon: Icons.qr_code_2,
            label: 'QR code',
          ),
          const YourUploadsShareButton(
            icon: Icons.sms_outlined,
            label: 'SMS',
          ),
        ],
      ),
    );
  }
}

Future<String?> _buildTrackOptionShareUrl(
  BuildContext context,
  TrackOptionInfo info,
  WidgetRef ref,
) async {
  var privateToken = info.privateToken?.trim();
  var detailPrivacy = '';

  try {
    final details = await ref
        .read(uploadRepositoryProvider)
        .getTrackDetails(info.trackId)
        .timeout(const Duration(seconds: 5));
    detailPrivacy = details.privacy?.trim().toLowerCase() ?? '';
    final detailToken = details.privateToken?.trim();
    if (detailToken != null && detailToken.isNotEmpty) {
      privateToken = detailToken;
    }
  } catch (error) {
    debugPrint('shareTrackUrl detail fetch failed for ${info.trackId}: $error');
  }

  final current = ref.read(playerProvider).asData?.value;
  if (current?.bundle?.trackId == info.trackId) {
    final currentToken = current?.privateToken?.trim();
    if (currentToken != null && currentToken.isNotEmpty) {
      privateToken = currentToken;
    }
  }

  final stored = ref.read(globalTrackStoreProvider).find(info.trackId);
  final shouldUsePrivateLink =
      detailPrivacy == 'private' ||
      stored?.visibility == UploadVisibility.private ||
      (privateToken != null && privateToken.isNotEmpty);

  debugPrint(
    'shareTrackUrl trackId=${info.trackId} '
    'isOwned=${info.isOwned} '
    'detailPrivacy=$detailPrivacy '
    'storedVisibility=${stored?.visibility.name} '
    'requiresPrivate=$shouldUsePrivateLink '
    'hasPrivateToken=${privateToken != null && privateToken.isNotEmpty}',
  );

  if (shouldUsePrivateLink &&
      (privateToken == null || privateToken.isEmpty)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create private link. Token is missing.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
    return null;
  }

  return ApiEndpoints.shareTrackUrl(
    info.trackId,
    privateToken: shouldUsePrivateLink ? privateToken : null,
  );
}
