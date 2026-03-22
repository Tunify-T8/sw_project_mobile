class CreateTrackRequestDto {
  // Backend derives the user from bearer auth, so userId is not sent.
  final String userId;

  final String title;
  final String genre;
  final List<String> tags;
  final String description;
  final String privacy;

  // NOTE: backend treats artists as userIds and tries to look them up in the
  // DB. Sending a plain display name like "Artist Name" causes a 500 because
  // it fails the UUID lookup. We omit artists at creation time — they can be
  // set later via updateTrack (PATCH) once the user picks real collaborators.

  final String availabilityType;
  final List<String> availabilityRegions;

  final bool contentWarning;
  final String? scheduledReleaseDate;

  CreateTrackRequestDto({
    required this.userId,
    this.title = '',
    this.genre = 'music_hiphop',
    this.tags = const [],
    this.description = '',
    this.privacy = 'private',
    this.availabilityType = 'worldwide',
    this.availabilityRegions = const [],
    this.contentWarning = false,
    this.scheduledReleaseDate,
  });

  Map<String, dynamic> toJson() {
    final normalizedTitle = title.trim();

    final Map<String, dynamic> body = {
      'title': normalizedTitle.isEmpty ? 'Untitled track' : normalizedTitle,
      'genre': genre,
      'tags': tags,
      'description': description,
      'privacy': privacy,
      // artists intentionally omitted — backend does a DB UUID lookup on each
      // entry and will 500 if a non-UUID string is passed.
      'availability': {
        'type': availabilityType,
        'regions': availabilityRegions,
      },
      'contentWarning': contentWarning,
    };

    // Only send scheduledReleaseDate when non-null — explicit null crashes
    // the NestJS transformer on some validator configs.
    if (scheduledReleaseDate != null) {
      body['scheduledReleaseDate'] = scheduledReleaseDate;
    }

    return body;
  }
}