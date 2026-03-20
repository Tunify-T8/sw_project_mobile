import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/picked_upload_file.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_quota.dart';

void main() {
  group('UploadQuota', () {
    const freeQuota = UploadQuota(
      tier: 'free',
      uploadMinutesLimit: 180,
      uploadMinutesUsed: 12,
      uploadMinutesRemaining: 168,
      canReplaceFiles: false,
      canScheduleRelease: false,
      canAccessAdvancedTab: false,
    );

    const proQuota = UploadQuota(
      tier: 'Pro',
      uploadMinutesLimit: 0,
      uploadMinutesUsed: 0,
      uploadMinutesRemaining: 0,
      canReplaceFiles: true,
      canScheduleRelease: true,
      canAccessAdvancedTab: true,
    );

    test('derived getters expose upgrade and unlimited states', () {
      expect(freeQuota.canUpgrade, isFalse);
      expect(freeQuota.isUnlimited, isFalse);

      expect(proQuota.canUpgrade, isTrue);
      expect(proQuota.isUnlimited, isTrue);
    });

    test('minutesRequiredForDuration handles non-positive values and rounds up', () {
      expect(freeQuota.minutesRequiredForDuration(0), 0);
      expect(freeQuota.minutesRequiredForDuration(-5), 0);

      expect(freeQuota.minutesRequiredForDuration(1), 1);
      expect(freeQuota.minutesRequiredForDuration(60), 1);
      expect(freeQuota.minutesRequiredForDuration(61), 2);
      expect(freeQuota.minutesRequiredForDuration(245), 5);
    });

    test('canUploadDuration respects unlimited accounts and remaining minutes', () {
      expect(proQuota.canUploadDuration(999999), isTrue);

      expect(freeQuota.canUploadDuration(60), isTrue);
      expect(freeQuota.canUploadDuration(168 * 60), isTrue);
      expect(freeQuota.canUploadDuration((168 * 60) + 1), isFalse);
    });

    test('consumeDuration returns the same instance for unlimited or non-positive duration', () {
      expect(identical(proQuota.consumeDuration(400), proQuota), isTrue);
      expect(identical(freeQuota.consumeDuration(0), freeQuota), isTrue);
      expect(identical(freeQuota.consumeDuration(-7), freeQuota), isTrue);
    });

    test('consumeDuration rounds up minutes and caps the used value at the limit', () {
      final updated = freeQuota.consumeDuration(61);

      expect(updated.uploadMinutesUsed, 14);
      expect(updated.uploadMinutesRemaining, 166);
      expect(updated.tier, freeQuota.tier);
      expect(updated.canReplaceFiles, freeQuota.canReplaceFiles);
      expect(updated.canScheduleRelease, freeQuota.canScheduleRelease);
      expect(updated.canAccessAdvancedTab, freeQuota.canAccessAdvancedTab);

      final capped = freeQuota.consumeDuration(200000);

      expect(capped.uploadMinutesUsed, 180);
      expect(capped.uploadMinutesRemaining, 0);
    });
  });

  group('PickedUploadFile', () {
    test('durationMinutesCeil returns null when duration is missing or non-positive', () {
      const missingDuration = PickedUploadFile(
        name: 'track.mp3',
        path: '/tmp/track.mp3',
        sizeBytes: 2048,
      );

      const zeroDuration = PickedUploadFile(
        name: 'track.mp3',
        path: '/tmp/track.mp3',
        sizeBytes: 2048,
        durationSeconds: 0,
      );

      const negativeDuration = PickedUploadFile(
        name: 'track.mp3',
        path: '/tmp/track.mp3',
        sizeBytes: 2048,
        durationSeconds: -10,
      );

      expect(missingDuration.durationMinutesCeil, isNull);
      expect(zeroDuration.durationMinutesCeil, isNull);
      expect(negativeDuration.durationMinutesCeil, isNull);
    });

    test('durationMinutesCeil rounds up partial minutes', () {
      const oneSecond = PickedUploadFile(
        name: 'a.mp3',
        path: '/tmp/a.mp3',
        sizeBytes: 100,
        durationSeconds: 1,
      );

      const oneMinute = PickedUploadFile(
        name: 'b.mp3',
        path: '/tmp/b.mp3',
        sizeBytes: 100,
        durationSeconds: 60,
      );

      const oneMinuteOneSecond = PickedUploadFile(
        name: 'c.mp3',
        path: '/tmp/c.mp3',
        sizeBytes: 100,
        durationSeconds: 61,
      );

      const fourMinutesFiveSeconds = PickedUploadFile(
        name: 'd.mp3',
        path: '/tmp/d.mp3',
        sizeBytes: 100,
        durationSeconds: 245,
      );

      expect(oneSecond.durationMinutesCeil, 1);
      expect(oneMinute.durationMinutesCeil, 1);
      expect(oneMinuteOneSecond.durationMinutesCeil, 2);
      expect(fourMinutesFiveSeconds.durationMinutesCeil, 5);
    });
  });
}