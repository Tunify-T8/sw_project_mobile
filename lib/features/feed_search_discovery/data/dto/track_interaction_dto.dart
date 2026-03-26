class TrackInteractionDto {
  final bool isLiked;
  final bool isReposted;

  TrackInteractionDto({required this.isLiked, required this.isReposted});

  factory TrackInteractionDto.fromJson(Map<String, dynamic> json){
    return TrackInteractionDto(
      isLiked: json['isLiked'] ?? false,
      isReposted: json['isReposted'] ?? false,
    );
  }
}