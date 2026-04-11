import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/network/api_endpoints.dart';
import 'package:software_project/features/feed_search_discovery/data/api/discovery_api.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/collection_type.dart';

class MockDio extends Mock implements Dio {
  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return super.noSuchMethod(
          Invocation.method(#get, [path], {
            #data: data,
            #queryParameters: queryParameters,
            #options: options,
            #cancelToken: cancelToken,
            #onReceiveProgress: onReceiveProgress,
          }),
          returnValue: Future<Response<T>>.value(
            Response<T>(
              requestOptions: RequestOptions(path: path),
              data: null,
            ),
          ),
        )
        as Future<Response<T>>;
  }
}

void main() {
  late MockDio dio;
  late DiscoveryApi api;

  setUp(() {
    dio = MockDio();
    api = DiscoveryApi(dio);
  });

  Response<Map<String, dynamic>> jsonResponse(
    String path,
    Map<String, dynamic> data,
  ) {
    return Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  test('getFollowingFeed forwards optional params and parses feed response', () async {
    when(
      dio.get<Map<String, dynamic>>(
        ApiEndpoints.getFollowingFeed,
        queryParameters: {
          'page': 2,
          'limit': 5,
          'includeReposts': false,
          'sinceTimestamp': '2026-01-01T00:00:00Z',
        },
      ),
    ).thenAnswer(
      (_) async => jsonResponse(ApiEndpoints.getFollowingFeed, {
        'items': [
          {
            'trackId': 'track-1',
            'action': {
              'actorId': 'user-1',
              'username': 'Drake',
              'action': 'post',
              'date': '2026-01-01T00:00:00Z',
            },
            'title': 'Midnight Drive',
            'artist': 'Drake',
            'artistId': 'artist-1',
            'artistIsCertified': true,
            'genre': 'hip hop',
            'durationInSeconds': 215,
            'numberOfComments': 1,
            'numberOfLikes': 2,
            'numberOfListens': 3,
            'numberOfReposts': 4,
            'isLiked': true,
            'isReposted': false,
          },
        ],
        'page': 2,
        'limit': 5,
        'hasMore': true,
      }),
    );

    final result = await api.getFollowingFeed(
      page: 2,
      limit: 5,
      includeReposts: false,
      sinceTimestamp: '2026-01-01T00:00:00Z',
    );

    expect(result.items.single.title, 'Midnight Drive');
    expect(result.page, 2);
    expect(result.limit, 5);
    expect(result.hasMore, isTrue);
  });

  test('getDiscover includes genreId only when provided and parses results', () async {
    when(
      dio.get<Map<String, dynamic>>(
        ApiEndpoints.getDiscover,
        queryParameters: {
          'page': 3,
          'limit': 4,
          'genreId': 'rock',
        },
      ),
    ).thenAnswer(
      (_) async => jsonResponse(ApiEndpoints.getDiscover, {
        'items': [
          {
            'itemType': 'user',
            'resource': {
              'id': 'user-1',
              'username': 'Artist',
              'followersCount': 20,
              'verified': true,
              'isFollowing': false,
            },
          },
        ],
        'page': 3,
        'limit': 4,
        'total': 1,
      }),
    );

    final result = await api.getDiscover(page: 3, limit: 4, genreId: 'rock');

    expect(result.items.single.itemType.name, 'user');
    expect(result.total, 1);
  });

  test('getTrending forwards type period genre and parses items', () async {
    when(
      dio.get<Map<String, dynamic>>(
        ApiEndpoints.getTrending,
        queryParameters: {
          'page': 1,
          'limit': 10,
          'type': 'playlist',
          'period': 'month',
          'genreId': 'pop',
        },
      ),
    ).thenAnswer(
      (_) async => jsonResponse(ApiEndpoints.getTrending, {
        'items': [
          {
            'id': 'trend-1',
            'name': 'Trend',
            'artist': 'Artist',
            'type': 'playlist',
            'score': 10,
          },
        ],
        'type': 'playlist',
        'period': 'month',
      }),
    );

    final result = await api.getTrending(
      limit: 10,
      type: 'playlist',
      period: 'month',
      genreId: 'pop',
    );

    expect(result.items.single.name, 'Trend');
    expect(result.type, 'playlist');
    expect(result.period, 'month');
  });

  test('getSuggestedArtists forwards default paging and parses response', () async {
    when(
      dio.get<Map<String, dynamic>>(
        ApiEndpoints.getSuggestedArtists,
        queryParameters: {'page': 1, 'limit': 10},
      ),
    ).thenAnswer(
      (_) async => jsonResponse(ApiEndpoints.getSuggestedArtists, {
        'items': [
          {
            'userId': 'user-1',
            'name': 'Artist',
            'followersCount': 1200,
            'tracksCount': 12,
            'genreTags': ['rock'],
          },
        ],
        'page': 1,
        'limit': 10,
        'total': 1,
      }),
    );

    final result = await api.getSuggestedArtists();

    expect(result.items.single.name, 'Artist');
    expect(result.limit, 10);
  });

  test('search forwards query params and parses aggregate search data', () async {
    when(
      dio.get<Map<String, dynamic>>(
        ApiEndpoints.search,
        queryParameters: {'q': 'don', 'page': 2, 'limit': 5},
      ),
    ).thenAnswer(
      (_) async => jsonResponse(ApiEndpoints.search, {
        'data': [
          {
            'type': 'track',
            'id': 'track-1',
            'title': 'Song',
            'artist': 'Artist',
            'durationSeconds': 180,
            'likesCount': 10,
            'playsCount': 20,
            'allowDownloads': false,
            'createdAt': '2026-01-01T00:00:00Z',
            'score': 0.8,
          },
        ],
        'page': 2,
        'limit': 5,
        'total': 1,
        'hasMore': false,
      }),
    );

    final result = await api.search(q: 'don', page: 2, limit: 5);

    expect(result.items.single.track?.title, 'Song');
    expect(result.page, 2);
  });

  test('searchTracks only includes non-null filters', () async {
    when(
      dio.get<Map<String, dynamic>>(
        ApiEndpoints.searchTracks,
        queryParameters: {
          'q': 'rock',
          'page': 1,
          'limit': 20,
          'tag': 'rock',
          'duration': 'TWO_TEN',
          'allowDownloads': true,
        },
      ),
    ).thenAnswer(
      (_) async => jsonResponse(ApiEndpoints.searchTracks, {
        'data': [
          {
            'id': 'track-1',
            'title': 'Track',
            'artistId': 'artist-1',
            'artistName': 'Artist',
            'artistVerified': true,
            'isFollowingArtist': false,
            'duration': 180,
            'likesCount': 1,
            'repostsCount': 2,
            'commentsCount': 3,
            'createdAt': '2026-01-01T00:00:00Z',
            'interaction': {'isLiked': false, 'isReposted': false},
          },
        ],
        'page': 1,
        'limit': 20,
        'total': 1,
      }),
    );

    final result = await api.searchTracks(
      q: 'rock',
      tag: 'rock',
      duration: 'TWO_TEN',
      allowDownloads: true,
    );

    expect(result.items.single.title, 'Track');
    verify(
      dio.get<Map<String, dynamic>>(
        ApiEndpoints.searchTracks,
        queryParameters: {
          'q': 'rock',
          'page': 1,
          'limit': 20,
          'tag': 'rock',
          'duration': 'TWO_TEN',
          'allowDownloads': true,
        },
      ),
    ).called(1);
  });

  test('searchCollections includes type and tag when provided', () async {
    when(
      dio.get<Map<String, dynamic>>(
        ApiEndpoints.searchCollections,
        queryParameters: {
          'q': 'mix',
          'page': 4,
          'limit': 6,
          'type': 'playlist',
          'tag': 'party',
        },
      ),
    ).thenAnswer(
      (_) async => jsonResponse(ApiEndpoints.searchCollections, {
        'data': [
          {
            'id': 'playlist-1',
            'type': 'playlist',
            'title': 'Party Mix',
            'creatorId': 'creator-1',
            'creatorName': 'DJ',
            'trackCount': 7,
            'duration': 1000,
            'createdAt': '2026-01-01T00:00:00Z',
          },
        ],
        'page': 4,
        'limit': 6,
        'total': 1,
      }),
    );

    final result = await api.searchCollections(
      q: 'mix',
      page: 4,
      limit: 6,
      type: CollectionType.playlist,
      tag: 'party',
    );

    expect(result.items.single.type, CollectionType.playlist);
    expect(result.page, 4);
  });

  test('searchPeople includes only provided filters and default sort', () async {
    when(
      dio.get<Map<String, dynamic>>(
        ApiEndpoints.searchPeople,
        queryParameters: {
          'q': 'artist',
          'page': 2,
          'limit': 8,
          'sort': 'FOLLOWERS',
          'location': 'Cairo',
          'minFollowers': 500,
          'verifiedOnly': true,
        },
      ),
    ).thenAnswer(
      (_) async => jsonResponse(ApiEndpoints.searchPeople, {
        'data': [
          {
            'id': 'user-1',
            'username': 'Artist',
            'followersCount': 500,
            'verified': true,
            'location': 'Cairo',
            'isFollowing': false,
          },
        ],
        'page': 2,
        'limit': 8,
        'total': 1,
      }),
    );

    final result = await api.searchPeople(
      q: 'artist',
      page: 2,
      limit: 8,
      location: 'Cairo',
      minFollowers: 500,
      verifiedOnly: true,
      sort: 'FOLLOWERS',
    );

    expect(result.items.single.username, 'Artist');
    expect(result.limit, 8);
  });
}
