import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_context_request.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_event.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_status.dart';
import 'package:software_project/features/playback_streaming_engine/domain/usecases/build_playback_queue_usecase.dart';
import 'package:software_project/features/playback_streaming_engine/domain/usecases/get_listening_history_usecase.dart';
import 'package:software_project/features/playback_streaming_engine/domain/usecases/get_playback_bundle_usecase.dart';
import 'package:software_project/features/playback_streaming_engine/domain/usecases/report_playback_event_usecase.dart';
import 'package:software_project/features/playback_streaming_engine/domain/usecases/report_track_completed_usecase.dart';
import 'package:software_project/features/playback_streaming_engine/domain/usecases/request_stream_url_usecase.dart';

import '../helpers/playback_test_utils.dart';

void main() {
  late FakePlayerRepository repository;

  setUp(() {
    repository = FakePlayerRepository();
  });

  test('GetPlaybackBundleUsecase delegates to repository', () async {
    final usecase = GetPlaybackBundleUsecase(repository);

    final result = await usecase('track-1', privateToken: 'secret');

    expect(result.trackId, 'track-1');
  });

  test('RequestStreamUrlUsecase delegates with quality', () async {
    final usecase = RequestStreamUrlUsecase(repository);

    final result = await usecase('track-1', quality: '320');

    expect(result.trackId, 'track-1');
    expect(result.format, 'hls');
  });

  test('ReportPlaybackEventUsecase forwards events', () async {
    final usecase = ReportPlaybackEventUsecase(repository);
    const event = PlaybackEvent(
      trackId: 'track-1',
      action: PlaybackAction.progress,
      positionSeconds: 15,
    );

    await usecase(event);

    expect(repository.reportedEvents.single.trackId, 'track-1');
    expect(repository.reportedEvents.single.positionSeconds, 15);
  });

  test('BuildPlaybackQueueUsecase forwards request object', () async {
    final usecase = BuildPlaybackQueueUsecase(repository);
    const request = PlaybackContextRequest(
      contextType: PlaybackContextType.feed,
      contextId: 'feed-1',
      startTrackId: 'track-2',
      shuffle: true,
      repeat: RepeatMode.all,
    );

    final queue = await usecase(request);

    expect(queue.trackIds.first, 'track-2');
    expect(queue.repeat, RepeatMode.all);
  });

  test('GetListeningHistoryUsecase requests configured page', () async {
    final usecase = GetListeningHistoryUsecase(repository);

    final result = await usecase(page: 2, limit: 5);

    expect(result.single.trackId, 'track-1');
  });

  test('ReportTrackCompletedUsecase delegates track completion', () async {
    String? completedTrackId;
    repository.reportTrackCompletedHandler = (trackId) async {
      completedTrackId = trackId;
    };
    final usecase = ReportTrackCompletedUsecase(repository);

    await usecase('track-77');

    expect(completedTrackId, 'track-77');
  });
}
