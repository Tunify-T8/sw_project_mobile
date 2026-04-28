// Data Transfer Objects for GET /search/autocomplete
//
// Backend contract (from Module 8 API spec):
//   Returns up to 5 results per category (tracks, users, collections).
//   Matches from a single character onwards.
//   Typo tolerance applied automatically.
//   Suspended users and deleted/hidden/private tracks are excluded.

class AutocompleteTrackDto {
  final String id;
  final String title;
  final String artist;

  const AutocompleteTrackDto({
    required this.id,
    required this.title,
    required this.artist,
  });

  factory AutocompleteTrackDto.fromJson(Map<String, dynamic> json) =>
      AutocompleteTrackDto(
        id: json['id'] as String,
        title: json['title'] as String,
        artist: json['artist'] as String,
      );
}

class AutocompleteUserDto {
  final String id;
  final String username;

  /// May be null if the user has not set a display name.
  final String? displayName;

  const AutocompleteUserDto({
    required this.id,
    required this.username,
    this.displayName,
  });

  factory AutocompleteUserDto.fromJson(Map<String, dynamic> json) =>
      AutocompleteUserDto(
        id: json['id'] as String,
        username: json['username'] as String,
        displayName: json['displayName'] as String?,
      );
}

class AutocompleteCollectionDto {
  final String id;
  final String title;
  final String artist;

  const AutocompleteCollectionDto({
    required this.id,
    required this.title,
    required this.artist,
  });

  factory AutocompleteCollectionDto.fromJson(Map<String, dynamic> json) =>
      AutocompleteCollectionDto(
        id: json['id'] as String,
        title: json['title'] as String,
        artist: json['artist'] as String,
      );
}

class AutocompleteResponseDto {
  final List<AutocompleteTrackDto> tracks;
  final List<AutocompleteUserDto> users;
  final List<AutocompleteCollectionDto> collections;

  const AutocompleteResponseDto({
    required this.tracks,
    required this.users,
    required this.collections,
  });

  factory AutocompleteResponseDto.fromJson(Map<String, dynamic> json) {
    List<T> _parse<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      final raw = json[key];
      if (raw == null) return <T>[];
      return (raw as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return AutocompleteResponseDto(
      tracks: _parse('tracks', AutocompleteTrackDto.fromJson),
      users: _parse('users', AutocompleteUserDto.fromJson),
      collections: _parse('collections', AutocompleteCollectionDto.fromJson),
    );
  }
}
