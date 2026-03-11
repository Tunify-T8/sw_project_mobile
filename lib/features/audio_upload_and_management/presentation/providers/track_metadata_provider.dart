import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../data/services/mock_upload_service.dart';
import '../../domain/entities/track_metadata_state.dart';
import 'upload_provider.dart';

class TrackMetadataNotifier extends Notifier<TrackMetadataState> {
  @override
  TrackMetadataState build() {
    return const TrackMetadataState();
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setGenre(String value) {
    state = state.copyWith(genre: value);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  void setTags(String value) {
    state = state.copyWith(tags: value);
  }

  void setPrivacy(String value) {
    state = state.copyWith(privacy: value);
  }

  Future<bool> saveMetadata(String trackId, WidgetRef ref) async {
    state = state.copyWith(
      isSaving: true,
      error: null,
    );

    try {
      final service = ref.read(mockUploadServiceProvider);

      await service.finalizeMetadata(
        trackId: trackId,
        title: state.title,
        genre: state.genre,
        description: state.description,
        tags: state.tags,
        privacy: state.privacy,
      );

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

final trackMetadataProvider =
    NotifierProvider<TrackMetadataNotifier, TrackMetadataState>(
  TrackMetadataNotifier.new,
);