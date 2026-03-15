enum UploadVisibility {
  public,
  private,
}

enum UploadProcessingStatus {
  finished,
  processing,
  failed,
  deleted,
}

class UploadItem {
  final String id;
  final String title;
  final String artistDisplay;
  final String durationLabel;
  final int durationSeconds;
  final String? artworkUrl;
  final UploadVisibility visibility;
  final UploadProcessingStatus status;
  final bool isExplicit;
  final DateTime createdAt;

  const UploadItem({
    required this.id,
    required this.title,
    required this.artistDisplay,
    required this.durationLabel,
    required this.durationSeconds,
    required this.artworkUrl,
    required this.visibility,
    required this.status,
    required this.isExplicit,
    required this.createdAt,
  });

  bool get isPlayable => status == UploadProcessingStatus.finished;
  bool get isDeleted => status == UploadProcessingStatus.deleted;

  UploadItem copyWith({
    String? id,
    String? title,
    String? artistDisplay,
    String? durationLabel,
    int? durationSeconds,
    String? artworkUrl,
    UploadVisibility? visibility,
    UploadProcessingStatus? status,
    bool? isExplicit,
    DateTime? createdAt,
  }) {
    return UploadItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artistDisplay: artistDisplay ?? this.artistDisplay,
      durationLabel: durationLabel ?? this.durationLabel,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      isExplicit: isExplicit ?? this.isExplicit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}