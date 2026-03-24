// Upload Feature Guide:
// Purpose: Domain model used by the upload feature to keep business data independent from API shapes.
// Used by: upload_mappers, cloudinary_upload_mapper, cloudinary_upload_repository_impl, and 10 more upload files.
// Concerns: Multi-format support; Transcoding logic.
import 'upload_status.dart';

class UploadedTrack {
  final String trackId;
  final UploadStatus status;
  final String? audioUrl;
  final String? waveformUrl;
  final String? title;
  final String? description;
  final String? privacy;
  final String? artworkUrl;
  final int? durationSeconds;
  final List<String> artists;
  final String? errorCode;
  final String? errorMessage;

  const UploadedTrack({
    required this.trackId,
    required this.status,
    this.audioUrl,
    this.waveformUrl,
    this.title,
    this.description,
    this.privacy,
    this.artworkUrl,
    this.durationSeconds,
    this.artists = const [],
    this.errorCode,
    this.errorMessage,
  });

  UploadedTrack copyWith({
    String? trackId,
    UploadStatus? status,
    String? audioUrl,
    String? waveformUrl,
    String? title,
    String? description,
    String? privacy,
    String? artworkUrl,
    int? durationSeconds,
    List<String>? artists,
    String? errorCode,
    String? errorMessage,
  }) {
    return UploadedTrack(
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      audioUrl: audioUrl ?? this.audioUrl,
      waveformUrl: waveformUrl ?? this.waveformUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      privacy: privacy ?? this.privacy,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      artists: artists ?? this.artists,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
