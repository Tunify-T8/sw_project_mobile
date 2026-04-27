import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/upload_cancellation_token.dart';
import '../../shared/upload_error_helpers.dart';
import '../dto/create_track_request_dto.dart';
import '../dto/finalize_track_metadata_request_dto.dart';
import '../dto/track_response_dto.dart';
import '../dto/upload_quota_dto.dart';

part 'upload_api_quota.dart';
part 'upload_api_normalization.dart';

class UploadApi {
  final Dio dio;

  UploadApi(this.dio);

  Future<TrackResponseDto> createTrack(CreateTrackRequestDto request) async {
    final response = await dio.post(
      ApiEndpoints.createTrack(),
      data: request.toJson(),
    );
    return TrackResponseDto.fromJson(_normalizeTrackJson(response.data));
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
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    await dio.post(
      ApiEndpoints.uploadAudio(trackId),
      data: formData,
      cancelToken: cancelToken,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );

    return TrackResponseDto(trackId: trackId, status: 'uploading');
  }

  Future<TrackResponseDto> replaceAudio({
    required String trackId,
    required String filePath,
    required String fileName,
    required ProgressCallback onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await dio.post(
      ApiEndpoints.replaceAudio(trackId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );

    return TrackResponseDto.fromJson(_normalizeTrackJson(response.data));
  }

  Future<TrackResponseDto> finalizeMetadata(
    FinalizeTrackMetadataRequestDto request,
  ) async {
    final response = await dio.patch(
      ApiEndpoints.finalizeMetadata(request.trackId),
      data: request.toJsonBody(),
      options: Options(contentType: 'application/json'),
    );
    final result = TrackResponseDto.fromJson(
      _normalizeTrackJson(response.data),
    );

    if (request.hasLocalArtwork) {
      try {
        await dio.patch(
          ApiEndpoints.finalizeMetadata(request.trackId),
          data: FormData.fromMap({
            'artwork': await MultipartFile.fromFile(request.artworkPath!),
          }),
          options: Options(contentType: 'multipart/form-data'),
        );
      } catch (_) {}
    }

    return result;
  }

  Future<TrackResponseDto> getTrackStatus(String trackId) async {
    final response = await dio.get(ApiEndpoints.trackStatus(trackId));
    return TrackResponseDto.fromJson(_normalizeTrackJson(response.data));
  }

  Future<TrackResponseDto> getTrackDetails(String trackId) async {
    final response = await dio.get(ApiEndpoints.trackDetails(trackId));
    return TrackResponseDto.fromJson(_normalizeTrackJson(response.data));
  }

  Future<TrackResponseDto> updateTrackMetadata(
    FinalizeTrackMetadataRequestDto request,
  ) async {
    final response = await dio.patch(
      ApiEndpoints.updateTrack(request.trackId),
      data: request.toJsonBody(),
      options: Options(contentType: 'application/json'),
    );
    final result = TrackResponseDto.fromJson(
      _normalizeTrackJson(response.data),
    );

    if (request.hasLocalArtwork) {
      try {
        await dio.patch(
          ApiEndpoints.updateTrack(request.trackId),
          data: FormData.fromMap({
            'artwork': await MultipartFile.fromFile(request.artworkPath!),
          }),
          options: Options(contentType: 'multipart/form-data'),
        );
      } catch (_) {}
    }

    return result;
  }

  Future<void> deleteTrack(String trackId) async {
    await dio.delete(ApiEndpoints.deleteTrack(trackId));
  }
}
