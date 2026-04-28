import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/core/network/api_endpoints.dart';
import 'package:software_project/features/followers_and_social_graph/data/api/social_api.dart';

void main() {
  late FakeDio dio;
  late SocialApi api;

  setUp(() {
    dio = FakeDio();
    api = SocialApi(dio);
  });

  test('sends relationship mutation requests to the expected endpoints', () async {
    await api.followUser('u1');
    await api.unfollowUser('u1');
    await api.blockUser('u1');
    await api.unblockUser('u1');

    expect(dio.calls, [
      'POST ${ApiEndpoints.followUser('u1')}',
      'DELETE ${ApiEndpoints.unfollowUser('u1')}',
      'POST ${ApiEndpoints.blockUser('u1')}',
      'DELETE ${ApiEndpoints.unblockUser('u1')}',
    ]);
  });

  test('getFollowStatus parses relation response', () async {
    dio.responses[ApiEndpoints.getFollowStatus('u2')] = {
      'isFollowing': true,
      'isBlocked': true,
    };

    final result = await api.getFollowStatus('u2');

    expect(result.isFollowing, isTrue);
    expect(result.isBlocked, isTrue);
  });

  test('parses public and current-user follower lists with paging', () async {
    dio.responses[ApiEndpoints.getUserFollowers('target')] = {
      'followers': [_userJson('f1')],
    };
    dio.responses[ApiEndpoints.getUserFollowing('target')] = {
      'following': [_userJson('f2')],
    };
    dio.responses[ApiEndpoints.getMyFollowers] = {
      'followers': [_userJson('f3')],
    };
    dio.responses[ApiEndpoints.getMyFollowing] = {
      'following': [_userJson('f4')],
    };

    expect((await api.getUserFollowers(userId: 'target', page: 2, limit: 3)).single.id, 'f1');
    expect((await api.getUserFollowing(userId: 'target', page: 2, limit: 3)).single.id, 'f2');
    expect((await api.getMyFollowers(page: 2, limit: 3)).single.id, 'f3');
    expect((await api.getMyFollowing(page: 2, limit: 3)).single.id, 'f4');
    expect(dio.queryParameters, everyElement({'page': 2, 'limit': 3}));
  });

  test('parses blocked true-friend and suggestion lists', () async {
    dio.responses[ApiEndpoints.getBlockedUsers] = {
      'data': [
        {'user': _userJson('blocked', isBlocked: true)},
      ],
    };
    dio.responses[ApiEndpoints.getTrueFriends] = {
      'data': [_userJson('true')],
    };
    dio.responses[ApiEndpoints.getSuggestedUsers] = {
      'data': [_userJson('suggested')],
    };
    dio.responses[ApiEndpoints.getSuggestedArtists] = {
      'data': [_userJson('artist')],
    };

    expect((await api.getBlockedUsers(page: 1, limit: 2)).single.isBlocked, isTrue);
    expect((await api.getTrueFriends(page: 1, limit: 2)).single.id, 'true');
    expect((await api.getSuggestedUsers(page: 1, limit: 2)).single.id, 'suggested');
    expect((await api.getSuggestedArtists(page: 1, limit: 2)).single.id, 'artist');
    expect(dio.queryParameters, everyElement({'page': 1, 'limit': 2}));
  });
}

class FakeDio implements Dio {
  final calls = <String>[];
  final queryParameters = <Map<String, dynamic>>[];
  final responses = <String, Map<String, dynamic>>{};

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    calls.add('POST $path');
    return Response<T>(requestOptions: RequestOptions(path: path));
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    calls.add('DELETE $path');
    return Response<T>(requestOptions: RequestOptions(path: path));
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    calls.add('GET $path');
    if (queryParameters != null) this.queryParameters.add(queryParameters);
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: responses[path] as T,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _userJson(String id, {bool isBlocked = false}) {
  return {
    'id': id,
    'username': 'name_$id',
    'avatarUrl': 'avatar_$id',
    'coverUrl': 'cover_$id',
    'location': 'Cairo',
    'followersCount': 12,
    'isCertified': true,
    'isFollowing': false,
    'isBlocked': isBlocked,
    'isNotificationEnabled': true,
  };
}
