Map<String, dynamic> createMockTrackRecord(String trackId) {
  return {
    'trackId': trackId,
    'status': 'idle',
    'title': '',
    'description': '',
    'genre': '',
    'tags': <String>[],
    'artists': <String>['ROZANA AHMED'],
    'durationSeconds': null,
    'privacy': 'public',
    'scheduledReleaseDate': null,
    'availability': {'type': 'worldwide', 'regions': <String>[]},
    'licensing': {
      'type': 'all_rights_reserved',
      'allowAttribution': false,
      'nonCommercial': false,
      'noDerivatives': false,
      'shareAlike': false,
    },
    'recordLabel': '',
    'publisher': '',
    'isrc': '',
    'pLine': '',
    'contentWarning': false,
    'permissions': {
      'enableDirectDownloads': false,
      'enableOfflineListening': false,
      'includeInRSS': true,
      'displayEmbedCode': true,
      'enableAppPlayback': true,
      'allowComments': true,
      'showCommentsPublic': true,
      'showInsightsPublic': false,
    },
    'audioUrl': null,
    'waveformUrl': null,
    'waveformBars': null,
    'artworkUrl': null,
    'createdAt': DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
    'audioMetadata': null,
  };
}

Map<String, dynamic> mockTrackFallback(String trackId) {
  return {'trackId': trackId, 'createdAt': DateTime.now().toIso8601String()};
}
