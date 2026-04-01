import 'feed_action_dto.dart';

class FeedItemDto {
  final String id;
  final FeedActionDto action;
  final String title;
  final String artist;
  final String artistId;
  final bool isCertified;
  final String genre;
  final int durationInSeconds;
  final String? coverUrl;
  final String? waveformUrl;
  final int numberOfComments;
  final int numberOfLikes;
  final int numberOfListens;
  final int numberOfReposts;
  final bool isLiked;
  final bool isReposted;
  final bool? isFollowingArtist;

  FeedItemDto({
    required this.id,
    required this.action,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.isCertified,
    required this.genre,
    required this.durationInSeconds,
    required this.coverUrl,
    required this.waveformUrl,
    required this.numberOfComments,
    required this.numberOfLikes,
    required this.numberOfListens,
    required this.numberOfReposts,
    required this.isLiked,
    required this.isReposted,
    this.isFollowingArtist,
  });

  factory FeedItemDto.fromJson(Map<String, dynamic> json) {
    return FeedItemDto(
      id: json['id']?.toString() ?? '',
      action: FeedActionDto.fromJson(
        json['action'] as Map<String, dynamic>? ?? {},
      ),
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      artistId: json['artistId']?.toString() ?? '',
      isCertified: json['isCertified'] ?? false,
      genre: json['genre']?.toString() ?? '',
      durationInSeconds: json['durationInSeconds'] ?? 0,
      coverUrl: json['coverUrl']?.toString(),
      waveformUrl: json['waveformUrl']?.toString(),
      numberOfComments: json['numberOfComments'] ?? 0,
      numberOfLikes: json['numberOfLikes'] ?? 0,
      numberOfListens: json['numberOfListens'] ?? 0,
      numberOfReposts: json['numberOfReposts'] ?? 1,
      isLiked: json['isLiked'] ?? false,
      isReposted: json['isReposted'] ?? false,
      isFollowingArtist: json['isFollowingArtist'] as bool?,
    );
  }
}

class PaginatedFeedResponseDto {
  final List<FeedItemDto> items;
  final int page;
  final int limit;
  final bool hasMore;

  PaginatedFeedResponseDto({
    required this.items,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory PaginatedFeedResponseDto.fromJson(Map<String, dynamic> json) {
    return PaginatedFeedResponseDto(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => FeedItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      hasMore: json['hasMore'] ?? false,
    );
  }
}
