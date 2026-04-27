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
  final isRelativeSecretPath =
      !uri.hasScheme && _secretTokenFromSegments(uri.pathSegments) != null;
  final isTunifyUrl =
      (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.toLowerCase() == 'tunify.duckdns.org';

  if (!isRelativePlaylistPath && !isRelativeSecretPath && !isTunifyUrl) {
    return null;
  }

  final playlistId = _playlistIdFromSegments(uri.pathSegments);
  final secretToken = _secretTokenFromSegments(uri.pathSegments);

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
    r'https?://tunify\.duckdns\.org/(playlists|s)/[^\s]+',
    caseSensitive: false,
  ).firstMatch(trimmed);
  return match?.group(0) ?? trimmed;
}

String? _playlistIdFromSegments(List<String> segments) {
  final normalized = segments.where((segment) => segment.isNotEmpty).toList();
  final playlistsIndex = normalized.indexOf('playlists');
  if (playlistsIndex < 0 || playlistsIndex >= normalized.length - 1) {
    return null;
  }
  return normalized[playlistsIndex + 1];
}

String? _secretTokenFromSegments(List<String> segments) {
  final normalized = segments.where((segment) => segment.isNotEmpty).toList();
  final secretIndex = normalized.indexOf('s');
  if (secretIndex < 0 || secretIndex >= normalized.length - 1) {
    return null;
  }
  return normalized[secretIndex + 1];
}
