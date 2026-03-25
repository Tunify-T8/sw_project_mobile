class TrackInteractionEntity {
  final bool isLiked;
  final bool isReposted;

  TrackInteractionEntity({
    required this.isLiked,
    required this.isReposted,
  });

  TrackInteractionEntity copyWith({
    bool? isLiked,
    bool? isReposted,
  }) {
    return TrackInteractionEntity(
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
    );
  }
}