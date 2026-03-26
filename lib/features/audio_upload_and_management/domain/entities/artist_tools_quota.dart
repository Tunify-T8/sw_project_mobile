// Upload Feature Guide:
// Purpose: Domain model used by the upload feature to keep business data independent from API shapes.
// Used by: library_uploads_mapper, library_uploads_repository_impl, library_uploads_repository, and 4 more upload files.
// Concerns: Supporting UI and infrastructure for upload and track management.
enum ArtistTier { free, pro }

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
