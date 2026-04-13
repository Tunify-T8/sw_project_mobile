import 'dart:async';
import 'dart:math';

import '../dto/notification_dto.dart';
import 'mock_notification_store.dart';

/// Simulates incoming notifications in mock mode.
/// Generates a random notification every 30–60 seconds to demonstrate
/// push notifications appearing on the device.
class MockNotificationSimulator {
  final MockNotificationStore _store;
  Timer? _timer;
  final _rng = Random();
  int _counter = 100;

  MockNotificationSimulator(this._store);

  void start() {
    _timer?.cancel();
    _scheduleNext();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _scheduleNext() {
    final delay = Duration(seconds: 30 + _rng.nextInt(31)); // 30–60s
    _timer = Timer(delay, () {
      _generateNotification();
      _scheduleNext();
    });
  }

  void _generateNotification() {
    final templates = [
      _Template(
        type: 'track_liked',
        actors: ['Nour Ali', 'Yara Sami', 'Khaled Nabil', 'Mona Fathi'],
        messages: [
          'liked your track Midnight Echoes',
          'liked your track Summer Waves',
          'liked your track Deep Focus',
        ],
        referenceType: 'track',
      ),
      _Template(
        type: 'track_commented',
        actors: ['Tamer Hosny', 'Dina El Sherbiny', 'Amr Diab'],
        messages: [
          'commented great vibes on Midnight Echoes',
          'commented love this on Summer Waves',
          'commented amazing beat on Deep Focus',
        ],
        referenceType: 'comment',
      ),
      _Template(
        type: 'user_followed',
        actors: ['DJ Flame', 'BeatMaster', 'LoFi Queen', 'Bass Drop'],
        messages: ['started following you'],
        referenceType: 'user',
      ),
      _Template(
        type: 'track_reposted',
        actors: ['Music Hub', 'Fresh Beats', 'Cairo Sounds'],
        messages: [
          'reposted your track Midnight Echoes',
          'reposted your track Summer Waves',
        ],
        referenceType: 'track',
      ),
    ];

    final template = templates[_rng.nextInt(templates.length)];
    final actor = template.actors[_rng.nextInt(template.actors.length)];
    final message = template.messages[_rng.nextInt(template.messages.length)];
    _counter++;

    _store.addNotification(
      NotificationDto(
        id: 'notif-sim-$_counter',
        type: template.type,
        actor: NotificationActorDto(
          id: 'user-sim-${actor.toLowerCase().replaceAll(' ', '-')}',
          username: actor,
        ),
        referenceType: template.referenceType,
        referenceId: 'ref-sim-$_counter',
        message: message,
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );
  }
}

class _Template {
  final String type;
  final List<String> actors;
  final List<String> messages;
  final String referenceType;

  const _Template({
    required this.type,
    required this.actors,
    required this.messages,
    required this.referenceType,
  });
}
