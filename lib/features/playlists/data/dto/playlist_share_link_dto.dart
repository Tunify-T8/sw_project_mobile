class PlaylistShareLinkDto {
  const PlaylistShareLinkDto({
    required this.shareUrl,
    this.appUrl,
  });

  final String shareUrl;
  final String? appUrl;

  factory PlaylistShareLinkDto.fromJson(Map<String, dynamic> json) {
    return PlaylistShareLinkDto(
      shareUrl: json['shareUrl'] as String,
      appUrl: json['appUrl'] as String?,
    );
  }
}
