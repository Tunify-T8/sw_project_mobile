enum ArtistTier {
  free,
  pro,
}

class ArtistToolsQuota {
  final ArtistTier tier;
  final int uploadMinutesLimit;
  final int uploadMinutesUsed;
  final bool canReplaceFiles;
  final bool canUpgrade;

  const ArtistToolsQuota({
    required this.tier,
    required this.uploadMinutesLimit,
    required this.uploadMinutesUsed,
    required this.canReplaceFiles,
    required this.canUpgrade,
  });

  int get uploadMinutesRemaining => uploadMinutesLimit - uploadMinutesUsed;

  bool get isFree => tier == ArtistTier.free;
  bool get canAmplify => tier == ArtistTier.pro;
}