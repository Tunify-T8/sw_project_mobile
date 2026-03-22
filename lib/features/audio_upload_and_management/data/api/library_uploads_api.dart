import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/token_storage.dart';
import '../../shared/upload_error_helpers.dart';
import '../dto/artist_tools_quota_dto.dart';
import '../dto/upload_item_dto.dart';

/// Real Dio API for the Library / Your Uploads screen.
/// This class talks to the backend only.
/// It should NOT use GlobalTrackStore or any mock-only logic.
class LibraryUploadsApi {
  final Dio dio;
  final TokenStorage _tokenStorage;

  const LibraryUploadsApi(
    this.dio, {
    TokenStorage tokenStorage = const TokenStorage(),
  }) : _tokenStorage = tokenStorage;

  /// GET /tracks/me
  /// NOTE: The backend controller declares @Get(':id') before @Get('me'),
  /// so NestJS routes /tracks/me to the :id handler and returns 404.
  /// We catch that and return an empty list so the upload flow keeps working.
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

      return data
          .whereType<Map<String, dynamic>>()
          .map(UploadItemDto.fromJson)
          .toList();
    } on DioException catch (e) {
      // 404 means the backend route order bug is active — return empty list
      // rather than crashing. The upload itself succeeded.
      if (e.response?.statusCode == 404) return const [];
      rethrow;
    }
  }

  /// GET /users/me/artist-tools/upload-minutes
  Future<ArtistToolsQuotaDto> getArtistToolsQuota() async {
    final user = await _tokenStorage.getUser();
    if (user == null) {
      throw const UploadFlowException(
        'Please sign in again to load your upload tools.',
      );
    }

    final response = await dio.get(ApiEndpoints.artistToolsQuota(user.id));
    final raw = response.data;

    if (raw is Map<String, dynamic>) {
      return ArtistToolsQuotaDto.fromJson(
        raw['data'] is Map<String, dynamic>
            ? raw['data'] as Map<String, dynamic>
            : raw,
      );
    }

    throw const UploadFlowException(
      'We could not load your artist tools right now. Please try again.',
    );
  }

  /// DELETE /tracks/:id
  Future<void> deleteUpload(String trackId) async {
    await dio.delete(ApiEndpoints.deleteUpload(trackId));
  }

  /// POST /tracks/:id/audio/replace
  Future<void> replaceUploadFile({
    required String trackId,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'newAudioFile': await MultipartFile.fromFile(filePath),
    });

    await dio.post(ApiEndpoints.replaceUploadFile(trackId), data: formData);
  }

  /// PATCH /tracks/:id
  Future<UploadItemDto> updateUpload({
    required String trackId,
    required String title,
    required String description,
    required String privacy,
    String? localArtworkPath,
  }) async {
    final fields = <String, dynamic>{
      'title': title,
      'description': description,
      'privacy': privacy,
    };

    Response response;

    if (localArtworkPath != null) {
      final formData = FormData.fromMap({
        ...fields,
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
        data: fields,
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