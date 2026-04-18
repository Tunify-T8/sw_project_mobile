import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/routes.dart';
import '../../../audio_upload_and_management/presentation/providers/public_user_uploads_provider.dart';
import '../../../audio_upload_and_management/presentation/screens/track_detail_screen.dart';
import '../../../followers_and_social_graph/presentation/providers/network_lists_notifier.dart';
import '../../../messaging_track_sharing/domain/usecases/open_conversation_usecase.dart';
import '../../../messaging_track_sharing/presentation/providers/messaging_usecases_provider.dart';
import '../../../messaging_track_sharing/presentation/providers/messaging_dependencies_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_share_sheet.dart';
import '../widgets/profile_tracks_section.dart';
import '../widgets/user_options_sheet.dart';
import '../../../followers_and_social_graph/presentation/widgets/relationship_button.dart';
import '../../../followers_and_social_graph/presentation/providers/relationship_status_notifier.dart';

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
  /// Uses [OpenConversationUseCase] which calls createOrGetConversation,
  /// then navigates to the ChatScreen.
  Future<void> _openChat(String displayName, String? avatarUrl) async {
    if (_openingChat) return;
    setState(() => _openingChat = true);
    try {
      ref.read(mockMessagingStoreProvider).registerUserPreview(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open chat: $e'),
          backgroundColor: const Color(0xFF2A2A2A),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  Widget _buildActionButtons(bool isBlocked, String displayName, String? avatarUrl) {
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
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          // FIX: Wire the mail icon to open/create a chat conversation.
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
          IconButton(
            icon: const Icon(Icons.shuffle, color: Colors.white, size: 28),
            onPressed: () {},
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.black, size: 28),
              onPressed: () {},
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

    return Scaffold(
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
          ? Center(
              child: Text(
                state.errorMessage ?? 'Error loading profile',
                style: const TextStyle(color: Colors.white),
              ),
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
                      profile?.userName ?? '',
                      profile?.profileImagePath,
                    ),
                  ),
                  _OtherUserTracksSection(userId: widget.userId),
                ],
              ),
            ),
    );
  }
}

class _OtherUserTracksSection extends ConsumerWidget {
  const _OtherUserTracksSection({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(publicUserUploadsProvider(userId));

    // Mirror my-profile behaviour: while loading or on error, show the same
    // ProfileTracksSection with an empty list so the "No uploaded tracks yet."
    // placeholder matches exactly. No new UI is introduced here.
    final items = tracksAsync.asData?.value ?? const [];

    return ProfileTracksSection(
      items: items,
      onTrackTap: (item) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TrackDetailScreen(item: item),
          ),
        );
      },
    );
  }
}