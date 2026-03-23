/// Signed, expiring streaming URL returned by POST /tracks/{id}/stream.
class StreamUrl {
  const StreamUrl({
    required this.trackId,
    required this.url,
    required this.expiresInSeconds,
    required this.format,
  });

  final String trackId;
  final String url;
  final int expiresInSeconds;
  final String format; // 'hls' | 'mp3'

  bool get isHls => format == 'hls';
}
