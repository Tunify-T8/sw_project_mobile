import 'package:dio/dio.dart';

import '../../shared/upload_error_helpers.dart';
import 'cloudinary_asset_delete_service.dart';

class CloudinaryMediaService {
  CloudinaryMediaService({
    required Dio dio,
    required String cloudName,
    required String audioUploadPreset,
    required String imageUploadPreset,
    this.apiKey = '',
    this.apiSecret = '',
  }) : _dio = dio,
       _cloudName = cloudName,
       _audioUploadPreset = audioUploadPreset,
       _imageUploadPreset = imageUploadPreset;

  final Dio _dio;
  final String _cloudName;
  final String _audioUploadPreset;
  final String _imageUploadPreset;
  final String apiKey;
  final String apiSecret;

  bool get isConfigured =>
      _cloudName.trim().isNotEmpty &&
      _audioUploadPreset.trim().isNotEmpty &&
      _imageUploadPreset.trim().isNotEmpty;

  bool get canDeleteAssets =>
      _cloudName.trim().isNotEmpty &&
      apiKey.trim().isNotEmpty &&
      apiSecret.trim().isNotEmpty;

  Future<CloudinaryAsset> uploadAudio({
    required String filePath,
    required String fileName,
    required ProgressCallback onSendProgress,
  }) {
    return _upload(
      resourceType: 'video',
      filePath: filePath,
      fileName: fileName,
      uploadPreset: _audioUploadPreset,
      onSendProgress: onSendProgress,
    );
  }

  Future<CloudinaryAsset> uploadArtwork({
    required String filePath,
    required String fileName,
  }) {
    return _upload(
      resourceType: 'image',
      filePath: filePath,
      fileName: fileName,
      uploadPreset: _imageUploadPreset,
    );
  }

  String buildWaveformImageUrl({
    required String audioPublicId,
    int width = 1200,
    int height = 240,
  }) {
    final base = 'https://res.cloudinary.com/$_cloudName/video/upload';
    return '$base/fl_waveform,w_$width,h_$height,c_fit,co_rgb:ffffff/$audioPublicId.png';
  }

  Future<void> deleteTrackAssets({String? audioUrl, String? artworkUrl}) async {
    await Future.wait([
      deleteCloudinaryAssetByUrl(
        dio: _dio,
        cloudName: _cloudName,
        apiKey: apiKey,
        apiSecret: apiSecret,
        assetUrl: audioUrl,
        resourceType: 'video',
      ),
      deleteCloudinaryAssetByUrl(
        dio: _dio,
        cloudName: _cloudName,
        apiKey: apiKey,
        apiSecret: apiSecret,
        assetUrl: artworkUrl,
        resourceType: 'image',
      ),
    ]);
  }

  Future<CloudinaryAsset> _upload({
    required String resourceType,
    required String filePath,
    required String fileName,
    required String uploadPreset,
    ProgressCallback? onSendProgress,
  }) async {
    if (!isConfigured) {
      throw const UploadFlowException(
        'Uploads are not configured right now. Please try again later.',
      );
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'upload_preset': uploadPreset,
    });

    final response = await _dio.post<Map<String, dynamic>>(
      'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );

    final data = response.data;
    if (data == null) {
      throw const UploadFlowException(
        'The upload service returned an empty response. Please try again.',
      );
    }

    final secureUrl = data['secure_url'] as String?;
    final publicId = data['public_id'] as String?;

    if (secureUrl == null || publicId == null) {
      throw const UploadFlowException(
        'The upload service returned incomplete track data. Please try again.',
      );
    }

    return CloudinaryAsset(
      secureUrl: secureUrl,
      publicId: publicId,
      resourceType: (data['resource_type'] as String?) ?? resourceType,
      format: data['format'] as String?,
      durationSeconds: (data['duration'] as num?)?.round(),
      bytes: (data['bytes'] as num?)?.toInt(),
      originalFilename: data['original_filename'] as String?,
    );
  }
}

class CloudinaryAsset {
  const CloudinaryAsset({
    required this.secureUrl,
    required this.publicId,
    required this.resourceType,
    this.format,
    this.durationSeconds,
    this.bytes,
    this.originalFilename,
  });

  final String secureUrl;
  final String publicId;
  final String resourceType;
  final String? format;
  final int? durationSeconds;
  final int? bytes;
  final String? originalFilename;
}
