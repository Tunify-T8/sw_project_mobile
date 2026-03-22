import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../shared/upload_error_helpers.dart';
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
    final _raw = response.data as Map<String, dynamic>;
    final _map = _raw['data'] is Map<String, dynamic> ? _raw['data'] as Map<String, dynamic> : _raw;
    return UploadQuotaDto.fromJson(_map);
  }

  Future<TrackResponseDto> createTrack(CreateTrackRequestDto request) async {
    final response = await dio.post(
      ApiEndpoints.createTrack(),
      data: request.toJson(),
    );
    // Backend returns the raw Prisma track object on POST /tracks.
    // It uses `id` not `trackId`, and `transcodingStatus` not `status`.
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

    // Backend controller uses FileInterceptor('file') — field must be 'file'.
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await dio.post(
      ApiEndpoints.uploadAudio(trackId),
      data: formData,
      cancelToken: cancelToken,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );

    // uploadAudio returns { message: '...' } — not a full track object.
    // Synthesize a minimal DTO so the rest of the flow keeps working.
    return TrackResponseDto(
      trackId: trackId,
      status: 'uploading',
    );
  }

  Future<TrackResponseDto> replaceAudio({
    required String trackId,
    required String filePath,
    required String fileName,
    required ProgressCallback onSendProgress,
  }) async {
    // Backend controller uses FileInterceptor('file') — field must be 'file'.
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

  // finalizeMetadata uses PATCH (not PUT) — backend only has @Patch(':id').
  Future<TrackResponseDto> finalizeMetadata(
    FinalizeTrackMetadataRequestDto request,
  ) async {
    final body = await request.toRequestBody();
    final isMultipart = body is FormData;
    final response = await dio.patch(
      ApiEndpoints.finalizeMetadata(request.trackId),
      data: body,
      options: Options(
        contentType: isMultipart ? 'multipart/form-data' : 'application/json',
      ),
    );

    return TrackResponseDto.fromJson(_normalizeTrackJson(response.data));
  }

  Future<TrackResponseDto> getTrackStatus(String trackId) async {
    final response = await dio.get(ApiEndpoints.trackStatus(trackId));
    // GET :id/status returns { id, transcodingStatus, durationSeconds,
    // audioUrl, waveformUrl } — normalise to our standard shape.
    return TrackResponseDto.fromJson(_normalizeTrackJson(response.data));
  }

  Future<TrackResponseDto> getTrackDetails(String trackId) async {
    final response = await dio.get(ApiEndpoints.trackDetails(trackId));
    // GET :id wraps in { track: {...}, statusCode: 200 }
    return TrackResponseDto.fromJson(_normalizeTrackJson(response.data));
  }

  // updateTrackMetadata also uses PATCH.
  Future<TrackResponseDto> updateTrackMetadata(
    FinalizeTrackMetadataRequestDto request,
  ) async {
    final body = await request.toRequestBody();
    final isMultipart = body is FormData;
    final response = await dio.patch(
      ApiEndpoints.updateTrack(request.trackId),
      data: body,
      options: Options(
        contentType: isMultipart ? 'multipart/form-data' : 'application/json',
      ),
    );

    return TrackResponseDto.fromJson(_normalizeTrackJson(response.data));
  }

  Future<void> deleteTrack(String trackId) async {
    await dio.delete(ApiEndpoints.deleteTrack(trackId));
  }

  // ---------------------------------------------------------------------------
  // Response normalisation
  // ---------------------------------------------------------------------------

  /// Unwraps every response shape the backend produces and returns a flat map
  /// with the canonical keys `trackId` and `status` that TrackResponseDto
  /// expects.
  ///
  /// Known shapes:
  ///   • POST /tracks          → raw Prisma object: { id, transcodingStatus, … }
  ///   • POST :id/audio        → { message: '…' }   (handled before this)
  ///   • GET  :id/status       → { id, transcodingStatus, audioUrl, … }
  ///   • GET  :id              → { track: { trackId, status, … }, statusCode }
  ///   • PATCH :id             → { trackId, status, … }
  ///   • POST :id/audio/replace→ { trackId, status, … }
  Map<String, dynamic> _normalizeTrackJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const UploadFlowException(
        'The server returned an unexpected upload response.',
      );
    }

    Map<String, dynamic> map = raw;

    // Unwrap { track: {...}, statusCode: 200 } envelope (GET :id)
    if (map.containsKey('track') && map['track'] is Map<String, dynamic>) {
      map = map['track'] as Map<String, dynamic>;
    }

    // Unwrap { data: {...} } envelope (future-proofing)
    if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
      map = map['data'] as Map<String, dynamic>;
    }

    // Normalise `id` → `trackId`
    if (!map.containsKey('trackId') && map.containsKey('id')) {
      map = Map<String, dynamic>.from(map);
      (map as Map<String, dynamic>)['trackId'] = map['id'];
    }

    // Normalise `transcodingStatus` → `status`
    if (!map.containsKey('status') && map.containsKey('transcodingStatus')) {
      map = Map<String, dynamic>.from(map);
      (map as Map<String, dynamic>)['status'] = map['transcodingStatus'];
    }

    return map;
  }
}