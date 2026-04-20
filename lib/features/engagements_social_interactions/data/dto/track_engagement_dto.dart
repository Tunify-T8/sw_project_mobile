class TrackEngagementDto {
  const TrackEngagementDto({
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

  factory TrackEngagementDto.fromJson(Map<String, dynamic> json) {
    return TrackEngagementDto(
      trackId: (json['trackId'] as String?) ?? '',
      likeCount: (json['likesCount'] as int?) ?? (json['likeCount'] as int?) ?? 0,
      repostCount: (json['repostsCount'] as int?) ?? (json['repostCount'] as int?) ?? 0,
      commentCount: (json['commentsCount'] as int?) ?? (json['commentCount'] as int?) ?? 0,
      isLiked: (json['isLiked'] as bool?) ?? false,
      isReposted: (json['isReposted'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'likeCount': likeCount,
      'repostCount': repostCount,
      'commentCount': commentCount,
      'isLiked': isLiked,
      'isReposted': isReposted,
    };
  }
}
