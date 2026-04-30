import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/notifications/domain/entities/notification_preferences_entity.dart';

void main() {
  group('PreferenceChannel', () {
    test('creates with default all enabled', () {
      const channel = PreferenceChannel();

      expect(channel.trackLiked, true);
      expect(channel.trackCommented, true);
      expect(channel.trackReposted, true);
      expect(channel.userFollowed, true);
      expect(channel.newRelease, true);
      expect(channel.newMessage, true);
      expect(channel.system, true);
      expect(channel.subscription, true);
    });

    test('creates with custom settings', () {
      const channel = PreferenceChannel(
        trackLiked: false,
        trackCommented: true,
        trackReposted: false,
        userFollowed: true,
        newRelease: false,
        newMessage: true,
        system: false,
        subscription: true,
      );

      expect(channel.trackLiked, false);
      expect(channel.trackCommented, true);
      expect(channel.trackReposted, false);
      expect(channel.userFollowed, true);
    });

    test('copyWith updates specific preferences', () {
      const original = PreferenceChannel(
        trackLiked: true,
        trackCommented: true,
      );

      final updated = original.copyWith(
        trackLiked: false,
      );

      expect(updated.trackLiked, false);
      expect(updated.trackCommented, true); // Preserved
    });

    test('copyWith preserves all when not specified', () {
      const original = PreferenceChannel(
        trackLiked: false,
        trackCommented: false,
        newMessage: true,
      );

      final updated = original.copyWith();

      expect(updated.trackLiked, false);
      expect(updated.trackCommented, false);
      expect(updated.newMessage, true);
    });

    test('converts to map', () {
      const channel = PreferenceChannel(
        trackLiked: true,
        trackCommented: false,
        newMessage: true,
      );

      final map = channel.toMap();

      expect(map['trackLiked'], true);
      expect(map['trackCommented'], false);
      expect(map['newMessage'], true);
      expect(map.length, 8); // All 8 preferences
    });

    test('toMap includes all preferences', () {
      const channel = PreferenceChannel();
      final map = channel.toMap();

      expect(map.keys, contains('trackLiked'));
      expect(map.keys, contains('trackCommented'));
      expect(map.keys, contains('trackReposted'));
      expect(map.keys, contains('userFollowed'));
      expect(map.keys, contains('newRelease'));
      expect(map.keys, contains('newMessage'));
      expect(map.keys, contains('system'));
      expect(map.keys, contains('subscription'));
    });
  });

  group('NotificationPreferencesEntity', () {
    test('creates with push and email channels', () {
      const prefs = NotificationPreferencesEntity();

      expect(prefs.push, isA<PreferenceChannel>());
      expect(prefs.email, isA<PreferenceChannel>());
    });

    test('allows separate push and email settings', () {
      const prefs = NotificationPreferencesEntity(
        push: PreferenceChannel(trackLiked: true, newMessage: false),
        email: PreferenceChannel(trackLiked: false, newMessage: true),
      );

      expect(prefs.push.trackLiked, true);
      expect(prefs.push.newMessage, false);
      expect(prefs.email.trackLiked, false);
      expect(prefs.email.newMessage, true);
    });

    test('copyWith updates push channel', () {
      const original = NotificationPreferencesEntity(
        push: PreferenceChannel(trackLiked: true),
        email: PreferenceChannel(trackLiked: false),
      );

      const newPush = PreferenceChannel(trackLiked: false);
      final updated = original.copyWith(push: newPush);

      expect(updated.push.trackLiked, false);
      expect(updated.email.trackLiked, false); // Preserved
    });

    test('copyWith updates email channel', () {
      const original = NotificationPreferencesEntity(
        push: PreferenceChannel(trackLiked: true),
        email: PreferenceChannel(trackLiked: false),
      );

      const newEmail = PreferenceChannel(trackLiked: true, newMessage: false);
      final updated = original.copyWith(email: newEmail);

      expect(updated.email.trackLiked, true);
      expect(updated.email.newMessage, false);
      expect(updated.push.trackLiked, true); // Preserved
    });

    test('copyWith preserves both channels when not specified', () {
      const push = PreferenceChannel(trackLiked: false, newMessage: true);
      const email = PreferenceChannel(trackCommented: false);

      const original = NotificationPreferencesEntity(
        push: push,
        email: email,
      );

      final updated = original.copyWith();

      expect(updated.push.trackLiked, false);
      expect(updated.push.newMessage, true);
      expect(updated.email.trackCommented, false);
    });

    test('defaults to all channels enabled', () {
      const prefs = NotificationPreferencesEntity();

      expect(prefs.push.trackLiked, true);
      expect(prefs.push.newMessage, true);
      expect(prefs.email.trackLiked, true);
      expect(prefs.email.newMessage, true);
    });

    test('supports disable all notifications for a channel', () {
      const disabledChannel = PreferenceChannel(
        trackLiked: false,
        trackCommented: false,
        trackReposted: false,
        userFollowed: false,
        newRelease: false,
        newMessage: false,
        system: false,
        subscription: false,
      );

      const prefs = NotificationPreferencesEntity(push: disabledChannel);

      expect(prefs.push.trackLiked, false);
      expect(prefs.push.newMessage, false);
      expect(prefs.email.trackLiked, true); // Email still enabled
    });
  });
}
