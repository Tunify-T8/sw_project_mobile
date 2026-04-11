/// A single play event that occurred while the device was offline.
///
/// Queued locally and flushed to `POST /tracks/plays/batch` when the
/// device comes back online.
class OfflinePlayRecord {
  const OfflinePlayRecord({
    required this.trackId,
    required this.playedAt,
    this.completed = false,
  });

  /// The track that was played.
  final String trackId;

  /// Timestamp of when playback actually started — NOT when the batch is sent.
  final DateTime playedAt;

  /// Whether the user reached 90 % of the track duration naturally.
  final bool completed;

  OfflinePlayRecord markCompleted() => OfflinePlayRecord(
        trackId: trackId,
        playedAt: playedAt,
        completed: true,
      );

  Map<String, dynamic> toJson() => {
        'trackId': trackId,
        'playedAt': playedAt.toIso8601String(),
        'completed': completed,
      };

  factory OfflinePlayRecord.fromJson(Map<String, dynamic> json) =>
      OfflinePlayRecord(
        trackId: json['trackId'] as String,
        playedAt: DateTime.parse(json['playedAt'] as String),
        completed: json['completed'] as bool? ?? false,
      );
}
