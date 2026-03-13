import 'social_user_entity.dart';

class NetworkListsState {
  final List<SocialUserEntity> followingUsers;
  final List<SocialUserEntity> followersUsers;
  final bool isLoadingFollowing;
  final bool isLoadingFollowers;
  final String? error;

  const NetworkListsState({
    this.followingUsers = const [],
    this.followersUsers = const [],
    this.isLoadingFollowing = false,
    this.isLoadingFollowers = false,
    this.error,
  });

  NetworkListsState copyWith({
    List<SocialUserEntity>? followingUsers,
    List<SocialUserEntity>? followerUsers,
    bool? isLoadingFollowing,
    bool? isLoadingFollowers,
    String? error,
  }) {
    return NetworkListsState(
      followingUsers: followingUsers ?? this.followingUsers,
      followersUsers: followerUsers ?? this.followersUsers,
      isLoadingFollowing: isLoadingFollowing ?? this.isLoadingFollowing,
      isLoadingFollowers: isLoadingFollowers ?? this.isLoadingFollowers,
      error: error,
    );
  }
}