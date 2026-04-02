import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/core/network/dio_client.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/features/audio_upload_and_management/data/api/upload_api.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/mock_upload_repository_impl.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/real_upload_repository_impl.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/file_picker_service.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/mock_upload_service.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_dependencies_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_backend_mode_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_dependencies_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_repository_provider.dart';

import '../helpers/local_upload_test_mocks.dart'
    show MockDio, MockMockUploadService, MockUploadApi;

class _TestAuthController extends AuthController {
  _TestAuthController(this._value);

  final AsyncValue<AuthUserEntity?> _value;

  @override
  AsyncValue<AuthUserEntity?> build() => _value;
}

void main() {
  test('backend mode defaults to real', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(uploadBackendModeProvider), UploadBackendMode.real);
    expect(container.read(libraryUploadsUseMockProvider), isFalse);
  });

  test('mock mode enables the local list path for library uploads', () {
    final container = ProviderContainer(
      overrides: [
        uploadBackendModeProvider.overrideWith((_) => UploadBackendMode.mock),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(libraryUploadsUseMockProvider), isTrue);
  });

  test(
    'upload dependency providers read the authenticated user and support overrides',
    () {
      const user = AuthUserEntity(
        id: 'user-1',
        email: 'kevin@example.com',
        username: 'Kevin',
        role: 'artist',
        isVerified: true,
      );
      final mockDio = MockDio();
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(
            () => _TestAuthController(const AsyncData(user)),
          ),
          dioProvider.overrideWithValue(mockDio),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(currentUploadUserIdProvider), 'user-1');
      expect(container.read(currentArtistNameProvider), 'Kevin');
      expect(
        container.read(filePickerServiceProvider),
        isA<FilePickerService>(),
      );
      expect(container.read(uploadApiProvider), isA<UploadApi>());
    },
  );

  test(
    'uploadRepositoryProvider selects the repository for each backend mode',
    () {
      final mockUploadService = MockMockUploadService();
      final mockUploadApi = MockUploadApi();

      final mockContainer = ProviderContainer(
        overrides: [
          uploadBackendModeProvider.overrideWith((_) => UploadBackendMode.mock),
          mockUploadServiceProvider.overrideWithValue(mockUploadService),
        ],
      );
      addTearDown(mockContainer.dispose);
      expect(
        mockContainer.read(uploadRepositoryProvider),
        isA<MockUploadRepository>(),
      );

      final realContainer = ProviderContainer(
        overrides: [
          uploadBackendModeProvider.overrideWith((_) => UploadBackendMode.real),
          uploadApiProvider.overrideWithValue(mockUploadApi),
        ],
      );
      addTearDown(realContainer.dispose);
      expect(
        realContainer.read(uploadRepositoryProvider),
        isA<RealUploadRepository>(),
      );
    },
  );
}
