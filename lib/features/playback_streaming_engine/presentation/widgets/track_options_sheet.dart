import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/routing/routes.dart';

import '../../../audio_upload_and_management/data/services/global_track_store.dart';
import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../audio_upload_and_management/presentation/providers/library_uploads_provider.dart';
import '../../../audio_upload_and_management/presentation/providers/track_detail_item_provider.dart';
import '../../../audio_upload_and_management/presentation/providers/upload_repository_provider.dart';
import '../../../audio_upload_and_management/presentation/screens/edit_track_screen.dart';
import '../../../audio_upload_and_management/presentation/screens/track_info_screen.dart';
import '../../../audio_upload_and_management/presentation/widgets/upload_artwork_view.dart';
import '../../../audio_upload_and_management/presentation/widgets/your_uploads/your_uploads_dialogs.dart';
import '../../../audio_upload_and_management/presentation/widgets/your_uploads/your_uploads_options_actions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../engagements_social_interactions/presentation/provider/engagement_state.dart';
import '../../../engagements_social_interactions/presentation/screens/comments_screen.dart';
import '../../../engagements_social_interactions/presentation/widgets/repost_caption_sheet.dart';
import '../../../messaging_track_sharing/domain/entities/conversation_entity.dart';
import '../../../messaging_track_sharing/domain/entities/message_attachment.dart';
import '../../../messaging_track_sharing/presentation/state/chat_controller.dart';
import '../../../messaging_track_sharing/presentation/state/conversations_controller.dart';
import '../../../premium_subscription/domain/entities/subscription_tier.dart';
import '../../../premium_subscription/presentation/providers/subscription_notifier.dart';
import '../../../profile/presentation/screens/other_user_profile_screen.dart';
import '../../../playlists/domain/entities/collection_type.dart';
import '../../../playlists/presentation/widgets/select_playlist_sheet.dart';
import '../../domain/entities/history_track.dart';
import '../providers/listening_history_provider.dart';
import '../providers/player_provider.dart';
import 'track_qr_code.dart';

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
  final bool isPrivate;
  final String? privateToken;

  factory TrackOptionInfo.fromUploadItem(
    UploadItem item, {
    String? artistId,
    bool isOwned = true,
  }) {
    return TrackOptionInfo(
      trackId: item.id,
      title: item.title,
      artist: item.artistDisplay,
      coverUrl: item.artworkUrl,
      localArtworkPath: item.localArtworkPath,
      isOwned: isOwned,
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
      artistId: track.artist.id.isNotEmpty ? track.artist.id : null,
      coverUrl: track.coverUrl,
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
    String? fallbackPrivateToken,
  }) {
    final store = ref.read(globalTrackStoreProvider);
    final stored = store.find(trackId);
    if (stored != null) {
      final currentUserId = ref
          .read(authControllerProvider)
          .asData
          ?.value
          ?.id
          .trim();
      final ownerUserId = store.ownerUserIdForTrack(trackId);
      final isDefinitelyOwned =
          currentUserId != null &&
          currentUserId.isNotEmpty &&
          ownerUserId != null &&
          ownerUserId != '__global__' &&
          ownerUserId == currentUserId;
      final isFallbackOwned =
          fallbackIsOwned ||
          (currentUserId != null &&
              currentUserId.isNotEmpty &&
              fallbackArtistId == currentUserId);
      return TrackOptionInfo.fromUploadItem(
        stored,
        artistId: fallbackArtistId,
        isOwned: isDefinitelyOwned || isFallbackOwned,
      );
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
      isPrivate:
          fallbackPrivateToken != null &&
          fallbackPrivateToken.trim().isNotEmpty,
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
      if (ref.read(engagementProvider(info.trackId)).engagementStatus ==
          EngagementStatus.initial) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(engagementProvider(info.trackId).notifier).loadEngagement();
        });
      }
      return TrackOptionsSheetContent(
        info: info,
        ref: ref,
        onEditTap: onEditTap,
        onDeleteTap: onDeleteTap,
      );
    },
  );
}

Future<void> showTrackShareSheet(
  BuildContext context, {
  required TrackOptionInfo info,
  required WidgetRef ref,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => TrackShareSheetContent(info: info, ref: ref),
  );
}

final _trackOptionsOwnerProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, trackId) async {
      final details = await ref
          .read(uploadRepositoryProvider)
          .getTrackDetails(trackId)
          .timeout(const Duration(seconds: 5));
      final ownerUserId = details.ownerUserId?.trim();
      final stored = ref.read(globalTrackStoreProvider).find(trackId);
      if (stored != null && ownerUserId != null && ownerUserId.isNotEmpty) {
        ref
            .read(globalTrackStoreProvider)
            .update(stored, ownerUserId: ownerUserId);
      }
      return ownerUserId == null || ownerUserId.isEmpty ? null : ownerUserId;
    });

class TrackShareSheetContent extends ConsumerWidget {
  const TrackShareSheetContent({
    super.key,
    required this.info,
    required this.ref,
  });

  final TrackOptionInfo info;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef watchRef) {
    final conversations = watchRef.watch(conversationsControllerProvider).items;

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
              const SizedBox(height: 12),
              FrostedTrackHeader(info: info),
              const SizedBox(height: 4),
              if (conversations.isNotEmpty) ...[
                SectionLabel(label: 'SEND TO'),
                SendToRow(info: info, conversations: conversations),
              ],
              SectionLabel(label: 'SHARE'),
              ShareRow(info: info, ref: ref),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackOptionsSheetContent extends ConsumerWidget {
  const TrackOptionsSheetContent({
    super.key,
    required this.info,
    required this.ref,
    this.onEditTap,
    this.onDeleteTap,
  });

  final TrackOptionInfo info;
  final WidgetRef ref;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  bool _resolveIsOwned({String? currentUserId, String? backendOwnerUserId}) {
    if (info.isOwned) return true;

    if (currentUserId == null || currentUserId.isEmpty) return false;

    final ownerId = backendOwnerUserId?.trim();
    if (ownerId != null && ownerId.isNotEmpty) {
      return currentUserId == ownerId;
    }

    final storeOwnerId = ref
        .read(globalTrackStoreProvider)
        .ownerUserIdForTrack(info.trackId)
        ?.trim();
    if (storeOwnerId != null &&
        storeOwnerId.isNotEmpty &&
        storeOwnerId != '__global__') {
      return currentUserId == storeOwnerId;
    }

    final uploaderId = info.artistId?.trim();
    if (uploaderId == null || uploaderId.isEmpty) return false;

    return currentUserId == uploaderId;
  }

  bool _isArtist() {
    final role = ref.read(authControllerProvider).value?.role.toUpperCase();
    return role == 'ARTIST';
  }

  void _openAddToAlbum(BuildContext context) {
    final navigator = Navigator.of(context);
    final targetContext = navigator.context;
    if (!_isArtist()) {
      navigator.pop();
      ScaffoldMessenger.of(targetContext).showSnackBar(
        const SnackBar(content: Text('Only artists can add to albums')),
      );
      return;
    }
    navigator.pop();
    showSelectPlaylistSheet(
      context: targetContext,
      ref: ref,
      trackId: info.trackId,
      collectionType: CollectionType.album,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef watchRef) {
    final currentUserId = watchRef
        .watch(authControllerProvider)
        .value
        ?.id
        .trim();
    final backendOwnerUserId = watchRef
        .watch(_trackOptionsOwnerProvider(info.trackId))
        .asData
        ?.value
        ?.trim();
    final isOwned = _resolveIsOwned(
      currentUserId: currentUserId,
      backendOwnerUserId: backendOwnerUserId,
    );
    final conversations = watchRef.watch(conversationsControllerProvider).items;
    final subscriptionState = watchRef.watch(subscriptionNotifierProvider);
    final currentSubscription = subscriptionState.currentSubscription;
    final canDownload = currentSubscription.tier != SubscriptionTier.free;
    final engagementState = watchRef.watch(engagementProvider(info.trackId));
    final engagement = engagementState.engagement;
    final isLiked = engagement?.isLiked ?? false;
    final isReposted = engagement?.isReposted ?? false;

    if (engagementState.engagementStatus == EngagementStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        watchRef
            .read(engagementProvider(info.trackId).notifier)
            .loadEngagement();
      });
    }

    if (!subscriptionState.hasLoadedCurrent &&
        !subscriptionState.isCurrentLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        watchRef
            .read(subscriptionNotifierProvider.notifier)
            .loadCurrentSubscription();
      });
    }

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
              FrostedTrackHeader(info: info),
              const SizedBox(height: 4),

              // ── Send To ──────────────────────────────────────────────
              if (conversations.isNotEmpty) ...[
                SectionLabel(label: 'SEND TO'),
                SendToRow(info: info, conversations: conversations),
              ],

              // ── Share ────────────────────────────────────────────────
              SectionLabel(label: 'SHARE'),
              ShareRow(info: info, ref: ref),

              const Divider(color: Colors.white12, height: 1),

              if (canDownload) ...[
                YourUploadsOptionRow(
                  icon: Icons.download_outlined,
                  label: 'Download track',
                  onTap: () => downloadTrackFromOptions(context, ref, info),
                ),
                const Divider(color: Colors.white12, height: 1),
              ],

              // ── Action rows (owner vs non-owner) ─────────────────────
              ...(isOwned
                  ? _buildOwnerRows(context)
                  : _buildNonOwnerRows(
                      context,
                      isLiked: isLiked,
                      isReposted: isReposted,
                    )),

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
        icon: Icons.edit_outlined,
        label: 'Edit track',
        onTap: () {
          if (onEditTap != null) {
            onEditTap!();
          } else {
            editTrackFromOptions(context, ref, info);
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
        key: const Key('track_options_add_to_playlist'),
        icon: Icons.playlist_add,
        label: 'Add to playlist',
        onTap: () {
          final navigator = Navigator.of(context);
          final targetContext = navigator.context;
          navigator.pop();
          showSelectPlaylistSheet(
            context: targetContext,
            ref: ref,
            trackId: info.trackId,
          );
        },
      ),
      YourUploadsOptionRow(
        key: const Key('track_options_add_to_album'),
        icon: Icons.album_outlined,
        label: 'Add to album',
        onTap: () => _openAddToAlbum(context),
      ),
      const Divider(color: Colors.white12, height: 1),
      YourUploadsOptionRow(
        icon: Icons.graphic_eq,
        label: 'Behind this track',
        onTap: () {
          final navigator = Navigator.of(context);
          final targetContext = navigator.context;
          navigator.pop();
          _navigateToBehindThisTrack(targetContext);
        },
      ),
      YourUploadsOptionRow(
        icon: Icons.comment_outlined,
        label: 'View comments',
        onTap: () {
          final navigator = Navigator.of(context);
          navigator.pop();
          navigator.push(
            MaterialPageRoute(
              builder: (_) => CommentsScreen(trackId: info.trackId),
            ),
          );
        },
      ),
      YourUploadsOptionRow(
        icon: Icons.delete_outline,
        label: 'Delete track',
        color: Colors.redAccent,
        onTap: () {
          if (onDeleteTap != null) {
            onDeleteTap!();
          } else {
            deleteTrackFromOptions(context, ref, info);
          }
        },
      ),
    ];
  }

  List<Widget> _buildNonOwnerRows(
    BuildContext context, {
    required bool isLiked,
    required bool isReposted,
  }) {
    return [
      YourUploadsOptionRow(
        key: const Key('track_options_like'),
        icon: isLiked ? Icons.favorite : Icons.favorite_border,
        label: isLiked ? 'Liked' : 'Like',
        color: isLiked ? Colors.orange : Colors.white,
        onTap: () {
          ref.read(engagementProvider(info.trackId).notifier).toggleLike();
          Navigator.pop(context);
        },
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
        key: const Key('track_options_add_to_playlist'),
        icon: Icons.playlist_add,
        label: 'Add to playlist',
        onTap: () {
          final navigator = Navigator.of(context);
          final targetContext = navigator.context;
          navigator.pop();
          showSelectPlaylistSheet(
            context: targetContext,
            ref: ref,
            trackId: info.trackId,
          );
        },
      ),
      YourUploadsOptionRow(
        key: const Key('track_options_add_to_album'),
        icon: Icons.album_outlined,
        label: 'Add to album',
        onTap: () => _openAddToAlbum(context),
      ),
      const Divider(color: Colors.white12, height: 1),
      YourUploadsOptionRow(
        icon: Icons.person_outline,
        label: 'Go to profile',
        onTap: () async {
          final navigator = Navigator.of(context);
          final targetContext = navigator.context;
          navigator.pop();
          await _navigateToUploaderProfile(targetContext);
        },
      ),
      YourUploadsOptionRow(
        icon: Icons.comment_outlined,
        label: 'View comments',
        onTap: () {
          final navigator = Navigator.of(context);
          navigator.pop();
          navigator.push(
            MaterialPageRoute(
              builder: (_) => CommentsScreen(trackId: info.trackId),
            ),
          );
        },
      ),
      YourUploadsOptionRow(
        key: const Key('track_options_repost'),
        icon: isReposted ? Icons.repeat_on : Icons.repeat,
        label: isReposted ? 'Reposted' : 'Repost on SoundCloud',
        color: isReposted ? Colors.orange : Colors.white,
        onTap: () {
          final navigator = Navigator.of(context);
          final targetContext = navigator.context;
          navigator.pop();
          if (isReposted) {
            ref.read(engagementProvider(info.trackId).notifier).removeRepost();
            return;
          }

          RepostCaptionSheet.show(
            targetContext,
            trackId: info.trackId,
            trackTitle: info.title,
            artistName: info.artist,
            coverUrl: info.coverUrl,
          );
        },
      ),
      const Divider(color: Colors.white12, height: 1),
      YourUploadsOptionRow(
        icon: Icons.graphic_eq,
        label: 'Behind this track',
        onTap: () {
          final navigator = Navigator.of(context);
          final targetContext = navigator.context;
          navigator.pop();
          _navigateToBehindThisTrack(targetContext);
        },
      ),
    ];
  }

  Future<void> _navigateToUploaderProfile(BuildContext context) async {
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
      try {
        final ownerId = await ref.read(_trackOptionsOwnerProvider(info.trackId).future);
        if (ownerId != null && ownerId.trim().isNotEmpty) {
          userId = ownerId.trim();
        }
      } catch (_) {
        // Keep fallback behavior below.
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
    final item =
        stored ??
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

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TrackInfoScreen(item: item)));
  }
}

// ── Frosted track header ────────────────────────────────────────────────────

Future<void> editTrackFromOptions(
  BuildContext context,
  WidgetRef ref,
  TrackOptionInfo info,
) async {
  final navigator = Navigator.of(context);
  final uploadsNotifier = ref.read(libraryUploadsProvider.notifier);

  final item = await _resolveOptionUploadItem(ref, info);
  if (!context.mounted) return;

  navigator.pop();
  final result = await navigator.push<bool>(
    MaterialPageRoute(builder: (_) => EditTrackScreen(item: item)),
  );
  if (result == true) {
    await uploadsNotifier.refresh();
  }
}

Future<void> deleteTrackFromOptions(
  BuildContext context,
  WidgetRef ref,
  TrackOptionInfo info,
) async {
  final navigator = Navigator.of(context);
  final navigatorContext = navigator.context;
  final uploadsNotifier = ref.read(libraryUploadsProvider.notifier);

  final item = await _resolveOptionUploadItem(ref, info);
  if (!navigatorContext.mounted) return;

  navigator.pop();
  final confirmed = await confirmYourUploadsDeletion(navigatorContext, item);
  if (!confirmed) return;

  await uploadsNotifier.deleteTrack(info.trackId);
}

Future<void> downloadTrackFromOptions(
  BuildContext context,
  WidgetRef ref,
  TrackOptionInfo info,
) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final dio = ref.read(dioProvider);
  var subscriptionState = ref.read(subscriptionNotifierProvider);
  var currentSubscription = subscriptionState.currentSubscription;

  if (!subscriptionState.hasLoadedCurrent &&
      !subscriptionState.isCurrentLoading) {
    await ref
        .read(subscriptionNotifierProvider.notifier)
        .loadCurrentSubscription();
    subscriptionState = ref.read(subscriptionNotifierProvider);
    currentSubscription = subscriptionState.currentSubscription;
  }

  navigator.pop();

  if (currentSubscription.tier == SubscriptionTier.free) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('Upgrade to premium to download tracks.')),
    );
    return;
  }

  try {
    messenger?.showSnackBar(
      const SnackBar(
        duration: Duration(minutes: 1),
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Downloading track...'),
          ],
        ),
      ),
    );

    final response = await dio.get(ApiEndpoints.trackDownload(info.trackId));
    final downloadUrl = _readDownloadUrl(response.data);
    if (downloadUrl == null || downloadUrl.trim().isEmpty) {
      throw StateError('Download URL missing from response.');
    }

    final file = await _downloadTrackFile(downloadUrl: downloadUrl, info: info);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(content: Text('Downloaded to ${file.path}')),
    );
  } catch (error) {
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(content: Text(_downloadErrorMessage(error))),
    );
  }
}

Future<File> _downloadTrackFile({
  required String downloadUrl,
  required TrackOptionInfo info,
}) async {
  final directory = await _trackDownloadDirectory();
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final extension = _downloadExtension(downloadUrl);
  final safeTitle = _safeFileName(
    info.title.isEmpty ? info.trackId : info.title,
  );
  final file = File('${directory.path}/$safeTitle.$extension');
  final tempFile = File('${file.path}.download');

  if (await tempFile.exists()) {
    await tempFile.delete();
  }

  await Dio().download(downloadUrl, tempFile.path);

  if (await file.exists()) {
    await file.delete();
  }
  return tempFile.rename(file.path);
}

Future<Directory> _trackDownloadDirectory() async {
  if (Platform.isAndroid) {
    final external = await getExternalStorageDirectory();
    if (external != null) {
      return Directory('${external.path}/downloads');
    }
  }

  final documents = await getApplicationDocumentsDirectory();
  return Directory('${documents.path}/downloads');
}

String _downloadExtension(String url) {
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
  for (final ext in const ['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a']) {
    if (path.endsWith('.$ext')) return ext;
  }
  return 'mp3';
}

String _safeFileName(String value) {
  final sanitized = value
      .trim()
      .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
      .replaceAll(RegExp(r'\s+'), ' ');
  if (sanitized.isEmpty) return 'track';
  return sanitized.length > 80 ? sanitized.substring(0, 80).trim() : sanitized;
}

Future<UploadItem> _resolveOptionUploadItem(
  WidgetRef ref,
  TrackOptionInfo info,
) async {
  final stored = ref.read(globalTrackStoreProvider).find(info.trackId);
  final base = stored ?? _fallbackUploadItemFromOptions(info);

  try {
    final details = await ref
        .read(uploadRepositoryProvider)
        .getTrackDetails(info.trackId)
        .timeout(const Duration(seconds: 5));
    final merged = mergeTrackDetailItem(base: base, details: details);
    final ownerUserId = details.ownerUserId?.trim();
    if (ownerUserId != null && ownerUserId.isNotEmpty) {
      ref
          .read(globalTrackStoreProvider)
          .update(merged, ownerUserId: ownerUserId);
    }
    return merged;
  } catch (_) {
    return base;
  }
}

UploadItem _fallbackUploadItemFromOptions(TrackOptionInfo info) {
  return UploadItem(
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
}

String? _readDownloadUrl(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) {
      return data['downloadUrl']?.toString();
    }
    return raw['downloadUrl']?.toString();
  }
  return null;
}

String _downloadErrorMessage(Object error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 403) {
      return 'Download requires a premium plan and enabled downloads.';
    }
    if (statusCode == 404) {
      return 'This track is not available for download.';
    }
  }
  return 'We could not download this track right now.';
}

class FrostedTrackHeader extends StatelessWidget {
  const FrostedTrackHeader({super.key, required this.info});

  final TrackOptionInfo info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 84,
          child: Stack(
            children: [
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

              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.55)),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          Text(
                            info.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ── Section label ───────────────────────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});

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

class SendToRow extends StatelessWidget {
  const SendToRow({super.key, required this.info, required this.conversations});

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
          return SendToAvatar(info: info, conversation: conv);
        },
      ),
    );
  }
}

class SendToAvatar extends StatelessWidget {
  const SendToAvatar({
    super.key,
    required this.info,
    required this.conversation,
  });

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
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed(
      Routes.chat,
      arguments: {
        'conversationId': conversation.conversationId,
        'otherUserId': conversation.otherUser.id,
        'otherUserName': conversation.otherUser.displayName,
        'otherUserAvatar': conversation.otherUser.avatarUrl,
        'pendingAttachment': _trackMessageAttachment(info),
      },
    );
  }
}

// ── Share row (social + copy link) ─────────────────────────────────────────

class ShareRow extends StatelessWidget {
  const ShareRow({super.key, required this.info, required this.ref});

  final TrackOptionInfo info;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
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
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.push(
                MaterialPageRoute<void>(
                  builder: (_) => TrackShareToScreen(info: info),
                ),
              );
            },
          ),

          // Copy link
          YourUploadsShareButton(
            icon: Icons.copy_outlined,
            label: 'Copy link',
            onTap: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.maybeOf(context);
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              await Clipboard.setData(ClipboardData(text: url));
              if (!context.mounted) return;
              navigator.pop();
              messenger?.showSnackBar(
                const SnackBar(
                  content: Text('Link copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          YourUploadsShareButton(
            icon: Icons.qr_code_2,
            label: 'QR code',
            onTap: () async {
              final navigator = Navigator.of(context);
              final dialogContext = Navigator.of(
                context,
                rootNavigator: true,
              ).context;
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null || !context.mounted || !dialogContext.mounted) {
                return;
              }
              navigator.pop();
              await showTrackQrCodeDialog(dialogContext, url);
            },
          ),

          // WhatsApp
          SocialShareButton(
            faIcon: FontAwesomeIcons.whatsapp,
            iconColor: const Color(0xFF25D366),
            label: 'WhatsApp',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
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

          // SMS
          YourUploadsShareButton(
            icon: Icons.sms_outlined,
            label: 'SMS',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              final text = Uri.encodeComponent(
                'Check out "${info.title}" on Tunify: $url',
              );
              await launchUrl(
                Uri.parse('sms:?body=$text'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),

          // Instagram Stories
          SocialShareButton(
            faIcon: FontAwesomeIcons.instagram,
            iconColor: const Color(0xFFE1306C),
            label: 'Stories',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              // Instagram deep-link: opens the app
              await launchUrl(
                Uri.parse(
                  'instagram://sharesheet?text=${Uri.encodeComponent('Check out "${info.title}" on Tunify: $url')}',
                ),
                mode: LaunchMode.externalApplication,
              );
            },
          ),

          // Snapchat
          SocialShareButton(
            faIcon: FontAwesomeIcons.snapchat,
            iconColor: const Color(0xFFFFFC00),
            label: 'Snapchat',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              await launchUrl(
                Uri.parse(
                  'snapchat://send?text=${Uri.encodeComponent('Check out "${info.title}" on Tunify: $url')}',
                ),
                mode: LaunchMode.externalApplication,
              );
            },
          ),

          // Facebook
          SocialShareButton(
            faIcon: FontAwesomeIcons.facebook,
            iconColor: const Color(0xFF1877F2),
            label: 'Facebook',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              await launchUrl(
                Uri.parse(
                  'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}',
                ),
                mode: LaunchMode.externalApplication,
              );
            },
          ),

          // X (Twitter)
          SocialShareButton(
            faIcon: FontAwesomeIcons.xTwitter,
            iconColor: Colors.white,
            label: 'X',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              final text = Uri.encodeComponent(
                'Check out "${info.title}" on Tunify: $url',
              );
              await launchUrl(
                Uri.parse('https://twitter.com/intent/tweet?text=$text'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),

          // Messenger
          SocialShareButton(
            faIcon: FontAwesomeIcons.facebookMessenger,
            iconColor: const Color(0xFF0084FF),
            label: 'Messenger',
            onTap: () async {
              final url = await _buildTrackOptionShareUrl(context, info, ref);
              if (url == null) return;
              await launchUrl(
                Uri.parse(
                  'fb-messenger://share?link=${Uri.encodeComponent(url)}',
                ),
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

// QR code popup

Future<void> showTrackQrCodeDialog(BuildContext context, String url) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    builder: (context) {
      final screenWidth = MediaQuery.sizeOf(context).width;
      final qrSize = (screenWidth - 96).clamp(220.0, 330.0);

      return Dialog(
        backgroundColor: const Color(0xFF111111),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TrackQrCode(data: url, size: qrSize),
              const SizedBox(height: 26),
              const Text(
                'Others can scan this QR code with a smartphone\ncamera to see this content.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class TrackShareToScreen extends ConsumerStatefulWidget {
  const TrackShareToScreen({super.key, required this.info});

  final TrackOptionInfo info;

  @override
  ConsumerState<TrackShareToScreen> createState() => _TrackShareToScreenState();
}

class _TrackShareToScreenState extends ConsumerState<TrackShareToScreen> {
  String? _sendingConversationId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationsControllerProvider);
    final conversations = state.visible;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 12, 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _sendingConversationId == null
                        ? () => Navigator.of(context).pop()
                        : null,
                  ),
                  const Expanded(
                    child: Text(
                      'Share To',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF1F1F1F)),
            if (state.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (state.error != null && conversations.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Could not load chats',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else if (conversations.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No chats yet',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  color: Colors.white,
                  onRefresh: () => ref
                      .read(conversationsControllerProvider.notifier)
                      .refresh(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: conversations.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Color(0xFF1A1A1A)),
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final isSending =
                          _sendingConversationId == conversation.conversationId;
                      return _ShareConversationTile(
                        conversation: conversation,
                        isSending: isSending,
                        enabled: _sendingConversationId == null,
                        onTap: () => _sendToConversation(conversation),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendToConversation(ConversationEntity conversation) async {
    if (_sendingConversationId != null) return;
    setState(() => _sendingConversationId = conversation.conversationId);

    try {
      final chatProvider = chatControllerProvider(conversation.conversationId);
      await ref.read(chatProvider.notifier).sendAttachments([
        _trackMessageAttachment(widget.info),
      ]);
      final sendError = ref.read(chatProvider).error;
      if (sendError != null) {
        throw Exception(sendError);
      }

      if (!mounted) return;
      await Navigator.of(context).pushReplacementNamed(
        Routes.chat,
        arguments: {
          'conversationId': conversation.conversationId,
          'otherUserId': conversation.otherUser.id,
          'otherUserName': conversation.otherUser.displayName,
          'otherUserAvatar': conversation.otherUser.avatarUrl,
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not send track. Please try again.'),
        ),
      );
      setState(() => _sendingConversationId = null);
    }
  }
}

class _ShareConversationTile extends StatelessWidget {
  const _ShareConversationTile({
    required this.conversation,
    required this.isSending,
    required this.enabled,
    required this.onTap,
  });

  final ConversationEntity conversation;
  final bool isSending;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final user = conversation.otherUser;
    final avatar = user.avatarUrl?.trim();
    final preview = conversation.lastMessagePreview?.trim() ?? '';

    return Material(
      color: Colors.black,
      child: InkWell(
        onTap: enabled ? onTap : null,
        splashColor: Colors.white10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF2A2A2A),
                backgroundImage: avatar != null && avatar.isNotEmpty
                    ? NetworkImage(avatar)
                    : null,
                child: avatar == null || avatar.isEmpty
                    ? Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8A8A8A),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSending)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}

MessageAttachment _trackMessageAttachment(TrackOptionInfo info) {
  return MessageAttachment(
    id: info.trackId,
    type: MessageAttachmentType.track,
    backendKind: info.isOwned
        ? MessageAttachmentBackendKind.trackUpload
        : MessageAttachmentBackendKind.trackLike,
    title: info.title,
    subtitle: info.artist,
    artworkUrl: info.coverUrl,
  );
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
