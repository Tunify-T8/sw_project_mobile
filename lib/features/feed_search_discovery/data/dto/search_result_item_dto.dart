// ─── Track item ───────────────────────────────────────────────────────────────

class SearchTrackItemDto {
  final String id;
  final String title;
  final String artist;
  final String? genre;
  final int durationSeconds;
  final String? coverUrl;
  final int likesCount;
  final int playsCount;
  final bool allowDownloads;
  final String createdAt;
  final double score;

  const SearchTrackItemDto({
    required this.id,
    required this.title,
    required this.artist,
    this.genre,
    required this.durationSeconds,
    this.coverUrl,
    required this.likesCount,
    required this.playsCount,
    required this.allowDownloads,
    required this.createdAt,
    required this.score,
  });

  factory SearchTrackItemDto.fromJson(Map<String, dynamic> json) {
    return SearchTrackItemDto(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      genre: json['genre']?.toString(),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      coverUrl: json['coverUrl']?.toString(),
      likesCount: json['likesCount'] as int? ?? 0,
      playsCount: json['playsCount'] as int? ?? 0,
      allowDownloads: json['allowDownloads'] as bool? ?? false,
      createdAt: json['createdAt']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ─── Track preview inside a collection ───────────────────────────────────────

class SearchTrackPreviewItemDto {
  final String id;
  final String title;
  final String artist;
  final int durationSeconds;

  const SearchTrackPreviewItemDto({
    required this.id,
    required this.title,
    required this.artist,
    required this.durationSeconds,
  });

  factory SearchTrackPreviewItemDto.fromJson(Map<String, dynamic> json) {
    return SearchTrackPreviewItemDto(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      durationSeconds: json['durationSeconds'] as int? ?? 0,
    );
  }
}

// ─── Collection item (album / playlist) ──────────────────────────────────────

class SearchCollectionItemDto {
  final String id;
  final String type; // "album" | "playlist"
  final String title;
  final String artist;
  final String? description;
  final String? coverUrl;
  final List<SearchTrackPreviewItemDto> trackPreview;
  final String createdAt;
  final double score;

  const SearchCollectionItemDto({
    required this.id,
    required this.type,
    required this.title,
    required this.artist,
    this.description,
    this.coverUrl,
    required this.trackPreview,
    required this.createdAt,
    required this.score,
  });

  factory SearchCollectionItemDto.fromJson(Map<String, dynamic> json) {
    return SearchCollectionItemDto(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'album',
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      description: json['description']?.toString(),
      coverUrl: json['coverUrl']?.toString(),
      trackPreview: (json['trackPreview'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                SearchTrackPreviewItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      createdAt: json['createdAt']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ─── User item ────────────────────────────────────────────────────────────────

class SearchUserItemDto {
  final String id;
  final String username;
  final String? displayName;
  final String? location;
  final bool isCertified;
  final int followersCount;
  final bool? isFollowing;
  final double score;

  const SearchUserItemDto({
    required this.id,
    required this.username,
    this.displayName,
    this.location,
    required this.isCertified,
    required this.followersCount,
    this.isFollowing,
    required this.score,
  });

  factory SearchUserItemDto.fromJson(Map<String, dynamic> json) {
    return SearchUserItemDto(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      displayName: json['displayName']?.toString(),
      location: json['location']?.toString(),
      isCertified: json['isCertified'] as bool? ?? false,
      followersCount: json['followersCount'] as int? ?? 0,
      isFollowing: json['isFollowing'] as bool?,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ─── Sealed union item ────────────────────────────────────────────────────────
//
// Wraps one of the three item types. The "type" field on each raw JSON object
// determines which concrete DTO gets constructed.

class SearchResultItemDto {
  final SearchTrackItemDto? track;
  final SearchCollectionItemDto? collection;
  final SearchUserItemDto? user;

  const SearchResultItemDto._({this.track, this.collection, this.user});

  factory SearchResultItemDto.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? '';
    switch (type) {
      case 'track':
        return SearchResultItemDto._(track: SearchTrackItemDto.fromJson(json));
      case 'album':
      case 'playlist':
        return SearchResultItemDto._(
          collection: SearchCollectionItemDto.fromJson(json),
        );
      case 'user':
        return SearchResultItemDto._(user: SearchUserItemDto.fromJson(json));
      default:
        return const SearchResultItemDto._();
    }
  }
}

// ─── Paginated wrapper ────────────────────────────────────────────────────────

class PaginatedSearchResponseDto {
  final List<SearchResultItemDto> items;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  const PaginatedSearchResponseDto({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory PaginatedSearchResponseDto.fromJson(Map<String, dynamic> json) {
    return PaginatedSearchResponseDto(
      items:
          (json['data'] as List<dynamic>? ?? []) // key is "data" not "items"
              .map(
                (e) => SearchResultItemDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
