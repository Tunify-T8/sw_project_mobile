import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'track_options_header.dart';
import 'track_actions.dart';
import 'track_option_menu_item.dart';
import 'track_social_actions.dart';
import 'track_feed_actions.dart';
import 'track_more_actions.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../../features/engagements_social_interactions/presentation/provider/engagement_state.dart';
import '../../../../features/engagements_social_interactions/presentation/screens/comments_screen.dart';
import '../../../../features/messaging_track_sharing/presentation/state/conversations_controller.dart';
import '../../../../features/playback_streaming_engine/presentation/widgets/track_options_sheet.dart';
import '../../../../features/playback_streaming_engine/presentation/utils/track_artist_resolver.dart';
import '../../../../features/premium_subscription/domain/entities/subscription_tier.dart';
import '../../../../features/premium_subscription/presentation/providers/subscription_notifier.dart';

Future<void> showTrackOptionsMenu({
  required BuildContext context,
  required String trackId,
  required String title,
  required String artistId,
  required String artistName,
  String? coverUrl,
  String? localArtworkPath,
  bool? initialIsLiked,
  bool? initialIsReposted,
  bool isDiscoverFeed = false,
  bool isFollowingFeed = false,
  bool isBehindTrack = false,
}) {
  final isFeedMenu =
      isDiscoverFeed ||
      isFollowingFeed ||
      (initialIsLiked != null && initialIsReposted != null);

  if (isFeedMenu) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => TrackOptionsMenu(
        trackId: trackId,
        title: title,
        artistId: artistId,
        artistName: artistName,
        coverUrl: coverUrl,
        localArtworkPath: localArtworkPath,
        initialIsLiked: initialIsLiked,
        initialIsReposted: initialIsReposted,
        isDiscoverFeed: isDiscoverFeed,
        isFollowingFeed: isFollowingFeed,
        isBehindTrack: isBehindTrack,
        allowDownloadAction: false,
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Consumer(
      builder: (context, ref, _) {
        final resolvedArtistId =
            resolveArtistIdForTrackLocally(
              ref,
              trackId,
              fallbackArtistId: artistId,
            ) ??
            artistId;
        final currentUserId = ref.read(authControllerProvider).value?.id;
        final info = TrackOptionInfo.fromTrackId(
          trackId,
          ref,
          fallbackTitle: title,
          fallbackArtist: artistName,
          fallbackArtistId: resolvedArtistId,
          fallbackCoverUrl: coverUrl,
          fallbackLocalArtworkPath: localArtworkPath,
          fallbackIsOwned: currentUserId == resolvedArtistId,
        );

        return TrackOptionsSheetContent(info: info, ref: ref);
      },
    ),
  );
}

class TrackOptionsMenu extends ConsumerStatefulWidget {
  final String trackId;
  final String title;
  final String artistId;
  final String artistName;
  final String? coverUrl;
  final String? localArtworkPath;
  final bool? initialIsLiked;
  final bool? initialIsReposted;
  final bool isDiscoverFeed;
  final bool isFollowingFeed;
  final bool isBehindTrack;
  final bool allowDownloadAction;

  const TrackOptionsMenu({
    super.key,
    required this.trackId,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.coverUrl,
    this.localArtworkPath,
    this.initialIsLiked,
    this.initialIsReposted,
    this.isDiscoverFeed = false,
    this.isFollowingFeed = false,
    this.isBehindTrack = false,
    this.allowDownloadAction = true,
  });

  @override
  ConsumerState<TrackOptionsMenu> createState() => _TrackOptionsMenuState();
}

class _TrackOptionsMenuState extends ConsumerState<TrackOptionsMenu> {
  late String _resolvedArtistId;

  @override
  void initState() {
    super.initState();
    _resolvedArtistId =
        resolveArtistIdForTrackLocally(
          ref,
          widget.trackId,
          fallbackArtistId: widget.artistId,
        ) ??
        widget.artistId;

    if (widget.initialIsLiked == null || widget.initialIsReposted == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final state = ref.read(engagementProvider(widget.trackId));

        if (state.engagementStatus == EngagementStatus.initial) {
          ref
              .read(engagementProvider(widget.trackId).notifier)
              .loadEngagement();
        }
      });
    }

    if (_resolvedArtistId.trim().isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resolveArtistId());
    }
  }

  Future<void> _resolveArtistId() async {
    final artistId = await resolveArtistIdForTrack(
      ref,
      widget.trackId,
      fallbackArtistId: widget.artistId,
    );
    if (!mounted || artistId == null || artistId == _resolvedArtistId) {
      return;
    }
    setState(() => _resolvedArtistId = artistId);
  }

  @override
  Widget build(BuildContext context) {
    final engagement =
        (widget.initialIsLiked == null || widget.initialIsReposted == null)
        ? ref.watch(engagementProvider(widget.trackId)).engagement
        : null;

    final isLiked = widget.initialIsLiked ?? engagement?.isLiked ?? false;
    final isReposted =
        widget.initialIsReposted ?? engagement?.isReposted ?? false;

    final conversations = ref.watch(conversationsControllerProvider).items;

    final info = TrackOptionInfo(
      trackId: widget.trackId,
      title: widget.title,
      artist: widget.artistName,
      artistId: _resolvedArtistId,
      coverUrl: widget.coverUrl,
      localArtworkPath: widget.localArtworkPath,
      isOwned: ref.read(authControllerProvider).value?.id == _resolvedArtistId,
    );

    final String? myId = ref.read(authControllerProvider).value?.id;
    final isMyTrack = (myId == _resolvedArtistId);
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final currentSubscription = subscriptionState.currentSubscription;
    final canDownload = currentSubscription?.tier != SubscriptionTier.free;

    if (!subscriptionState.hasLoadedCurrent &&
        !subscriptionState.isCurrentLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(subscriptionNotifierProvider.notifier)
            .loadCurrentSubscription();
      });
    }

    return ListView(
      children: [
        const SizedBox(height: 8),

        TrackOptionsHeader(
          title: widget.title,
          artistName: widget.artistName,
          coverUrl: widget.coverUrl,
          localArtworkPath: widget.localArtworkPath,
        ),

        if (conversations.isNotEmpty) ...[
          const SectionLabel(label: 'SEND TO'),
          SendToRow(info: info, conversations: conversations),
        ],

        const SectionLabel(label: 'SHARE'),
        ShareRow(info: info, ref: ref),

        const Divider(color: Colors.white12, height: 1),

        if (canDownload && widget.allowDownloadAction) ...[
          TrackOptionMenuItem(
            key: const Key('track_options_menu_download_premium_action'),
            icon: Icons.download_outlined,
            label: 'Download track',
            onTap: () => downloadTrackFromOptions(context, ref, info),
          ),
          const Divider(color: Colors.white12, height: 1),
        ],

        if (isMyTrack) ...[
          TrackOptionMenuItem(
            icon: Icons.edit,
            label: 'Edit track',
            onTap: () => editTrackFromOptions(context, ref, info),
          ),
          const Divider(color: Colors.white12, height: 1),
        ],

        TrackActions(
          trackId: widget.trackId,
          isLiked: isLiked,
          isMyTrack: isMyTrack,
          isDiscoverFeed: widget.isDiscoverFeed,
          isFollowingFeed: widget.isFollowingFeed,
        ),

        const Divider(color: Colors.white12),

        if (!isMyTrack) ...[
          TrackSocialActions(
            trackId: widget.trackId,
            artistId: _resolvedArtistId,
            title: widget.title,
            artistName: widget.artistName,
            coverUrl: widget.coverUrl,
            isReposted: isReposted,
          ),
          const Divider(color: Colors.white12),
        ],
        if (widget.isDiscoverFeed || widget.isFollowingFeed) ...[
          TrackFeedActions(isDiscoverFeed: widget.isDiscoverFeed),
          const Divider(color: Colors.white12),
        ],

        TrackMoreActions(
          isMyTrack: isMyTrack,
          isBehindTrack: widget.isBehindTrack,
        ),

        if (isMyTrack) ...[
          TrackOptionMenuItem(
            key: const Key('track_options_comment_item'),
            icon: Icons.comment_outlined,
            label: 'View comments',
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.push(
                MaterialPageRoute(
                  builder: (_) => CommentsScreen(trackId: widget.trackId),
                ),
              );
            },
          ),
          const Divider(color: Colors.white12),
          TrackOptionMenuItem(
            icon: Icons.delete,
            color: Colors.red,
            label: 'Delete track',
            onTap: () => deleteTrackFromOptions(context, ref, info),
          ),
        ],
      ],
    );
  }
}
