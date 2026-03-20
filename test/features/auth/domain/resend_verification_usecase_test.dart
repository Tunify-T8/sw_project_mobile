import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/auth/domain/usecases/resend_verification_usecase.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late ResendVerificationUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ResendVerificationUseCase(mockRepository);
  });

  test('calls resendVerification with correct email', () async {
    when(
      mockRepository.resendVerification('user@example.com'),
    ).thenAnswer((_) async {});

    await useCase('user@example.com');

    verify(mockRepository.resendVerification('user@example.com')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
