/// Engagement counters + authenticated user's interaction state.
class TrackEngagement {
  const TrackEngagement({
    required this.likeCount,
    required this.commentCount,
    required this.repostCount,
    required this.isLiked,
    required this.isReposted,
    required this.isSaved,
  });

  final int likeCount;
  final int commentCount;
  final int repostCount;
  final bool isLiked;
  final bool isReposted;
  final bool isSaved;

  TrackEngagement copyWith({
    int? likeCount,
    int? commentCount,
    int? repostCount,
    bool? isLiked,
    bool? isReposted,
    bool? isSaved,
  }) {
    return TrackEngagement(
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      repostCount: repostCount ?? this.repostCount,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
