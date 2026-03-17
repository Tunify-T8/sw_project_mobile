import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/library_uploads_api.dart';
import '../../data/api/mock_library_uploads_api.dart';
import '../../data/repository/library_uploads_repository_impl.dart';
import '../../domain/repositories/library_uploads_repository.dart';
import '../../domain/usecases/delete_upload_usecase.dart';
import '../../domain/usecases/get_artist_tools_quota_usecase.dart';
import '../../domain/usecases/get_my_uploads_usecase.dart';
import '../../domain/usecases/replace_file_usecase.dart';
import '../../domain/usecases/search_my_uploads_usecase.dart';
import '../../domain/usecases/update_upload_usecase.dart';
import 'library_uploads_dependencies_provider.dart';

final libraryUploadsApiProvider = Provider<LibraryUploadsApi>((ref) {
  final dio = ref.watch(libraryUploadsDioProvider);
  return LibraryUploadsApi(dio);
});

final mockLibraryUploadsApiProvider = Provider<MockLibraryUploadsApi>((ref) {
  return MockLibraryUploadsApi();
});

final libraryUploadsRepositoryProvider = Provider<LibraryUploadsRepository>((
  ref,
) {
  return LibraryUploadsRepositoryImpl(
    api: ref.watch(libraryUploadsApiProvider),
    mockApi: ref.watch(mockLibraryUploadsApiProvider),
    useMock: ref.watch(libraryUploadsUseMockProvider),
  );
});

final getMyUploadsUsecaseProvider = Provider<GetMyUploadsUsecase>((ref) {
  return GetMyUploadsUsecase(ref.watch(libraryUploadsRepositoryProvider));
});

final getArtistToolsQuotaUsecaseProvider = Provider<GetArtistToolsQuotaUsecase>(
  (ref) {
    return GetArtistToolsQuotaUsecase(
      ref.watch(libraryUploadsRepositoryProvider),
    );
  },
);

final deleteUploadUsecaseProvider = Provider<DeleteUploadUsecase>((ref) {
  return DeleteUploadUsecase(ref.watch(libraryUploadsRepositoryProvider));
});

final replaceFileUsecaseProvider = Provider<ReplaceFileUsecase>((ref) {
  return ReplaceFileUsecase(ref.watch(libraryUploadsRepositoryProvider));
});

final searchMyUploadsUsecaseProvider = Provider<SearchMyUploadsUsecase>((ref) {
  return const SearchMyUploadsUsecase();
});

final updateUploadUsecaseProvider = Provider<UpdateUploadUsecase>((ref) {
  return UpdateUploadUsecase(ref.watch(libraryUploadsRepositoryProvider));
});
