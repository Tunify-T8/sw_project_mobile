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

  TrackEngagementEntity copyWith({
    int? commentCount,
    int? likeCount,
    int? repostCount,
    bool? isLiked,
    bool? isReposted,
  }) {
    return TrackEngagementEntity(
      trackId: trackId,
      likeCount: likeCount ?? this.likeCount,
      repostCount: repostCount ?? this.repostCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
    );
  }
}