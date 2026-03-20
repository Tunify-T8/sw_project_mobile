import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/upload_cancellation_token.dart';
import '../dto/create_track_request_dto.dart';
import '../dto/finalize_track_metadata_request_dto.dart';
import '../dto/track_response_dto.dart';
import '../dto/upload_quota_dto.dart';

class UploadApi {
  final Dio dio;

  UploadApi(this.dio);

  Future<UploadQuotaDto> getUploadQuota(String userId) async {
    final response = await dio.get(ApiEndpoints.uploadQuota());
    return UploadQuotaDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TrackResponseDto> createTrack(CreateTrackRequestDto request) async {
    final response = await dio.post(
      ApiEndpoints.createTrack(),
      data: request.toJson(),
    );

    return TrackResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TrackResponseDto> uploadAudio({
    required String trackId,
    required String filePath,
    required String fileName,
    required ProgressCallback onSendProgress,
    UploadCancellationToken? cancellationToken,
  }) async {
    final cancelToken = CancelToken();
    cancellationToken?.addListener(() {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('Upload cancelled by user.');
      }
    });

    final formData = FormData.fromMap({
      'audioFile': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await dio.post(
      ApiEndpoints.uploadAudio(trackId),
      data: formData,
      cancelToken: cancelToken,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );

    return TrackResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TrackResponseDto> replaceAudio({
    required String trackId,
    required String filePath,
    required String fileName,
    required ProgressCallback onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'newAudioFile': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    final response = await dio.post(
      ApiEndpoints.replaceAudio(trackId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );

    return TrackResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TrackResponseDto> finalizeMetadata(
    FinalizeTrackMetadataRequestDto request,
  ) async {
    final response = await dio.put(
      ApiEndpoints.finalizeMetadata(request.trackId),
      data: await request.toFormData(),
      options: Options(contentType: 'multipart/form-data'),
    );

    return TrackResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TrackResponseDto> getTrackStatus(String trackId) async {
    final response = await dio.get(ApiEndpoints.trackStatus(trackId));
    return TrackResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TrackResponseDto> getTrackDetails(String trackId) async {
    final response = await dio.get(ApiEndpoints.trackDetails(trackId));
    return TrackResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TrackResponseDto> updateTrackMetadata(
    FinalizeTrackMetadataRequestDto request,
  ) async {
    final response = await dio.patch(
      ApiEndpoints.updateTrack(request.trackId),
      data: await request.toFormData(),
      options: Options(contentType: 'multipart/form-data'),
    );

    return TrackResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTrack(String trackId) async {
    await dio.delete(ApiEndpoints.deleteTrack(trackId));
  }
}
