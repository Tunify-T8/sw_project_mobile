// Upload Feature Guide:
// Purpose: Riverpod state machine for quota loading, audio selection, upload progress, cancellation, restore points, and upload completion cleanup.
// Used by: upload_flow_controller, track_metadata_provider, artist_home_screen, and 5 more upload files.
// Concerns: Multi-format support; Transcoding logic.
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/picked_upload_file.dart';
import '../../domain/entities/upload_cancellation_token.dart';
import '../../domain/entities/upload_quota.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/uploaded_track.dart';
import '../../shared/upload_error_helpers.dart';
import 'library_uploads_provider.dart';
import 'upload_dependencies_provider.dart';
import 'upload_repository_provider.dart';
import 'upload_state.dart';

part 'upload_provider_quota.dart';
part 'upload_provider_flow.dart';
part 'upload_provider_background.dart';
part 'upload_provider_helpers.dart';

class UploadNotifier extends Notifier<UploadState> {
  int _activeUploadRequestId = 0;
  int _activeCompletionRequestId = 0;
  UploadCancellationToken? _activeCancellationToken;
  _UploadRestorePoint? _activeRestorePoint;

  @override
  UploadState build() {
    return const UploadState();
  }
}

final uploadProvider = NotifierProvider<UploadNotifier, UploadState>(
  UploadNotifier.new,
);
