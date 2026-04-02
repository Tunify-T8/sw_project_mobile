class TrendingTrackEntity {
  final String title;
  final String artistName;
  final String? coverUrl;
  final bool isLiked;
  final bool isReposted;

  TrendingTrackEntity({
    required this.title,
    required this.artistName,
    this.coverUrl,
    required this.isLiked,
    required this.isReposted,
  });

  TrendingTrackEntity copyWith({
    String? title,
    String? artistName,
    String? coverUrl,
    bool? isLiked,
    bool? isReposted,
  }) {
    return TrendingTrackEntity(
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      coverUrl: coverUrl ?? this.coverUrl,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
    );
  }
}