# Audio Upload & Track Management

This feature is split into four main layers:

- `data/`: API clients, DTOs, repositories, workflow helpers, and services.
- `domain/`: upload entities, repository contracts, and use cases.
- `presentation/`: Riverpod providers, controllers, screens, widgets, and UI helpers.
- `shared/`: cross-cutting upload error handling.

Every Dart file in this feature now starts with an `Upload Feature Guide` comment that explains:

- what the file is responsible for
- which nearby upload files use it
- which Module 4 concern(s) it belongs to

## Main flow

1. `presentation/screens/upload_entry_screen.dart`
   Starts the upload flow, checks auth, loads quota, opens the file picker, and creates the upload draft.
2. `presentation/providers/upload_provider.dart`
   Manages quota checks, file selection, draft creation, upload progress, cancellation, restore points, and completion cleanup.
3. `presentation/screens/track_metadata_screen.dart`
   Collects title, genre, tags, artwork, privacy, release date, and advanced metadata.
4. `presentation/providers/track_metadata_provider.dart`
   Validates metadata, saves it, and polls processing status until the track is finished or failed.
5. `presentation/screens/your_uploads_screen.dart`
   Lets the user review, filter, edit, replace, or delete uploaded tracks.

## Module 4 mapping

### Multi-Format Support

Handled by:

- `data/services/file_picker_service.dart`
- `domain/entities/picked_upload_file.dart`
- `presentation/providers/upload_provider.dart`
- `presentation/providers/upload_repository_provider.dart`
- `data/repository/mock_upload_repository_impl.dart`
- `data/repository/real_upload_repository_impl.dart`
- `data/repository/cloudinary_upload_repository_impl.dart`
- `data/api/upload_api.dart`
- `data/services/cloudinary_media_service.dart`

How it works:

- The picker accepts uploadable audio from the device.
- The active repository mode (`mock`, `cloudinary`, or `real`) decides where the file goes.
- The chosen repository uploads or simulates the audio file and returns a track id plus status.

### Metadata Engine

Handled by:

- `domain/entities/track_metadata.dart`
- `presentation/providers/track_metadata_state.dart`
- `presentation/providers/track_metadata_provider.dart`
- `presentation/providers/track_metadata_mapper.dart`
- `presentation/providers/track_metadata_validator.dart`
- `presentation/providers/track_metadata_notifier_fields.dart`
- `presentation/controllers/track_metadata_form_controllers.dart`
- `presentation/screens/track_metadata_screen.dart`
- `presentation/widgets/metadata/`
- `data/dto/finalize_track_metadata_request_dto.dart`
- `data/repository/cloudinary_upload_workflow.dart`
- `data/repository/real_upload_repository_impl.dart`
- `data/repository/mock_upload_repository_impl.dart`

How it works:

- The metadata screen edits a `TrackMetadataState`.
- Validator rules decide whether the form can be saved.
- The mapper converts state into the `TrackMetadata` entity.
- Repositories send or apply the metadata to the active backend.

### Transcoding Logic

Handled by:

- `domain/entities/upload_status.dart`
- `domain/entities/uploaded_track.dart`
- `presentation/providers/upload_state.dart`
- `presentation/providers/upload_provider.dart`
- `presentation/providers/track_metadata_provider.dart`
- `presentation/screens/upload_progress_screen.dart`
- `data/api/upload_api.dart`
- `data/dto/track_response_dto.dart`
- `data/mappers/upload_status_mapper.dart`
- `data/repository/real_upload_repository_impl.dart`
- `data/repository/cloudinary_upload_workflow.dart`
- `data/services/mock_upload_service.dart`

How it works:

- New uploads move through statuses like `idle`, `uploading`, `processing`, and `finished`.
- Real mode polls backend status endpoints.
- Cloudinary/mock flows simulate the processing stage and then mark the track finished.
- The progress screen and providers react to those state changes.

### Track Visibility

Handled by:

- `presentation/widgets/metadata/privacy_section.dart`
- `presentation/providers/track_metadata_state.dart`
- `presentation/providers/track_metadata_mapper.dart`
- `domain/entities/upload_item.dart`
- `data/dto/upload_item_dto.dart`
- `data/repository/library_uploads_repository_impl.dart`
- `presentation/providers/library_uploads_provider.dart`
- `presentation/providers/library_uploads_filter.dart`
- `presentation/screens/your_uploads_screen.dart`
- `presentation/screens/edit_track_screen.dart`

How it works:

- Privacy is edited in the metadata form as public/private.
- That value is mapped into repository/API payloads.
- The uploads library uses visibility-aware filtering and update actions.
- Track detail and edit flows read the saved visibility state from uploaded items.

### Waveform Generation

Handled by:

- `data/services/upload_waveform_service.dart`
- `data/services/cloudinary_media_service.dart`
- `data/repository/cloudinary_upload_workflow.dart`
- `presentation/providers/track_detail_waveform_provider.dart`
- `presentation/providers/track_detail_waveform_source.dart`
- `presentation/widgets/waveform_preview.dart`
- `presentation/widgets/track_detail/track_detail_waveform_panel.dart`
- `presentation/widgets/track_detail/track_detail_mock_waveform.dart`
- `presentation/widgets/track_detail/track_detail_soundcloud_waveform.dart`

How it works:

- Local audio can be analyzed into normalized bar data by `UploadWaveformService`.
- Cloudinary mode can also derive a waveform image URL from the uploaded audio asset.
- Track detail providers choose the best waveform source and feed the display widgets.

## Quick navigation tips

- Start with `presentation/providers/upload_provider.dart` if you want the upload lifecycle.
- Start with `presentation/providers/track_metadata_provider.dart` if you want the metadata save flow.
- Start with `presentation/providers/library_uploads_provider.dart` if you want track management.
- Start with `data/repository/cloudinary_upload_workflow.dart` if you want the Cloudinary-specific logic.
