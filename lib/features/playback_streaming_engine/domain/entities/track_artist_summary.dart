/// Minimal artist info embedded in playback responses.
class TrackArtistSummary {
  const TrackArtistSummary({
    required this.id,
    required this.name,
    required this.tier,
  });

  final String id;
  final String name;
  final String tier; // 'free' | 'pro'
}
