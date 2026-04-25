import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/routing/routes.dart';

import '../../../audio_upload_and_management/data/services/global_track_store.dart';
import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../audio_upload_and_management/presentation/providers/upload_repository_provider.dart';
import '../../../audio_upload_and_management/presentation/screens/track_detail_screen.dart';
import '../../../audio_upload_and_management/presentation/screens/track_info_screen.dart';
import '../../../audio_upload_and_management/presentation/widgets/upload_artwork_view.dart';
import '../../../audio_upload_and_management/presentation/widgets/your_uploads/your_uploads_options_actions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../engagements_social_interactions/presentation/provider/engagement_state.dart';
import '../../../engagements_social_interactions/presentation/widgets/repost_caption_sheet.dart';
import '../../../messaging_track_sharing/domain/entities/conversation_entity.dart';
import '../../../messaging_track_sharing/domain/entities/message_attachment.dart';
import '../../../messaging_track_sharing/presentation/state/conversations_controller.dart';
import '../../../profile/presentation/screens/other_user_profile_screen.dart';
import '../../domain/entities/history_track.dart';
import '../providers/listening_history_provider.dart';
import '../providers/player_provider.dart';

/// Lightweight data model used by the shared song options sheet.
class TrackOptionInfo {
  const TrackOptionInfo({
    required this.trackId,
    required this.title,
    required this.artist,
    this.artistId,
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
  final String? artistId;
  final String? coverUrl;
  final String? localArtworkPath;
  final bool isOwned;
  final String? artistId;
  final bool isPrivate;
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
      artistId: track.artist.id,
      coverUrl: track.coverUrl,
      artistId: track.artist.id.isNotEmpty ? track.artist.id : null,
    );
  }

  factory TrackOptionInfo.fromTrackId(
    String trackId,
    WidgetRef ref, {
    String? fallbackTitle,
    String? fallbackArtist,
    String? fallbackArtistId,
    String? fallbackCoverUrl,
    String? fallbackLocalArtworkPath,
    bool fallbackIsOwned = false,
    String? fallbackArtistId,
    String? fallbackPrivateToken,
  }) {
    final stored = ref.read(globalTrackStoreProvider).find(trackId);
    if (stored != null) {
      return TrackOptionInfo.fromUploadItem(stored, artistId: fallbackArtistId);
    }

    final historyTracks =
        ref.read(listeningHistoryProvider).asData?.value.tracks ?? const [];
    for (final track in historyTracks) {
      if (track.trackId == trackId) {
        return TrackOptionInfo.fromHistory(track);
      }
    }

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
      artistId: fallbackArtistId,
      coverUrl: fallbackCoverUrl,
      localArtworkPath: fallbackLocalArtworkPath,
      isOwned: fallbackIsOwned,
      artistId: fallbackArtistId,
      isPrivate:
          fallbackPrivateToken != null && fallbackPrivateToken.trim().isNotEmpty,
      privateToken: fallbackPrivateToken,
    );
  }
}

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
    builder: (ctx) {
      if (ref.read(engagementProvider(info.trackId)).engagementStatus == EngagementStatus.initial) {
        ref.read(engagementProvider(info.trackId).notifier).loadEngagement();
      }
      return _TrackOptionsSheetContent(
        info: info,
        ref: ref,
        onEditTap: onEditTap,
        onDeleteTap: onDeleteTap,
      );
    },
  );
}

class _TrackOptionsSheetContent extends ConsumerWidget {
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

  bool _resolveIsOwned() {
    if (info.isOwned) return true;

    final uploaderId = info.artistId?.trim();
    if (uploaderId == null || uploaderId.isEmpty) return false;

    final currentUserId =
        ref.read(authControllerProvider).asData?.value?.id.trim();
    if (currentUserId == null || currentUserId.isEmpty) return false;

    return currentUserId == uploaderId;
  }

  @override
  Widget build(BuildContext context, WidgetRef watchRef) {
    final isOwned = _resolveIsOwned();
    final conversations =
        watchRef.watch(conversationsControllerProvider).items;

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
              // ── Drag handle ──────────────────────────────────────────
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // ── Frosted track header ─────────────────────────────────
              _FrostedTrackHeader(info: info),
              const SizedBox(height: 4),

              // ── Send To ──────────────────────────────────────────────
              if (conversations.isNotEmpty) ...[
                _SectionLabel(label: 'SEND TO'),
                _SendToRow(
                  info: info,
                  conversations: conversations,
                ),
              ],

              // ── Share ────────────────────────────────────────────────
              _SectionLabel(label: 'SHARE'),
              _ShareRow(info: info, ref: ref),

              const Divider(color: Colors.white12, height: 1),

              // ── Action rows (owner vs non-owner) ─────────────────────
              ...(isOwned
                  ? _buildOwnerRows(context)
                  : _buildNonOwnerRows(context)),

              const SizedBox(height: 8),
            ],
          ),
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
    if (stored == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrackDetailScreen(item: stored)),
    );
  }

  void _navigateToUploaderProfile(BuildContext context) {
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
      MaterialPageRoute(builder: (_) => TrackInfoScreen(item: item)),
    );
  }
}

// ── Frosted track header ────────────────────────────────────────────────────

class _FrostedTrackHeader extends StatelessWidget {
  const _FrostedTrackHeader({required this.info});

  final TrackOptionInfo info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Blurred artwork backdrop
            if (info.coverUrl != null || info.localArtworkPath != null)
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: UploadArtworkView(
                    localPath: info.localArtworkPath,
                    remoteUrl: info.coverUrl,
                    width: double.infinity,
                    height: double.infinity,
                    backgroundColor: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.zero,
                    placeholder: const SizedBox.shrink(),
                  ),
                ),
              )
            else
              Positioned.fill(
                child: Container(color: const Color(0xFF2A2A2A)),
              ),

            // Dark overlay so text is always readable
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.55)),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  UploadArtworkView(
                    localPath: info.localArtworkPath,
                    remoteUrl: info.coverUrl,
                    width: 56,
                    height: 56,
                    backgroundColor: const Color(0xFF3A4A6A),
                    borderRadius: BorderRadius.circular(6),
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
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              info.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            if (info.isPrivate) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.lock_outline,
                                color: Colors.white54,
                                size: 13,
                              ),
                              const SizedBox(width: 2),
                              const Text(
                                'Private',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
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
            Consumer(
              builder: (context, watchRef, _) {
                final engagement = watchRef.watch(engagementProvider(info.trackId)).engagement;
                final isLiked = engagement?.isLiked ?? false;
                final isReposted = engagement?.isReposted ?? false;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    YourUploadsOptionRow(
                      key: const Key('track_options_like_row'),
                      icon: isLiked ? Icons.favorite : Icons.favorite_border,
                      label: isLiked ? 'Unlike' : 'Like',
                      color: isLiked ? Colors.orange : Colors.white,
                      onTap: () {
                        watchRef.read(engagementProvider(info.trackId).notifier).toggleLike();
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
                    if (info.artistId != null && info.artistId!.isNotEmpty)
                      YourUploadsOptionRow(
                        icon: Icons.person_outline,
                        label: 'Go to artist profile',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OtherUserProfileScreen(userId: info.artistId!),
                            ),
                          );
                        },
                      ),
                    YourUploadsOptionRow(
                      key: const Key('track_options_comments_row'),
                      icon: Icons.comment_outlined,
                      label: 'View comments',
                      onTap: () => Navigator.pop(context),
                    ),
                    YourUploadsOptionRow(
                      key: const Key('track_options_repost_row'),
                      icon: isReposted ? Icons.repeat_on : Icons.repeat,
                      label: isReposted ? 'Undo Repost' : 'Repost',
                      color: isReposted ? Colors.orange : Colors.white,
                      onTap: () async {
                        Navigator.pop(context);
                        if (isReposted) {
                          watchRef.read(engagementProvider(info.trackId).notifier).removeRepost();
                        } else {
                          await RepostCaptionSheet.show(
                            context,
                            trackId: info.trackId,
                            trackTitle: info.title,
                            artistName: info.artist,
                            coverUrl: info.coverUrl,
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
                    if (info.isOwned)
                      YourUploadsOptionRow(
                        icon: Icons.edit_outlined,
                        label: 'Edit track',
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToEditTrack(context);
                        },
                      ),
                    if (info.isOwned)
                      YourUploadsOptionRow(
                        icon: Icons.delete_outline,
                        label: 'Delete track',
                        color: Colors.redAccent,
                        onTap: () => Navigator.pop(context),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Section label ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
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

// ── Send To row (recent conversations) ─────────────────────────────────────

class _SendToRow extends StatelessWidget {
  const _SendToRow({required this.info, required this.conversations});

  final TrackOptionInfo info;
  final List<ConversationEntity> conversations;

  @override
  Widget build(BuildContext context) {
    final visible = conversations.take(5).toList();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: visible.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final conv = visible[index];
          return _SendToAvatar(info: info, conversation: conv);
        },
      ),
    );
  }
}

class _SendToAvatar extends StatelessWidget {
  const _SendToAvatar({required this.info, required this.conversation});

  final TrackOptionInfo info;
  final ConversationEntity conversation;

  @override
  Widget build(BuildContext context) {
    final user = conversation.otherUser;
    final name = user.displayName;
    final shortName = name.length > 8 ? '${name.substring(0, 7)}…' : name;

    return GestureDetector(
      onTap: () => _sendTrackToConversation(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF2A2A2A),
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            shortName,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _sendTrackToConversation(BuildContext context) {
    Navigator.pop(context);
    Navigator.of(context).pushNamed(
      Routes.chat,
      arguments: {
        'conversationId': conversation.conversationId,
        'otherUserName': conversation.otherUser.displayName,
        'otherUserAvatar': conversation.otherUser.avatarUrl,
        'pendingAttachment': MessageAttachment(
          id: info.trackId,
          type: MessageAttachmentType.track,
          title: info.title,
          subtitle: info.artist,
          artworkUrl: info.coverUrl,
        ),
      },
    );
  }
}

// ── Share row (social + copy link) ─────────────────────────────────────────

class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.info, required this.ref});

  final TrackOptionInfo info;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final hasToken =
        info.privateToken != null && info.privateToken!.trim().isNotEmpty;
    final usePrivateLabel = info.isPrivate || hasToken;

    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Message — opens native share sheet
          YourUploadsShareButton(
            icon: Icons.send_outlined,
            label: 'Message',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              final text = Uri.encodeComponent(
                  'Check out "${info.title}" on Tunify: $url');
              await launchUrl(
                Uri.parse('sms:?body=$text'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),

          // Copy link
          YourUploadsShareButton(
            icon: Icons.copy_outlined,
            label: usePrivateLabel ? 'Copy private link' : 'Copy link',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              await Clipboard.setData(ClipboardData(text: url));
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    usePrivateLabel
                        ? 'Private link copied to clipboard'
                        : 'Link copied to clipboard',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          // QR code (placeholder)
          const YourUploadsShareButton(
            icon: Icons.qr_code_2,
            label: 'QR code',
          ),

          // WhatsApp
          _SocialShareButton(
            faIcon: FontAwesomeIcons.whatsapp,
            iconColor: const Color(0xFF25D366),
            label: 'WhatsApp',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              final msg = Uri.encodeComponent(
                  'Check out "${info.title}" on Tunify: $url');
              await launchUrl(
                Uri.parse('https://wa.me/?text=$msg'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),

          // SMS
          YourUploadsShareButton(
            icon: Icons.sms_outlined,
            label: 'SMS',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              final text = Uri.encodeComponent(
                  'Check out "${info.title}" on Tunify: $url');
              await launchUrl(
                Uri.parse('sms:?body=$text'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),

          // Instagram Stories
          _SocialShareButton(
            faIcon: FontAwesomeIcons.instagram,
            iconColor: const Color(0xFFE1306C),
            label: 'Stories',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              // Instagram deep-link: opens the app
              await launchUrl(
                Uri.parse('instagram://sharesheet?text=${Uri.encodeComponent('Check out "${info.title}" on Tunify: $url')}'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),

          // Snapchat
          _SocialShareButton(
            faIcon: FontAwesomeIcons.snapchat,
            iconColor: const Color(0xFFFFFC00),
            label: 'Snapchat',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              await launchUrl(
                Uri.parse('snapchat://send?text=${Uri.encodeComponent('Check out "${info.title}" on Tunify: $url')}'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),

          // Facebook
          _SocialShareButton(
            faIcon: FontAwesomeIcons.facebook,
            iconColor: const Color(0xFF1877F2),
            label: 'Facebook',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              await launchUrl(
                Uri.parse('https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),

          // X (Twitter)
          _SocialShareButton(
            faIcon: FontAwesomeIcons.xTwitter,
            iconColor: Colors.white,
            label: 'X',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              final text = Uri.encodeComponent(
                  'Check out "${info.title}" on Tunify: $url');
              await launchUrl(
                Uri.parse('https://twitter.com/intent/tweet?text=$text'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),

          // Messenger
          _SocialShareButton(
            faIcon: FontAwesomeIcons.facebookMessenger,
            iconColor: const Color(0xFF0084FF),
            label: 'Messenger',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              await launchUrl(
                Uri.parse('fb-messenger://share?link=${Uri.encodeComponent(url)}'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),

          // More (opens generic share intent via browser fallback)
          YourUploadsShareButton(
            icon: Icons.more_horiz,
            label: 'More',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A share button that renders a FontAwesome brand icon inside a colored circle.
class _SocialShareButton extends StatelessWidget {
  const _SocialShareButton({
    required this.faIcon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  final IconData faIcon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(faIcon, color: iconColor, size: 22),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Share URL builder ───────────────────────────────────────────────────────

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
  final shouldUsePrivateLink = detailPrivacy == 'private' ||
      stored?.visibility == UploadVisibility.private ||
      (privateToken != null && privateToken.isNotEmpty);

  if (shouldUsePrivateLink && (privateToken == null || privateToken.isEmpty)) {
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
