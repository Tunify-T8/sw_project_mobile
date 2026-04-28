import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playlists/presentation/providers/recent_playlists_provider.dart';

import '../helpers/playlist_test_mocks.dart';

void main() {
  group('RecentPlaylistItem', () {
    test('can be built from a playlist summary for library fallback cards', () {
      final summary = dummyPlaylistSummary(
        id: 'playlist-1',
        title: 'my playlist',
      );

      final item = RecentPlaylistItem.fromSummary(summary, ownerName: 'Joe');

      expect(item.id, 'playlist-1');
      expect(item.title, 'my playlist');
      expect(item.trackCount, 3);
      expect(item.isMine, isTrue);
      expect(item.ownerName, 'Joe');
      expect(item.subtitle, 'Joe - 3 tracks');
    });
  });
}
