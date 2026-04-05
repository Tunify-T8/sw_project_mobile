part of 'upload_api.dart';

extension _UploadApiNormalization on UploadApi {
  Map<String, dynamic> _normalizeTrackJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const UploadFlowException(
        'The server returned an unexpected upload response.',
      );
    }

    Map<String, dynamic> map = raw;

    if (map.containsKey('track') && map['track'] is Map<String, dynamic>) {
      map = map['track'] as Map<String, dynamic>;
    }

    if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
      map = map['data'] as Map<String, dynamic>;
    }

    if (!map.containsKey('trackId') && map.containsKey('id')) {
      map = Map<String, dynamic>.from(map)..['trackId'] = map['id'];
    }

    if (!map.containsKey('status') && map.containsKey('transcodingStatus')) {
      map = Map<String, dynamic>.from(map)
        ..['status'] = map['transcodingStatus'];
    }

    return map;
  }
}
