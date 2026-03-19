import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/global_track_store.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_item.dart';

void main() {
  UploadItem buildItem({
    required String id,
    required String title,
    required DateTime createdAt,
  }) {
    return UploadItem(
      id: id,
      title: title,
      artistDisplay: 'Kevin',
      durationLabel: '1:00',
      durationSeconds: 60,
      artworkUrl: null,
      visibility: UploadVisibility.public,
      status: UploadProcessingStatus.finished,
      isExplicit: false,
      createdAt: createdAt,
    );
  }

  void clearStore() {
    for (final item in GlobalTrackStore.instance.all.toList()) {
      GlobalTrackStore.instance.remove(item.id);
    }
  }

  setUp(clearStore);
  tearDown(clearStore);

  test('add keeps newest first and replaces items with the same id', () {
    final older = buildItem(
      id: 'track-1',
      title: 'Older',
      createdAt: DateTime.utc(2026, 1, 1),
    );
    final newer = buildItem(
      id: 'track-1',
      title: 'Newer',
      createdAt: DateTime.utc(2026, 2, 1),
    );

    GlobalTrackStore.instance.add(older);
    GlobalTrackStore.instance.add(newer);

    expect(GlobalTrackStore.instance.all, hasLength(1));
    expect(GlobalTrackStore.instance.all.single.title, 'Newer');
  });

  test('update replaces existing items and inserts missing ones', () {
    final first = buildItem(
      id: 'track-1',
      title: 'First',
      createdAt: DateTime.utc(2026, 1, 1),
    );
    final second = buildItem(
      id: 'track-2',
      title: 'Second',
      createdAt: DateTime.utc(2026, 2, 1),
    );

    GlobalTrackStore.instance.add(first);
    GlobalTrackStore.instance.update(first.copyWith(title: 'Updated'));
    GlobalTrackStore.instance.update(second);

    expect(GlobalTrackStore.instance.find('track-1')?.title, 'Updated');
    expect(GlobalTrackStore.instance.all.first.id, 'track-2');
  });

  test('find and remove behave safely', () {
    final item = buildItem(
      id: 'track-1',
      title: 'Stored',
      createdAt: DateTime.utc(2026, 1, 1),
    );

    GlobalTrackStore.instance.add(item);
    expect(GlobalTrackStore.instance.find('track-1')?.title, 'Stored');
    expect(GlobalTrackStore.instance.find('missing'), isNull);

    GlobalTrackStore.instance.remove('track-1');
    expect(GlobalTrackStore.instance.find('track-1'), isNull);
  });

  test('provider exposes the singleton store', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(globalTrackStoreProvider),
      same(GlobalTrackStore.instance),
    );
  });
}
