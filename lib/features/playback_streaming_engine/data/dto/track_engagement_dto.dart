class TrackEngagementDto {
  const TrackEngagementDto({
    required this.likeCount,
    required this.commentCount,
    required this.repostCount,
    required this.isLiked,
    required this.isReposted,
    required this.isSaved,
  });
// integrate with the track engagement endpoint to get real-time like/comment/repost counts and user engagement status for the currently playing track. This can be used to update the UI (e.g. like button state) and show engagement metrics in the player.
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final bool isLiked;
  final bool isReposted;
  final bool isSaved;

  factory TrackEngagementDto.fromJson(Map<String, dynamic> json) {
    return TrackEngagementDto(
      likeCount: (json['likeCount'] as int?) ?? 0,
      commentCount: (json['commentCount'] as int?) ?? 0,
      repostCount: (json['repostCount'] as int?) ?? 0,
      isLiked: (json['isLiked'] as bool?) ?? false,
      isReposted: (json['isReposted'] as bool?) ?? false,
      isSaved: (json['isSaved'] as bool?) ?? false,
    );
  }
}
