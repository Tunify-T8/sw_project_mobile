import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../followers_and_social_graph/domain/repositories/social_graph_repository.dart';
import '../../../followers_and_social_graph/presentation/providers/network_lists_notifier.dart';
import '../../../followers_and_social_graph/presentation/providers/social_graph_repository_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_share_sheet.dart';
import '../widgets/user_options_sheet.dart';
import '../../../engagements_social_interactions/presentation/widgets/profile_reposts_section.dart';

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

  bool _isFollowing = false;
  bool _followLoading = true;

  final nameStyle = const TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  late final followerStyle =
      TextStyle(fontSize: 18, color: Colors.grey.shade200);
  late final bioStyle =
      TextStyle(fontSize: 16, color: Colors.grey.shade400, height: 1.5);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref
          .read(userProfileProvider.notifier)
          .loadProfile(widget.userId);
      await _loadFollowStatus();
    });
  }

  Future<void> _loadFollowStatus() async {
    try {
      final repo = ref.read(socialGraphRepositoryProvider);
      final relation = await repo.getFollowStatus(widget.userId);
      if (mounted) {
        setState(() {
          _isFollowing = relation.isFollowing;
          _followLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    final repo = ref.read(socialGraphRepositoryProvider);
    final wasFollowing = _isFollowing;
    setState(() => _isFollowing = !wasFollowing);
    try {
      if (wasFollowing) {
        await repo.unfollowUser(widget.userId);
      } else {
        await repo.followUser(widget.userId);
      }
      await _syncAfterFollowChange(!wasFollowing);
    } catch (_) {
      if (mounted) setState(() => _isFollowing = wasFollowing);
    }
  }

  // Called by the three dots sheet after it already made the API call
  Future<void> _applyFollowChange() async {
    setState(() => _isFollowing = !_isFollowing);
    await _syncAfterFollowChange(_isFollowing);
  }

  Future<void> _syncAfterFollowChange(bool nowFollowing) async {
    ref.read(networkListsProvider.notifier).updateFollowStatus(
          userId: widget.userId,
          isFollowing: nowFollowing,
        );
    await ref.read(userProfileProvider.notifier).loadProfile(widget.userId);
    await ref.read(profileProvider.notifier).loadProfile();
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          _followLoading
              ? const SizedBox(
                  width: 100,
                  height: 36,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : OutlinedButton(
                  onPressed: _toggleFollow,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                  ),
                  child: Text(_isFollowing ? 'Following' : 'Follow'),
                ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.mail_outline, color: Colors.white),
            onPressed: () {},
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
              icon: const Icon(Icons.play_arrow,
                  color: Colors.black, size: 28),
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
          IconButton(
            icon: const Icon(Icons.cast),
            onPressed: () {},
          ),
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
                      isFollowing: _isFollowing,
                      onFollowChanged: _applyFollowChange,
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
                        actionButtons: _buildActionButtons(),
                      ),
                      ProfileRepostsSection(userId: widget.userId),
                    ],
                  ),
                ),
    );
  }
}
