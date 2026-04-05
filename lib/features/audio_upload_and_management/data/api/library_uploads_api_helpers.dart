part of 'library_uploads_api.dart';

extension _LibraryUploadsApiHelpers on LibraryUploadsApi {
  Future<UploadItemDto> _enrichCollaboratorsIfNeeded(UploadItemDto item) async {
    if (item.id.isEmpty || item.artists.length > 1) {
      return item;
    }

    try {
      final response = await dio.get(ApiEndpoints.uploadDetails(item.id));
      final raw = _normalizeTrackJson(response.data);
      final details = UploadItemDto.fromJson(raw);

      if (details.artists.isEmpty) {
        return item;
      }

      return item.copyWith(
        artists: details.artists,
        description: _preferText(details.description, item.description),
        artworkUrl: _preferText(details.artworkUrl, item.artworkUrl),
        waveformUrl: _preferText(details.waveformUrl, item.waveformUrl),
        audioUrl: _preferText(details.audioUrl, item.audioUrl),
      );
    } catch (_) {
      return item;
    }
  }

  Map<String, dynamic> _normalizeTrackJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return const <String, dynamic>{};
    }

    Map<String, dynamic> map = raw;

    if (map.containsKey('track') && map['track'] is Map<String, dynamic>) {
      map = map['track'] as Map<String, dynamic>;
    }

    if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
      map = map['data'] as Map<String, dynamic>;
    }

    if (!map.containsKey('trackId') && map.containsKey('id')) {
      map = Map<String, dynamic>.from(map)..['trackId'] = map['id'];
    }

    if (!map.containsKey('status') && map.containsKey('transcodingStatus')) {
      map = Map<String, dynamic>.from(map)
        ..['status'] = map['transcodingStatus'];
    }

    return map;
  }

  String? _preferText(String? preferred, String? fallback) {
    final trimmed = preferred?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return fallback;
    }
    return trimmed;
  }
}
