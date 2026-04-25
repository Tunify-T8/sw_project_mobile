import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/utils/shared_track_link_opener.dart';

void main() {
  group('parseTrackShareLink', () {
    test('extracts track id and private token from Tunify share URL', () {
      final parsed = parseTrackShareLink(
        'https://tunify.duckdns.org/tracks/track-123?privateToken=abc123',
      );

      expect(parsed?.trackId, 'track-123');
      expect(parsed?.privateToken, 'abc123');
    });

    test('accepts relative track route used by Flutter deep links', () {
      final parsed = parseTrackShareLink('/tracks/track-123?privateToken=abc123');

      expect(parsed?.trackId, 'track-123');
      expect(parsed?.privateToken, 'abc123');
    });

    test('rejects non Tunify URLs', () {
      expect(
        parseTrackShareLink(
          'https://example.com/tracks/track-123?privateToken=abc123',
        ),
        isNull,
      );
    });
  });
}
