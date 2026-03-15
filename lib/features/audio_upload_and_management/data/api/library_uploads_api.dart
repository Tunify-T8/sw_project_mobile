import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dto/artist_tools_quota_dto.dart';
import '../dto/upload_item_dto.dart';

class LibraryUploadsApi {
  final Dio dio;

  const LibraryUploadsApi(this.dio);

  Future<List<UploadItemDto>> getMyUploads() async {
    final response = await dio.get(ApiEndpoints.myUploads);

    final data = response.data as List<dynamic>;

    return data
        .map((item) => UploadItemDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ArtistToolsQuotaDto> getArtistToolsQuota() async {
    final response = await dio.get(ApiEndpoints.artistToolsQuota);

    return ArtistToolsQuotaDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> deleteUpload(String trackId) async {
    await dio.delete(ApiEndpoints.deleteUpload(trackId));
  }

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
}