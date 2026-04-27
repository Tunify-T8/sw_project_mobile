import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../audio_upload_and_management/presentation/widgets/your_uploads/your_uploads_options_actions.dart';
import '../../../engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../engagements_social_interactions/presentation/provider/engagement_state.dart';
import '../../../engagements_social_interactions/presentation/screens/comments_screen.dart';
import '../../../engagements_social_interactions/presentation/widgets/repost_caption_sheet.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../../profile/presentation/screens/other_user_profile_screen.dart';
import '../../domain/entities/playlist_track_entity.dart';

void showTrackInPlaylistOptionsSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PlaylistTrackEntity track,
  required VoidCallback onRemoveFromPlaylist,
}) {
  if (ref.read(engagementProvider(track.trackId)).engagementStatus ==
      EngagementStatus.initial) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(engagementProvider(track.trackId).notifier).loadEngagement();
    });
  }
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _TrackInPlaylistOptionsSheet(
      outerRef: ref,
      track: track,
      onRemoveFromPlaylist: onRemoveFromPlaylist,
    ),
  );
}

class _TrackInPlaylistOptionsSheet extends ConsumerWidget {
  const _TrackInPlaylistOptionsSheet({
    required this.outerRef,
    required this.track,
    required this.onRemoveFromPlaylist,
  });

  final WidgetRef outerRef;
  final PlaylistTrackEntity track;
  final VoidCallback onRemoveFromPlaylist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engState = ref.watch(engagementProvider(track.trackId));
    final isLiked = engState.engagement?.isLiked ?? false;
    final isReposted = engState.engagement?.isReposted ?? false;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _Header(track: track),
          _ShareRow(track: track),
          const Divider(color: Colors.white12, height: 1),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Like ────────────────────────────────────────────────
                  YourUploadsOptionRow(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    label: isLiked ? 'Unlike' : 'Like',
                    color: isLiked ? Colors.orange : Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      ref
                          .read(engagementProvider(track.trackId).notifier)
                          .toggleLike();
                    },
                  ),

                  // ── Play Next ───────────────────────────────────────────
                  YourUploadsOptionRow(
                    icon: Icons.queue_play_next_outlined,
                    label: 'Play Next',
                    onTap: () {
                      outerRef
                          .read(playerProvider.notifier)
                          .addToQueueNext(track.trackId);
                      Navigator.pop(context);
                    },
                  ),

                  // ── Play Last ───────────────────────────────────────────
                  YourUploadsOptionRow(
                    icon: Icons.add_to_queue_outlined,
                    label: 'Play Last',
                    onTap: () {
                      outerRef
                          .read(playerProvider.notifier)
                          .addToQueueLast(track.trackId);
                      Navigator.pop(context);
                    },
                  ),

                  YourUploadsOptionRow(
                    icon: Icons.playlist_add,
                    label: 'Add to playlist',
                    onTap: () => Navigator.pop(context),
                  ),

                  // ── Remove from playlist ────────────────────────────────
                  YourUploadsOptionRow(
                    icon: Icons.playlist_remove,
                    label: 'Remove from playlist',
                    onTap: () {
                      Navigator.pop(context);
                      onRemoveFromPlaylist();
                    },
                  ),

                  YourUploadsOptionRow(
                    icon: Icons.radio,
                    label: 'Start station',
                    onTap: () => Navigator.pop(context),
                  ),

                  const Divider(color: Colors.white12, height: 1),

                  // ── Go to artist profile ────────────────────────────────
                  YourUploadsOptionRow(
                    icon: Icons.person_outline,
                    label: 'Go to artist profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OtherUserProfileScreen(
                            userId: track.ownerId,
                          ),
                        ),
                      );
                    },
                  ),

                  // ── View comments ───────────────────────────────────────
                  YourUploadsOptionRow(
                    icon: Icons.comment_outlined,
                    label: 'View comments',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CommentsScreen(
                            trackId: track.trackId,
                            coverUrl: track.coverUrl,
                            trackTitle: track.title,
                            artistName: track.ownerDisplayName ??
                                track.ownerUsername,
                          ),
                        ),
                      );
                    },
                  ),

                  // ── Repost ──────────────────────────────────────────────
                  YourUploadsOptionRow(
                    icon: Icons.repeat,
                    label: isReposted ? 'Remove repost' : 'Repost',
                    color: isReposted ? Colors.orange : Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      if (isReposted) {
                        ref
                            .read(engagementProvider(track.trackId).notifier)
                            .removeRepost();
                      } else {
                        RepostCaptionSheet.show(
                          context,
                          trackId: track.trackId,
                          trackTitle: track.title,
                          artistName: track.ownerDisplayName ??
                              track.ownerUsername,
                          coverUrl: track.coverUrl,
                        );
                      }
                    },
                  ),

                  const Divider(color: Colors.white12, height: 1),

                  YourUploadsOptionRow(
                    icon: Icons.graphic_eq,
                    label: 'Behind this track',
                    onTap: () => Navigator.pop(context),
                  ),
                  YourUploadsOptionRow(
                    icon: Icons.flag_outlined,
                    label: 'Report',
                    onTap: () => Navigator.pop(context),
                  ),
                  SizedBox(height: bottomPadding + 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.track});
  final PlaylistTrackEntity track;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (track.coverUrl != null)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Image.network(track.coverUrl!, fit: BoxFit.cover),
            ),
          ),
        Container(color: Colors.black.withValues(alpha: 0.6)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              _CoverArt(coverUrl: track.coverUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.ownerDisplayName ?? track.ownerUsername,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverArt extends StatelessWidget {
  const _CoverArt({this.coverUrl});
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl != null
          ? Image.network(coverUrl!, fit: BoxFit.cover)
          : const Icon(Icons.music_note, color: Colors.white38, size: 26),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.track});
  final PlaylistTrackEntity track;

  String get _url =>
      '${ApiEndpoints.shareBaseUrl}/tracks/${track.trackId}';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          YourUploadsShareButton(
            icon: Icons.send_outlined,
            label: 'Message',
            onTap: () async {
              final body = Uri.encodeComponent(
                  'Check out "${track.title}" on Tunify: $_url');
              await launchUrl(Uri.parse('sms:?body=$body'),
                  mode: LaunchMode.externalApplication);
            },
          ),
          YourUploadsShareButton(
            icon: Icons.copy_outlined,
            label: 'Copy Link',
            onTap: () {
              Clipboard.setData(ClipboardData(text: _url));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF1C1C1E),
                  content: Text('Link copied',
                      style: TextStyle(color: Colors.white)),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          SocialShareButton(
            faIcon: FontAwesomeIcons.whatsapp,
            iconColor: const Color(0xFF25D366),
            label: 'WhatsApp',
            onTap: () async {
              final msg = Uri.encodeComponent(
                  'Check out "${track.title}" on Tunify: $_url');
              await launchUrl(Uri.parse('https://wa.me/?text=$msg'),
                  mode: LaunchMode.externalApplication);
            },
          ),
          SocialShareButton(
            faIcon: FontAwesomeIcons.instagram,
            iconColor: const Color(0xFFE1306C),
            label: 'Stories',
            onTap: () async {
              await launchUrl(
                Uri.parse(
                    'instagram://sharesheet?text=${Uri.encodeComponent(_url)}'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          YourUploadsShareButton(
            icon: Icons.sms_outlined,
            label: 'SMS',
            onTap: () async {
              final body = Uri.encodeComponent(
                  'Check out "${track.title}" on Tunify: $_url');
              await launchUrl(Uri.parse('sms:?body=$body'),
                  mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }
}
