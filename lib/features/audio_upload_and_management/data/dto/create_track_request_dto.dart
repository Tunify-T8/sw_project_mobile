class CreateTrackRequestDto {
  // Kept for compatibility with your current call sites.
  // Backend derives the user from bearer auth, so this is not sent.
  final String userId;

  final String title;
  final String genre;
  final List<String> tags;
  final String description;
  final String privacy;
  final List<String> artists;

  final String availabilityType;
  final List<String> availabilityRegions;

  final String licensingType;
  final bool allowAttribution;
  final bool nonCommercial;
  final bool noDerivatives;
  final bool shareAlike;

  final bool contentWarning;
  final String? scheduledReleaseDate;

  CreateTrackRequestDto({
    required this.userId,
    this.title = '',
    this.genre = 'music_hiphop',
    this.tags = const [],
    this.description = '',
    this.privacy = 'private',
    this.artists = const ['Artist Name'],
    this.availabilityType = 'worldwide',
    this.availabilityRegions = const [],
    this.licensingType = 'creative_commons',
    this.allowAttribution = true,
    this.nonCommercial = true,
    this.noDerivatives = false,
    this.shareAlike = true,
    this.contentWarning = false,
    this.scheduledReleaseDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'genre': genre,
      'tags': tags,
      'description': description,
      'privacy': privacy,
      'artists': artists,
      'availability': {
        'type': availabilityType,
        'regions': availabilityRegions,
      },
      'licensing': {
        'type': licensingType,
        'allowAttribution': allowAttribution,
        'nonCommercial': nonCommercial,
        'noDerivatives': noDerivatives,
        'shareAlike': shareAlike,
      },
      'scheduledReleaseDate': scheduledReleaseDate,
      'contentWarning': contentWarning,
    };
  }
}