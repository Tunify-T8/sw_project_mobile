import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/auth/domain/usecases/check_email_usecase.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late CheckEmailUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = CheckEmailUseCase(mockRepository);
  });

  test('returns true when email is already registered', () async {
    when(
      mockRepository.checkEmail('existing@example.com'),
    ).thenAnswer((_) async => true);

    final result = await useCase('existing@example.com');

    expect(result, isTrue);
    verify(mockRepository.checkEmail('existing@example.com')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns false when email is not registered', () async {
    when(
      mockRepository.checkEmail('new@example.com'),
    ).thenAnswer((_) async => false);

    final result = await useCase('new@example.com');

    expect(result, isFalse);
    verify(mockRepository.checkEmail('new@example.com')).called(1);
  });
}
