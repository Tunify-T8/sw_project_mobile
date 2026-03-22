// Upload Feature Guide:
// Purpose: Domain model used by the upload feature to keep business data independent from API shapes.
// Used by: upload_audio_genres, upload_genres, upload_music_genres
// Concerns: Multi-format support; Metadata engine.
enum UploadGenreGroup { music, audio }

class UploadGenre {
  final String label;
  final UploadGenreGroup? group;
  final String subGenre;
  final bool isNone;

  const UploadGenre({
    required this.label,
    required this.subGenre,
    this.group,
    this.isNone = false,
  });

  String get categoryValue => group?.name ?? '';
}
