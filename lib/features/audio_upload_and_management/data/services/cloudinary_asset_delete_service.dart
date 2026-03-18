import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../shared/upload_error_helpers.dart';

Future<void> deleteCloudinaryAssetByUrl({
  required Dio dio,
  required String cloudName,
  required String apiKey,
  required String apiSecret,
  required String resourceType,
  String? assetUrl,
}) async {
  final publicId = publicIdFromCloudinaryUrl(
    assetUrl,
    resourceType: resourceType,
  );
  if (publicId == null) return;

  final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final signature = sha1
      .convert(
        utf8.encode(
          'invalidate=true&public_id=$publicId&timestamp=$timestamp$apiSecret',
        ),
      )
      .toString();

  final response = await dio.post<Map<String, dynamic>>(
    'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/destroy',
    data: FormData.fromMap({
      'public_id': publicId,
      'timestamp': timestamp.toString(),
      'api_key': apiKey,
      'signature': signature,
      'invalidate': 'true',
    }),
    options: Options(contentType: 'multipart/form-data'),
  );

  final result = response.data?['result'] as String?;
  if (result != null && result != 'ok' && result != 'not found') {
    throw const UploadFlowException(
      'We could not delete the cloud file right now. Please try again.',
    );
  }
}

String? publicIdFromCloudinaryUrl(
  String? assetUrl, {
  required String resourceType,
}) {
  if (assetUrl == null || assetUrl.trim().isEmpty) return null;

  final uri = Uri.tryParse(assetUrl);
  final segments = uri?.pathSegments;
  if (uri == null || segments == null || !segments.contains(resourceType)) {
    return null;
  }

  final uploadIndex = segments.indexOf('upload');
  if (uploadIndex == -1 || uploadIndex + 1 >= segments.length) return null;

  var publicIdStart = uploadIndex + 1;
  for (var i = uploadIndex + 1; i < segments.length; i++) {
    if (RegExp(r'^v\d+$').hasMatch(segments[i])) {
      publicIdStart = i + 1;
      break;
    }
  }

  if (publicIdStart >= segments.length) return null;
  final publicIdSegments = segments.sublist(publicIdStart);
  if (publicIdSegments.isEmpty) return null;

  final lastSegment = publicIdSegments.last;
  final dotIndex = lastSegment.lastIndexOf('.');
  publicIdSegments[publicIdSegments.length - 1] = dotIndex > 0
      ? lastSegment.substring(0, dotIndex)
      : lastSegment;

  return publicIdSegments.join('/');
}
