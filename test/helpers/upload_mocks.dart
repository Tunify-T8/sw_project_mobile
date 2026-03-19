import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:software_project/features/audio_upload_and_management/data/api/library_uploads_api.dart';
import 'package:software_project/features/audio_upload_and_management/data/api/mock_library_uploads_api.dart';
import 'package:software_project/features/audio_upload_and_management/data/api/upload_api.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/cloudinary_media_service.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/file_picker_service.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/mock_upload_service.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/upload_waveform_service.dart';
import 'package:software_project/features/audio_upload_and_management/domain/repositories/library_uploads_repository.dart';
import 'package:software_project/features/audio_upload_and_management/domain/repositories/upload_repository.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/delete_upload_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/get_artist_tools_quota_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/get_my_uploads_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/replace_file_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/update_upload_usecase.dart';

@GenerateMocks([
  Dio,
  UploadApi,
  LibraryUploadsApi,
  MockLibraryUploadsApi,
  UploadRepository,
  LibraryUploadsRepository,
  FilePickerService,
  CloudinaryMediaService,
  MockUploadService,
  UploadWaveformService,
  GetMyUploadsUsecase,
  GetArtistToolsQuotaUsecase,
  DeleteUploadUsecase,
  ReplaceFileUsecase,
  UpdateUploadUsecase,
])
void main() {}
