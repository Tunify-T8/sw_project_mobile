class SocialUserEntity {
  final String userID;
  final String userDisplayName;
  final String avatarUrl;
  final int followersCount;
  final int followingCount; 
  final bool isFollowing;
  final bool isBlocked;
  final bool isDeleted;
  final bool isNotificationEnabled; //need to tell backend
  final bool isTrueFriend; //need to tell backend & check if we need it
  final bool isVerified; //tell backend
  //will see about those
  //final bool isArtist; 
  //final bool cityName; //change name!

  const SocialUserEntity({
    required this.userID,
    required this.userDisplayName,
    required this.avatarUrl,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
    required this.isBlocked,
    required this.isDeleted,
    required this.isNotificationEnabled,
    required this.isTrueFriend,
    required this.isVerified
  });

  SocialUserEntity copyWith({
  String? userID,
  String? userDisplayName,
  String? avatarUrl,
  int? followersCount,
  int? followingCount,
  bool? isFollowing,
  bool? isBlocked,
  bool? isDeleted,
  bool? isNotificationEnabled,
  bool? isTrueFriend,
  bool? isVerified,
}) {
  return SocialUserEntity(
    userID: userID ?? this.userID,
    userDisplayName: userDisplayName ?? this.userDisplayName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    followersCount: followersCount ?? this.followersCount,
    followingCount: followingCount ?? this.followingCount,
    isFollowing: isFollowing ?? this.isFollowing,
    isBlocked: isBlocked ?? this.isBlocked,
    isDeleted: isDeleted ?? this.isDeleted,
    isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
    isTrueFriend: isTrueFriend?? this.isTrueFriend,
    isVerified: isVerified?? this.isVerified,
  );
}
}