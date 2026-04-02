import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/token_storage.dart';
import '../../shared/upload_error_helpers.dart';
import '../dto/artist_tools_quota_dto.dart';
import '../dto/upload_item_dto.dart';

part 'library_uploads_api_helpers.dart';

class LibraryUploadsApi {
  final Dio dio;
  final TokenStorage _tokenStorage;

  const LibraryUploadsApi(
    this.dio, {
    TokenStorage tokenStorage = const TokenStorage(),
  }) : _tokenStorage = tokenStorage;

  Future<List<UploadItemDto>> getMyUploads() async {
    try {
      final response = await dio.get(ApiEndpoints.myUploads);
      final raw = response.data;

      final List<dynamic> data;
      if (raw is List) {
        data = raw;
      } else if (raw is Map<String, dynamic>) {
        data =
            (raw['items'] as List?) ??
            (raw['tracks'] as List?) ??
            (raw['uploads'] as List?) ??
            (raw['data'] as List?) ??
            const <dynamic>[];
      } else {
        data = const <dynamic>[];
      }

      final baseItems = data
          .whereType<Map<String, dynamic>>()
          .map(UploadItemDto.fromJson)
          .toList();

      return Future.wait(baseItems.map(_enrichCollaboratorsIfNeeded));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const [];
      rethrow;
    }
  }

  Future<ArtistToolsQuotaDto> getArtistToolsQuota() async {
    final user = await _tokenStorage.getUser();
    if (user == null) {
      throw const UploadFlowException(
        'Please sign in again to load your upload tools.',
      );
    }

    final results = await Future.wait([
      dio.get(ApiEndpoints.artistToolsQuota(user.id)),
      getMyUploads(),
    ]);

    final quotaResponse = results[0] as Response;
    final tracks = results[1] as List<UploadItemDto>;

    final raw = quotaResponse.data;
    if (raw is! Map<String, dynamic>) {
      throw const UploadFlowException(
        'We could not load your artist tools right now. Please try again.',
      );
    }

    final map = raw['data'] is Map<String, dynamic>
        ? raw['data'] as Map<String, dynamic>
        : raw;

    final computedUsedSeconds = tracks
        .where((t) => t.status == 'finished')
        .fold<int>(0, (sum, t) => sum + t.durationSeconds);
    final computedUsedMinutes = (computedUsedSeconds / 60).ceil();
    final limit = (map['uploadMinutesLimit'] as num?)?.toInt() ?? 99;

    final correctedMap = Map<String, dynamic>.from(map)
      ..['uploadMinutesUsed'] = computedUsedMinutes
      ..['uploadMinutesRemaining'] = (limit - computedUsedMinutes).clamp(
        0,
        limit,
      );

    return ArtistToolsQuotaDto.fromJson(correctedMap);
  }

  Future<void> deleteUpload(String trackId) async {
    await dio.delete(ApiEndpoints.deleteUpload(trackId));
  }

  Future<void> replaceUploadFile({
    required String trackId,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    await dio.post(ApiEndpoints.replaceUploadFile(trackId), data: formData);
  }

  Future<UploadItemDto> updateUpload({
    required String trackId,
    required String title,
    required String description,
    required String privacy,
    String? localArtworkPath,
  }) async {
    Response response;

    if (localArtworkPath != null) {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'privacy': privacy,
        'artwork': await MultipartFile.fromFile(
          localArtworkPath,
          filename: localArtworkPath.split('/').last,
        ),
      });
      response = await dio.patch(
        ApiEndpoints.updateTrack(trackId),
        data: formData,
      );
    } else {
      response = await dio.patch(
        ApiEndpoints.updateTrack(trackId),
        data: {'title': title, 'description': description, 'privacy': privacy},
      );
    }

    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      return UploadItemDto.fromJson(
        raw['data'] is Map<String, dynamic>
            ? raw['data'] as Map<String, dynamic>
            : raw,
      );
    }

    throw const UploadFlowException(
      'We could not save those track changes right now. Please try again.',
    );
  }
}
