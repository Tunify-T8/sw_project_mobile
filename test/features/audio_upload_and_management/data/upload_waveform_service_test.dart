import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/upload_waveform_service.dart';

void main() {
  group('UploadWaveformService', () {
    test('generateDisplayBarsFromFile returns null for empty and unsupported paths', () async {
      final service = UploadWaveformService();

      expect(await service.generateDisplayBarsFromFile('   '), isNull);
      expect(await service.generateDisplayBarsFromFile(r'C:\music\track.mp3'), isNull);
    });

    test('buildDisplayWaveformBars drops invalid samples and returns empty for silent audio', () {
      expect(
        buildDisplayWaveformBars(const [double.nan, double.infinity, 0, -0], targetBarCount: 4),
        isEmpty,
      );
    });

    test('buildDisplayWaveformBars buckets samples and normalizes them into display bars', () {
      final bars = buildDisplayWaveformBars(
        const [0.0, -0.2, 0.4, 0.8, 1.2, 0.6, 0.3],
        targetBarCount: 4,
      );
      final short = buildDisplayWaveformBars(
        const [0.5, 1.0],
        targetBarCount: 10,
      );

      expect(bars, hasLength(4));
      expect(bars.every((bar) => bar >= 0.02 && bar <= 1.0), isTrue);
      expect(short, hasLength(2));
      expect(short.last, 1.0);
    });
  });
}
