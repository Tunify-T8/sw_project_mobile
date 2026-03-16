import 'package:dio/dio.dart';

class CloudinaryMediaService {
  CloudinaryMediaService({
    required Dio dio,
    required String cloudName,
    required String audioUploadPreset,
    required String imageUploadPreset,
  })  : _dio = dio,
        _cloudName = cloudName,
        _audioUploadPreset = audioUploadPreset,
        _imageUploadPreset = imageUploadPreset;

  final Dio _dio;
  final String _cloudName;
  final String _audioUploadPreset;
  final String _imageUploadPreset;

  bool get isConfigured =>
      _cloudName.trim().isNotEmpty &&
      _audioUploadPreset.trim().isNotEmpty &&
      _imageUploadPreset.trim().isNotEmpty;

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
    int height = 180,
  }) {
    final base = 'https://res.cloudinary.com/$_cloudName/video/upload';
    return '$base/fl_waveform,w_$width,h_$height,c_fill,co_rgb:ffffff,b_rgb:111111/$audioPublicId.png';
  }

  Future<CloudinaryAsset> _upload({
    required String resourceType,
    required String filePath,
    required String fileName,
    required String uploadPreset,
    ProgressCallback? onSendProgress,
  }) async {
    if (!isConfigured) {
      throw StateError(
        'Cloudinary is not configured. Add CLOUDINARY_CLOUD_NAME, '
        'CLOUDINARY_AUDIO_UPLOAD_PRESET, and CLOUDINARY_IMAGE_UPLOAD_PRESET to your --dart-define values.',
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
      throw const FormatException('Cloudinary returned an empty response.');
    }

    final secureUrl = data['secure_url'] as String?;
    final publicId = data['public_id'] as String?;

    if (secureUrl == null || publicId == null) {
      throw const FormatException('Cloudinary response is missing secure_url or public_id.');
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
