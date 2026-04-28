import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../dto/discovery_item_dto.dart';
import '../dto/trending_item_dto.dart';
import '../dto/suggested_artist_dto.dart';
import '../dto/search_result_item_dto.dart';
import '../dto/feed_item_dto.dart';
import '../dto/track_search_response_dto.dart';
import '../dto/collection_search_response_dto.dart';
import '../dto/user_search_response_dto.dart';
import '../dto/autocomplete_response_dto.dart';
import '../../domain/entities/collection_type.dart';

class DiscoveryApi {
  final Dio dio;

  DiscoveryApi(this.dio);

  // ── Feed ──────────────────────────────────────────────────────────────────

  Future<PaginatedFeedResponseDto> getFollowingFeed({
    int page = 1,
    int limit = 20,
    bool includeReposts = true,
    String? sinceTimestamp,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      'includeReposts': includeReposts,
    };
    if (sinceTimestamp != null) params['sinceTimestamp'] = sinceTimestamp;

    final response = await dio.get(
      ApiEndpoints.getFollowingFeed,
      queryParameters: params,
    );
    debugPrint('[DiscoveryApi] getFollowingFeed → ${response.statusCode}');
    return PaginatedFeedResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<PaginatedDiscoveryResponseDto> getDiscover({
    int page = 1,
    int limit = 20,
    String? genreId,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (genreId != null) params['genreId'] = genreId;

    final response = await dio.get(
      ApiEndpoints.getDiscover,
      queryParameters: params,
    );
    return PaginatedDiscoveryResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<PaginatedTrendingResponseDto> getTrending({
    int page = 1,
    int limit = 20,
    String type = 'track',
    String period = 'week',
    String? genreId,
  }) async {
    final params = <String, dynamic>{'type': type, 'period': period};
    if (genreId != null) params['genreId'] = genreId;

    debugPrint('[DiscoveryApi] getTrending → params: $params');

    final response = await dio.get(
      ApiEndpoints.getTrending,
      queryParameters: params,
    );

    debugPrint(
      '[DiscoveryApi] getTrending ← ${response.statusCode} | items: ${(response.data['items'] as List?)?.length ?? 0}',
    );

    return PaginatedTrendingResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<PaginatedSuggestedArtistsResponseDto> getSuggestedArtists({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getSuggestedArtists,
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedSuggestedArtistsResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── Search ────────────────────────────────────────────────────────────────

  Future<PaginatedSearchResponseDto> search({
    required String q,
    int page = 1,
    int limit = 20,
  }) async {
    debugPrint('[DiscoveryApi] search → q="$q" page=$page limit=$limit');
    final response = await dio.get(
      ApiEndpoints.search,
      queryParameters: {'q': q, 'page': page, 'limit': limit},
    );
    final items = (response.data['data'] as List?)?.length ?? 0;
    debugPrint(
      '[DiscoveryApi] search ← ${response.statusCode} | items: $items',
    );
    return PaginatedSearchResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<AutocompleteResponseDto> searchAutocomplete({
    required String q,
  }) async {
    final response = await dio.get(
      ApiEndpoints.searchAutocomplete,
      queryParameters: {'q': q},
    );
    return AutocompleteResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<TrackSearchResponseDto> searchTracks({
    required String q,
    int page = 1,
    int limit = 20,
    String? tag,
    String? timeAdded,
    String? duration,
    String? toListen,
    bool? allowDownloads,
  }) async {
    final params = <String, dynamic>{'q': q, 'page': page, 'limit': limit};
    if (tag != null) params['tag'] = tag;
    if (timeAdded != null) params['timeAdded'] = timeAdded;
    if (duration != null) params['duration'] = duration;
    if (toListen != null) params['toListen'] = toListen;
    if (allowDownloads != null) params['allowDownloads'] = allowDownloads;

    debugPrint(
      '[DiscoveryApi] searchTracks → ${ApiEndpoints.searchTracks} params: $params',
    );

    final response = await dio.get(
      ApiEndpoints.searchTracks,
      queryParameters: params,
    );

    final items = (response.data['data'] as List?)?.length ?? 0;
    debugPrint(
      '[DiscoveryApi] searchTracks ← ${response.statusCode} | items: $items | raw: ${response.data}',
    );

    return TrackSearchResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<CollectionSearchResponseDto> searchCollections({
    required String q,
    int page = 1,
    int limit = 20,
    CollectionType? type,
    String? tag,
  }) async {
    final params = <String, dynamic>{'q': q, 'page': page, 'limit': limit};
    if (type != null) params['type'] = type.name;
    if (tag != null) params['tag'] = tag;

    debugPrint(
      '[DiscoveryApi] searchCollections → ${ApiEndpoints.searchCollections} params: $params',
    );

    final response = await dio.get(
      ApiEndpoints.searchCollections,
      queryParameters: params,
    );

    final items = (response.data['data'] as List?)?.length ?? 0;
    debugPrint(
      '[DiscoveryApi] searchCollections ← ${response.statusCode} | items: $items | raw: ${response.data}',
    );

    return CollectionSearchResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<UserSearchResponseDto> searchPeople({
    required String q,
    int page = 1,
    int limit = 20,
    String? location,
    int? minFollowers,
    bool? verifiedOnly,
    String sort = 'relevance',
  }) async {
    final params = <String, dynamic>{
      'q': q,
      'page': page,
      'limit': limit,
      'sort': sort,
    };
    if (location != null) params['location'] = location;
    if (minFollowers != null) params['minFollowers'] = minFollowers;
    if (verifiedOnly != null) params['verifiedOnly'] = verifiedOnly;

    debugPrint(
      '[DiscoveryApi] searchPeople → ${ApiEndpoints.searchPeople} params: $params',
    );

    final response = await dio.get(
      ApiEndpoints.searchPeople,
      queryParameters: params,
    );

    final items = (response.data['data'] as List?)?.length ?? 0;
    debugPrint(
      '[DiscoveryApi] searchPeople ← ${response.statusCode} | items: $items | raw: ${response.data}',
    );

    return UserSearchResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
