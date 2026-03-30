import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../dto/discovery_item_dto.dart';
import '../dto/trending_item_dto.dart';
import '../dto/suggested_artist_dto.dart';
import '../dto/resolved_resource_response_dto.dart';
import '../dto/search_result_item_dto.dart';
import '../dto/feed_item_dto.dart';
import '../dto/track_search_response_dto.dart';
import '../dto/collection_search_response_dto.dart';
import '../dto/user_search_response_dto.dart';
import '../../domain/entities/collection_type.dart';

class DiscoveryApi {
  final Dio dio;

  DiscoveryApi(this.dio);

  Future<PaginatedFeedResponseDto> getFeed({
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
      ApiEndpoints.getFeed,
      queryParameters: params,
    );
    return PaginatedFeedResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<ResolvedResourceResponseDto> resolveResource(String url) async {
    final response = await dio.get(
      ApiEndpoints.resolveResource,
      queryParameters: {'url': url},
    );

    return ResolvedResourceResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<PaginatedDiscoveryResponseDto> getDiscover({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getDiscover,
      queryParameters: {'page': page, 'limit': limit},
    );

    return PaginatedDiscoveryResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<PaginatedTrendingResponseDto> getTrending({
    int page = 1,
    int limit = 20,
    String type = 'track',
    String since = 'week',
  }) async {
    final response = await dio.get(
      ApiEndpoints.getTrending,
      queryParameters: {
        'page': page,
        'limit': limit,
        'type': type,
        'since': since,
      },
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

  Future<PaginatedSearchResponseDto> search({
    required String q,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.search,
      queryParameters: {'q': q, 'page': page, 'limit': limit},
    );

    return PaginatedSearchResponseDto.fromJson(
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
  }) async {
    final params = <String, dynamic>{'q': q, 'page': page, 'limit': limit};
    if (tag != null) params['tag'] = tag;
    if (timeAdded != null) params['timeAdded'] = timeAdded;
    if (duration != null) params['duration'] = duration;
    if (toListen != null) params['toListen'] = toListen;

    final response = await dio.get(
      ApiEndpoints.searchTracks,
      queryParameters: params,
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

    final response = await dio.get(
      ApiEndpoints.searchCollections,
      queryParameters: params,
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

    final response = await dio.get(
      ApiEndpoints.searchPeople,
      queryParameters: params,
    );
    return UserSearchResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
