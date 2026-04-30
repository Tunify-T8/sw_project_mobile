import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/routes.dart';
import '../../../audio_upload_and_management/presentation/providers/public_user_uploads_provider.dart';
import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../playback_streaming_engine/presentation/widgets/mini_player.dart';
import '../../../audio_upload_and_management/presentation/utils/upload_player_launcher.dart';
import '../../../messaging_track_sharing/presentation/providers/messaging_usecases_provider.dart';
import '../../../messaging_track_sharing/presentation/providers/messaging_dependencies_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_share_sheet.dart';
import '../widgets/profile_tracks_section.dart';
import '../widgets/user_options_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../followers_and_social_graph/presentation/widgets/relationship_button.dart';
import '../../../followers_and_social_graph/presentation/providers/relationship_status_notifier.dart';
import '../../../followers_and_social_graph/presentation/providers/social_graph_repository_provider.dart';
import '../../../engagements_social_interactions/presentation/widgets/profile_reposts_section.dart';
import '../../../engagements_social_interactions/presentation/widgets/profile_likes_section.dart';
import '../../../playlists/domain/entities/collection_type.dart';
import '../../../playlists/presentation/widgets/profile_playlists_section.dart';
import '../../../../shared/ui/widgets/play_button.dart';
import '../../../../shared/ui/patterns/error_retry_view.dart';

class OtherUserProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<OtherUserProfileScreen> createState() =>
      _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState
    extends ConsumerState<OtherUserProfileScreen> {
  final double profileHeight = 150;
  final double coverHeight = 150;

  final nameStyle = const TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  late final followerStyle = TextStyle(
    fontSize: 18,
    color: Colors.grey.shade200,
  );
  late final bioStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey.shade400,
    height: 1.5,
  );

  bool _openingChat = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(userProfileProvider.notifier).loadProfile(widget.userId);
    });
  }

  /// Opens an existing or new chat with this user.
  /// Enforces the privacy rule client-side: by default a user only accepts
  /// messages from people they follow. We check whether the target follows
  /// us before creating the conversation, and show a friendly popup if not.
  Future<void> _openChat(String displayName, String? avatarUrl) async {
    if (_openingChat) return;
    setState(() => _openingChat = true);
    try {
      final myUserId = ref.read(authControllerProvider).value?.id;
      if (myUserId == null || myUserId.isEmpty) {
        throw StateError('Not signed in');
      }

      final theyFollowMe = await ref
          .read(socialGraphRepositoryProvider)
          .doesUserFollowMe(widget.userId, myUserId);

      if (!theyFollowMe) {
        if (!mounted) return;
        _showCannotMessageDialog(displayName);
        return;
      }

      ref
          .read(mockMessagingStoreProvider)
          .registerUserPreview(
            id: widget.userId,
            displayName: displayName,
            avatarUrl: avatarUrl,
          );

      final conversationId = await ref
          .read(openConversationUseCaseProvider)
          .call(widget.userId);
      if (!mounted) return;
      await Navigator.of(context).pushNamed(
        Routes.chat,
        arguments: {
          'conversationId': conversationId,
          'otherUserId': widget.userId,
          'otherUserName': displayName,
          'otherUserAvatar': avatarUrl,
        },
      );
    } catch (e) {
      if (!mounted) return;
      final message = _friendlyConversationError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF2A2A2A),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  void _showCannotMessageDialog(String displayName) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Can\'t send message',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '$displayName only accepts messages from people they follow.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyConversationError(Object e) {
    final raw = e.toString().toLowerCase();
    if (raw.contains('403') ||
        raw.contains('forbidden') ||
        raw.contains('not follow') ||
        raw.contains('blocked')) {
      return 'You can\'t message this user. They only accept messages from people they follow.';
    }
    if (raw.contains('404') || raw.contains('not found')) {
      return 'Could not find this user. Please try again.';
    }
    return 'Could not open chat. Please try again.';
  }

  Widget _buildActionButtons(
    bool isBlocked,
    String displayName,
    String? avatarUrl,
    List<UploadItem> profileTracks,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          if (isBlocked)
            const Icon(Icons.block, color: Colors.white)
          else
            RelationshipButton(userId: widget.userId),
          const SizedBox(width: 12),
          IconButton(
            icon: _openingChat
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.mail_outline, color: Colors.white),
            onPressed: _openingChat
                ? null
                : () => _openChat(displayName, avatarUrl),
          ),
          const Spacer(),
          ShuffleButton(
            onTap: profileTracks.isEmpty
                ? null
                : () {
                    final shuffled = List.of(profileTracks)..shuffle();
                    openUploadItemPlayer(
                      context,
                      ref,
                      shuffled.first,
                      queueItems: shuffled,
                      openScreen: false,
                    );
                  },
          ),
          PlayButton(
            onTap: profileTracks.isEmpty
                ? null
                : () => openUploadItemPlayer(
                    context,
                    ref,
                    profileTracks.first,
                    queueItems: profileTracks,
                    openScreen: false,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileProvider);
    final relationshipState = ref.watch(
      relationshipStatusProvider(widget.userId),
    );
    final profile = state.profile;
    final profileDisplayName = _displayName(
      profile?.displayName,
      profile?.userName,
    );
    final profileTracks =
        ref.watch(publicUserUploadsProvider(widget.userId)).asData?.value ??
        const <UploadItem>[];

    return Scaffold(
      bottomNavigationBar: const MiniPlayer(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.cast), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: profile == null
                ? null
                : () => UserOptionsSheet.show(
                    context: context,
                    userId: widget.userId,
                    userName: profile.userName,
                    avatarUrl: profile.profileImagePath,
                    followersCount: profile.followersCount ?? 0,
                    tracksCount: profile.tracksCount ?? 0,
                    isFollowing: relationshipState.isFollowing ?? false,
                    isBlocked: relationshipState.isBlocked ?? false,
                    onFollowChanged: () async {
                      await ref
                          .read(
                            relationshipStatusProvider(widget.userId).notifier,
                          )
                          .toggleFollow();

                      await ref
                          .read(userProfileProvider.notifier)
                          .loadProfile(widget.userId);

                      await ref.read(profileProvider.notifier).loadProfile();
                    },
                    onBlockChanged: () {
                      ref
                          .read(
                            relationshipStatusProvider(widget.userId).notifier,
                          )
                          .toggleBlock();
                    },
                  ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.isError
          ? ErrorRetryView(
              onRetry: () => ref
                  .read(userProfileProvider.notifier)
                  .loadProfile(widget.userId),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(
                    coverHeight: coverHeight,
                    profileHeight: profileHeight,
                    coverUrl: profile?.coverImagePath,
                    profileUrl: profile?.profileImagePath,
                  ),
                  SizedBox(height: profileHeight / 2 + 8),
                  ProfileInfo(
                    displayName:
                        profile?.displayName ?? profile?.userName ?? '',
                    userName: profile?.userName ?? '',
                    city: profile?.city ?? '',
                    country: profile?.country ?? '',
                    bio: profile?.bio ?? '',
                    followersCount: profile?.followersCount ?? 0,
                    followingCount: profile?.followingCount ?? 0,
                    isCertified: profile?.isCertified ?? false,
                    nameStyle: nameStyle,
                    bioStyle: bioStyle,
                    followerStyle: followerStyle,
                    userId: widget.userId,
                    onShowMore: () => ProfileShareSheet(
                      context: context,
                      userName: profile?.userName ?? '',
                      bio: profile?.bio ?? '',
                      followersCount: profile?.followersCount ?? 0,
                      tracksCount: profile?.tracksCount ?? 0,
                      profileImage: null,
                      profileImagePath: profile?.profileImagePath,
                      instagram: profile?.instagram,
                      twitter: profile?.twitter,
                      youtube: profile?.youtube,
                      spotify: profile?.spotify,
                      tiktok: profile?.tiktok,
                      soundcloud: profile?.soundcloud,
                      bioStyle: bioStyle,
                    ).showInfoSheet(),
                    actionButtons: _buildActionButtons(
                      relationshipState.isBlocked ?? false,
                      profileDisplayName,
                      profile?.profileImagePath,
                      profileTracks,
                    ),
                  ),
                  _OtherUserTracksSection(userId: widget.userId),
                  ProfilePlaylistsSection(
                    username: profile?.userName,
                    ownerName: profileDisplayName,
                  ),
                  ProfilePlaylistsSection(
                    username: profile?.userName,
                    ownerName: profileDisplayName,
                    collectionType: CollectionType.album,
                    title: 'Albums',
                  ),
                  ProfileLikesSection(userId: widget.userId),
                  ProfileRepostsSection(userId: widget.userId),
                ],
              ),
            ),
    );
  }

  String _displayName(String? displayName, String? userName) {
    final display = displayName?.trim() ?? '';
    if (display.isNotEmpty) return display;
    final username = userName?.trim() ?? '';
    return username.isEmpty ? 'Unknown User' : username;
  }
}

class _OtherUserTracksSection extends ConsumerWidget {
  const _OtherUserTracksSection({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(publicUserUploadsProvider(userId));

    final items = tracksAsync.asData?.value ?? const [];

    return ProfileTracksSection(
      items: items,
      onTrackTap: (item) {
        openUploadItemPlayer(context, ref, item, queueItems: items);
      },
    );
  }
}
