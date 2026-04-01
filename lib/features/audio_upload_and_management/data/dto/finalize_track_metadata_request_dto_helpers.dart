part of 'finalize_track_metadata_request_dto.dart';

extension FinalizeTrackMetadataRequestDtoBody
    on FinalizeTrackMetadataRequestDto {
  Map<String, dynamic> toJsonBody() => _toJson();

  Future<FormData> toFormData() => _toFormData();

  Future<dynamic> toRequestBody() async =>
      hasLocalArtwork ? _toFormData() : _toJson();

  Map<String, dynamic> _toJson() {
    final body = <String, dynamic>{
      'title': title,
      if (genre.isNotEmpty) 'genre': genre,
      'tags': tags,
      'description': description,
      'privacy': privacy,
      if (artists.isNotEmpty) 'artists': artists,
      'recordLabel': recordLabel,
      'publisher': publisher,
      'isrc': isrc,
      'pLine': pLine,
      'contentWarning': contentWarning,
      'availability': {
        'type': availabilityType,
        'regions': availabilityRegions,
      },
      'licensing': {
        'type': licensingType,
        'allowAttribution': allowAttribution,
        'nonCommercial': nonCommercial,
        'noDerivatives': noDerivatives,
        'shareAlike': shareAlike,
      },
      'permissions': {
        'enableDirectDownloads': enableDirectDownloads,
        'enableOfflineListening': enableOfflineListening,
        'includeInRSS': includeInRss,
        'displayEmbedCode': displayEmbedCode,
        'enableAppPlayback': enableAppPlayback,
        'allowComments': true,
        'showCommentsPublic': true,
        'showInsightsPublic': false,
      },
    };

    if (scheduledReleaseDate != null) {
      body['scheduledReleaseDate'] = scheduledReleaseDate!.toIso8601String();
    }

    return body;
  }

  Future<FormData> _toFormData() async {
    final map = <String, dynamic>{
      'title': title,
      if (genre.isNotEmpty) 'genre': genre,
      'description': description,
      'privacy': privacy,
      if (artists.isNotEmpty) 'artists': artists,
      'recordLabel': recordLabel,
      'publisher': publisher,
      'isrc': isrc,
      'pLine': pLine,
      'contentWarning': contentWarning.toString(),
      'availability[type]': availabilityType,
      'licensing[type]': licensingType,
      'licensing[allowAttribution]': allowAttribution.toString(),
      'licensing[nonCommercial]': nonCommercial.toString(),
      'licensing[noDerivatives]': noDerivatives.toString(),
      'licensing[shareAlike]': shareAlike.toString(),
      'permissions[enableDirectDownloads]': enableDirectDownloads.toString(),
      'permissions[enableOfflineListening]': enableOfflineListening.toString(),
      'permissions[includeInRSS]': includeInRss.toString(),
      'permissions[displayEmbedCode]': displayEmbedCode.toString(),
      'permissions[enableAppPlayback]': enableAppPlayback.toString(),
      'permissions[allowComments]': 'true',
      'permissions[showCommentsPublic]': 'true',
      'permissions[showInsightsPublic]': 'false',
      if (tags.isNotEmpty) 'tags': tags,
      if (availabilityRegions.isNotEmpty)
        'availability[regions]': availabilityRegions,
      'artwork': await MultipartFile.fromFile(artworkPath!),
    };

    if (scheduledReleaseDate != null) {
      map['scheduledReleaseDate'] = scheduledReleaseDate!.toIso8601String();
    }

    return FormData.fromMap(map);
  }
}

String _buildGenreValue({required String category, required String subGenre}) {
  if (category.isEmpty && subGenre.isEmpty) {
    return '';
  }

  if (subGenre.isEmpty) {
    return category;
  }

  if (category.isEmpty) {
    return subGenre;
  }

  final normalizedCategory = category.trim().toLowerCase();
  final normalizedSubGenre = subGenre.trim().toLowerCase();
  final categoryPrefix = '${normalizedCategory}_';

  if (normalizedSubGenre == normalizedCategory) {
    return normalizedCategory;
  }

  if (normalizedSubGenre.startsWith(categoryPrefix)) {
    return normalizedSubGenre;
  }

  return '${normalizedCategory}_$normalizedSubGenre';
}
