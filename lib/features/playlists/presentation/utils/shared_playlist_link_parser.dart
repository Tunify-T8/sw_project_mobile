class SharedPlaylistLink {
  const SharedPlaylistLink({
    this.playlistId,
    this.secretToken,
  });

  final String? playlistId;
  final String? secretToken;
}

SharedPlaylistLink? parsePlaylistShareLink(String rawLink) {
  final trimmed = _extractPlaylistUrl(rawLink);
  if (trimmed.isEmpty) return null;

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;

  final isRelativePlaylistPath =
      !uri.hasScheme && _playlistIdFromSegments(uri.pathSegments) != null;
  final isTunifyUrl =
      (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.toLowerCase() == 'tunify.duckdns.org';
  final isTunifyAppLink =
      uri.scheme.toLowerCase() == 'tunify' &&
      _playlistIdFromSegments(uri.pathSegments) != null;

  if (!isRelativePlaylistPath && !isTunifyUrl && !isTunifyAppLink) {
    return null;
  }

  final playlistId = _playlistIdFromSegments(uri.pathSegments);
  final secretToken = _readPlaylistToken(uri);

  if ((playlistId == null || playlistId.isEmpty) &&
      (secretToken == null || secretToken.isEmpty)) {
    return null;
  }

  return SharedPlaylistLink(
    playlistId: playlistId?.trim(),
    secretToken: secretToken?.trim(),
  );
}

String _extractPlaylistUrl(String rawLink) {
  final trimmed = rawLink.trim();
  final match = RegExp(
    r'(https?://tunify\.duckdns\.org/playlist/[^\s]+|tunify://playlist/[^\s]+)',
    caseSensitive: false,
  ).firstMatch(trimmed);
  return match?.group(0) ?? trimmed;
}

String? _playlistIdFromSegments(List<String> segments) {
  final normalized = segments.where((segment) => segment.isNotEmpty).toList();
  final playlistIndex = normalized.indexOf('playlist');
  if (playlistIndex < 0 || playlistIndex >= normalized.length - 1) {
    return null;
  }
  return normalized[playlistIndex + 1];
}

String? _readPlaylistToken(Uri uri) {
  for (final entry in uri.queryParameters.entries) {
    final key = entry.key.toLowerCase();
    if (key == 'token') {
      return entry.value.trim();
    }
  }

  final rawQuery = uri.query;
  if (rawQuery.isEmpty) return null;

  for (final part in rawQuery.split('&')) {
    final index = part.indexOf('=');
    if (index <= 0) continue;
    final key = Uri.decodeQueryComponent(part.substring(0, index)).toLowerCase();
    if (key != 'token') continue;
    return Uri.decodeQueryComponent(part.substring(index + 1)).trim();
  }

  return null;
}
