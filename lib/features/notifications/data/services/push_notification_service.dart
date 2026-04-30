import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles local push notifications displayed on the device.
///
/// In mock mode the mock repository calls [show] directly.
/// In real mode, the FCM onMessage handler calls [show] when a
/// push payload arrives — the only change needed is wiring FCM
/// in [bootstrap()].
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final _tapController = StreamController<String?>.broadcast();

  /// Stream of notification payloads tapped by the user.
  Stream<String?> get onNotificationTap => _tapController.stream;

  bool _initialized = false;
  Future<void>? _initFuture;

  /// Must be called once at app startup (in bootstrap).
  Future<void> init() async {
    if (_initialized) return;
    if (!_canUseLocalNotifications) {
      _initialized = true;
      return;
    }

    final existing = _initFuture;
    if (existing != null) return existing;

    _initFuture = _initPlugin();
    try {
      await _initFuture;
      _initialized = true;
    } catch (_) {
      _initFuture = null;
      rethrow;
    }
  }

  Future<void> _initPlugin() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        _tapController.add(response.payload);
      },
    );

    // Request notification permission on Android 13+.
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Show a push notification on the device.
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_canUseLocalNotifications) return;

    await init();

    const androidDetails = AndroidNotificationDetails(
      'tunify_notifications',
      'Notifications',
      channelDescription: 'Tunify activity notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF5500),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }

  void dispose() {
    _tapController.close();
  }
}

bool get _canUseLocalNotifications => Platform.isAndroid || Platform.isIOS;
