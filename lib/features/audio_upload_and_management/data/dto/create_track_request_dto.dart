class CreateTrackRequestDto {
  final String userId;
  final bool contentWarning;
  final String? scheduledReleaseDate;

  CreateTrackRequestDto({
    required this.userId,
    this.contentWarning = false,
    this.scheduledReleaseDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'contentWarning': contentWarning,
      'scheduledReleaseDate': scheduledReleaseDate,
    };
  }
}