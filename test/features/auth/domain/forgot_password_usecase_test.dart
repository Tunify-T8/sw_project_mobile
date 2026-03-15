import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/auth/domain/usecases/logout_usecase.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LogoutUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockRepository);
  });

  test('calls signOut on the repository', () async {
    when(mockRepository.signOut()).thenAnswer((_) async {});

    await useCase();

    verify(mockRepository.signOut()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
