import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/global_track_store.dart';
import '../../../domain/entities/upload_item.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../followers_and_social_graph/presentation/providers/relationship_status_notifier.dart';
import '../../../../playback_streaming_engine/presentation/utils/track_artist_resolver.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class TrackDetailHeader extends ConsumerStatefulWidget {
  const TrackDetailHeader({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.onArtistTap,
    required this.onTrackInfoTap,
  });

  final UploadItem item;
  final VoidCallback onDismiss;
  final VoidCallback onArtistTap;
  final VoidCallback onTrackInfoTap;

  @override
  ConsumerState<TrackDetailHeader> createState() => _TrackDetailHeaderState();
}

class _TrackDetailHeaderState extends ConsumerState<TrackDetailHeader> {
  late String _resolvedArtistId;

  @override
  void initState() {
    super.initState();
    _resolvedArtistId = _resolveArtistIdLocally();

    if (_resolvedArtistId.trim().isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resolveArtistId());
    }
  }

  @override
  void didUpdateWidget(covariant TrackDetailHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id == widget.item.id) return;

    _resolvedArtistId = _resolveArtistIdLocally();
    if (_resolvedArtistId.trim().isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resolveArtistId());
    }
  }

  String _resolveArtistIdLocally() {
    return resolveArtistIdForTrackLocally(ref, widget.item.id) ?? '';
  }

  Future<void> _resolveArtistId() async {
    final trackId = widget.item.id;
    final artistId = await resolveArtistIdForTrack(ref, trackId);
    if (!mounted ||
        widget.item.id != trackId ||
        artistId == null ||
        artistId == _resolvedArtistId) {
      return;
    }
    setState(() => _resolvedArtistId = artistId);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        ref.watch(authControllerProvider).asData?.value?.id.trim() ?? '';
    final ownerUserId = ref
        .watch(globalTrackStoreProvider)
        .ownerUserIdForTrack(widget.item.id)
        ?.trim();
    final artistId = _resolvedArtistId.trim();
    final isOwnedTrack =
        currentUserId.isNotEmpty &&
        ((ownerUserId != null &&
                ownerUserId.isNotEmpty &&
                ownerUserId != '__global__' &&
                ownerUserId == currentUserId) ||
            artistId == currentUserId);
    final showFollowIcon = !isOwnedTrack && artistId.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BlackTag(
                    text: widget.item.title,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    onTap: widget.onTrackInfoTap,
                  ),
                  const SizedBox(height: 4),
                  _BlackTag(
                    text: widget.item.artistDisplay,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    onTap: widget.onArtistTap,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTrackInfoTap,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.82),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.graphic_eq,
                            color: Colors.white70,
                            size: 17,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Behind this track',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                _CircleAction(
                  size: 58,
                  backgroundColor: Colors.black,
                  icon: Icons.keyboard_arrow_down_rounded,
                  iconSize: 34,
                  onTap: widget.onDismiss,
                ),
                if (showFollowIcon) ...[
                  const SizedBox(height: 28),
                  _FollowSideIcon(artistId: artistId),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowSideIcon extends ConsumerWidget {
  const _FollowSideIcon({required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authControllerProvider).value?.id;

    if (artistId.trim().isEmpty) {
      return const _SideIcon(icon: Icons.person_add_alt_1_outlined);
    }

    final relationshipState = ref.watch(relationshipStatusProvider(artistId));
    final isFollowing = relationshipState.isFollowing ?? false;

    return (currentUserId != artistId) ?
    GestureDetector(
      onTap: () => ref.read(relationshipStatusProvider(artistId).notifier).toggleFollow(),
      child: Icon(
        isFollowing
            ? Icons.person_remove_alt_1_outlined
            : Icons.person_add_alt_1_outlined,
        color: Colors.white70,
        size: 34,
      ),
    ): SizedBox.shrink();
  }
}

class _BlackTag extends StatelessWidget {
  const _BlackTag({
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.onTap,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: Colors.black.withValues(alpha: 0.82),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.size,
    required this.backgroundColor,
    required this.icon,
    required this.iconSize,
    required this.onTap,
  });

  final double size;
  final Color backgroundColor;
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}
