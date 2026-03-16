import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dto/artist_tools_quota_dto.dart';
import '../dto/upload_item_dto.dart';

/// Real Dio API for the Library / Your Uploads screen.
/// This class talks to the backend only.
/// It should NOT use GlobalTrackStore or any mock-only logic.
class LibraryUploadsApi {
  final Dio dio;

  const LibraryUploadsApi(this.dio);

  /// GET /me/uploads
  Future<List<UploadItemDto>> getMyUploads() async {
    final response = await dio.get(ApiEndpoints.myUploads);
    final raw = response.data;

    final List<dynamic> data;
    if (raw is List) {
      data = raw;
    } else if (raw is Map<String, dynamic>) {
      data = (raw['items'] as List?) ??
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
  }

  /// GET /users/me/artist-tools/upload-minutes
  Future<ArtistToolsQuotaDto> getArtistToolsQuota() async {
    final response = await dio.get(ApiEndpoints.artistToolsQuota());
    final raw = response.data;

    if (raw is Map<String, dynamic>) {
      return ArtistToolsQuotaDto.fromJson(
        raw['data'] is Map<String, dynamic>
            ? raw['data'] as Map<String, dynamic>
            : raw,
      );
    }

    throw const FormatException('Invalid artist tools quota response format.');
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

    await dio.post(
      ApiEndpoints.replaceUploadFile(trackId),
      data: formData,
    );
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

    throw const FormatException('Invalid update upload response format.');
  }
}
