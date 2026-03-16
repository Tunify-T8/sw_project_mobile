enum UploadGenreGroup {
  music,
  audio,
}

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