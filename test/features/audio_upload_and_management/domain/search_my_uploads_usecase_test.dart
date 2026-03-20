import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/search_my_uploads_usecase.dart';

import '../helpers/upload_test_data.dart';

void main() {
  const usecase = SearchMyUploadsUsecase();

  test('returns every upload when the query is empty', () {
    final result = usecase(uploads: [sampleUploadItem], query: '   ');

    expect(result, [sampleUploadItem]);
  });

  test('filters by title and artist ignoring case', () {
    final secondItem = sampleUploadItem.copyWith(
      id: 'track-2',
      title: 'Sunrise Tape',
      artistDisplay: 'Luna',
    );

    final result = usecase(
      uploads: [sampleUploadItem, secondItem],
      query: 'kevin',
    );

    expect(result, [sampleUploadItem]);
  });
}
