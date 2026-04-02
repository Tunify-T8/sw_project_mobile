part of 'upload_api.dart';

extension UploadApiQuota on UploadApi {
  Future<UploadQuotaDto> getUploadQuota(String userId) async {
    final results = await Future.wait([
      dio.get(ApiEndpoints.artistToolsQuota(userId)),
      dio
          .get(ApiEndpoints.myUploads)
          .catchError(
            (_) => Response(
              requestOptions: RequestOptions(path: ApiEndpoints.myUploads),
              data: <dynamic>[],
              statusCode: 200,
            ),
          ),
    ]);

    final quotaResponse = results[0] as Response;
    final tracksResponse = results[1] as Response;

    final raw = quotaResponse.data;
    final map = raw is Map<String, dynamic>
        ? (raw['data'] is Map<String, dynamic>
              ? raw['data'] as Map<String, dynamic>
              : raw)
        : <String, dynamic>{};

    final trackList = tracksResponse.data;
    final tracks = trackList is List ? trackList : <dynamic>[];
    final computedUsedSeconds = tracks
        .whereType<Map<String, dynamic>>()
        .where((t) => t['status'] == 'finished')
        .fold<int>(
          0,
          (sum, t) =>
              sum +
              ((t['duration'] ?? t['durationSeconds'] ?? 0) as num).toInt(),
        );
    final computedUsedMinutes = (computedUsedSeconds / 60).ceil();
    final limit = (map['uploadMinutesLimit'] as num?)?.toInt() ?? 99;

    final correctedMap = Map<String, dynamic>.from(map)
      ..['uploadMinutesUsed'] = computedUsedMinutes
      ..['uploadMinutesRemaining'] = (limit - computedUsedMinutes).clamp(
        0,
        limit,
      );

    return UploadQuotaDto.fromJson(correctedMap);
  }
}
