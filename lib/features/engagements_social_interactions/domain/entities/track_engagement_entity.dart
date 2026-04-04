class TrackEngagementEntity {
  const TrackEngagementEntity({
    required this.trackId,
    required this.likeCount,
    required this.repostCount,
    required this.commentCount,
    required this.isLiked,
    required this.isReposted,
  });

  final String trackId;
  final int likeCount;
  final int repostCount;
  final int commentCount;
  final bool isLiked;
  final bool isReposted;
}