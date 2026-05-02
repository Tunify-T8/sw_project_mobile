import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/notification_entity.dart';
import '../api/notification_api.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase may be missing native config in local/dev builds.
  }
}

/// Handles local and Firebase Cloud Messaging push notifications.
///
/// Socket.IO keeps the in-app Activity screen live while the app is running.
/// FCM handles background/killed delivery and registers this device with the
/// backend `/notifications/device-token` endpoint.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final _tapController = StreamController<String?>.broadcast();
  final List<String?> _pendingTapPayloads = [];

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  bool _initialized = false;
  bool _fcmReady = false;
  String? _registeredToken;
  Future<void>? _initFuture;
  Future<void>? _fcmInitFuture;

  /// Stream of notification payloads tapped by the user.
  Stream<String?> get onNotificationTap => _tapController.stream;

  /// Must be called once at app startup.
  Future<void> init() async {
    if (_initialized) return;
    if (!_canUseLocalNotifications) {
      _initialized = true;
      return;
    }

    final existing = _initFuture;
    if (existing != null) return existing;

    _initFuture = _initialize();
    try {
      await _initFuture;
      _initialized = true;
    } catch (_) {
      _initFuture = null;
      rethrow;
    }
  }

  Future<void> _initialize() async {
    await _initPlugin();
    await _initFirebaseMessaging();
  }

  Future<void> _initPlugin() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        _emitOrQueueTap(response.payload);
      },
    );

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> _initFirebaseMessaging() async {
    if (!_canUsePushNotifications || _fcmReady) return;

    final existing = _fcmInitFuture;
    if (existing != null) return existing;

    _fcmInitFuture = _configureFirebaseMessaging();
    await _fcmInitFuture;
  }

  Future<void> _configureFirebaseMessaging() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );

      _foregroundSub ??= FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
      );
      _openedAppSub ??= FirebaseMessaging.onMessageOpenedApp.listen(
        _handleOpenedMessage,
      );

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _emitOrQueueTap(_payloadFromRemoteMessage(initialMessage));
      }

      _fcmReady = true;
    } catch (e) {
      _fcmInitFuture = null;
      _fcmReady = false;
      debugPrint('[PushNotifications] Firebase Messaging unavailable: $e');
    }
  }

  /// Registers this device's FCM token with the authenticated backend.
  ///
  /// Safe to call after login/session restore. Registration failures are logged
  /// instead of blocking auth, since push should never prevent sign-in.
  Future<void> syncDeviceToken() async {
    if (!_canUsePushNotifications) return;
    await init();
    if (!_fcmReady) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;

    await _registerDeviceToken(token);

    _tokenRefreshSub ??= FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) => unawaited(_registerDeviceToken(newToken, force: true)),
    );
  }

  /// Removes this device token from the backend before logout clears auth.
  Future<void> unregisterDeviceToken() async {
    if (!_canUsePushNotifications) return;
    await init();
    if (!_fcmReady) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await NotificationApi(
          DioClient.create(const TokenStorage()),
        ).removeDeviceToken(token);
      } catch (e) {
        debugPrint('[PushNotifications] Failed to remove device token: $e');
      }
    }

    _registeredToken = null;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }

  Future<void> _registerDeviceToken(String token, {bool force = false}) async {
    if (!force && _registeredToken == token) return;

    try {
      await NotificationApi(
        DioClient.create(const TokenStorage()),
      ).registerDeviceToken(token: token, platform: _platformName);
      _registeredToken = token;
    } catch (e) {
      debugPrint('[PushNotifications] Failed to register device token: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // When the app is foreground, the Socket.IO connection is live and
    // notifications_controller already shows a local notification from the
    // socket event. Showing one here too would double-notify the user.
    // FCM's setForegroundNotificationPresentationOptions(alert: false) already
    // suppresses the system banner — nothing more to do here.
  }

  void _handleOpenedMessage(RemoteMessage message) {
    _emitOrQueueTap(_payloadFromRemoteMessage(message));
  }

  /// Show a local notification on the device.
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
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  String payloadForNotification(NotificationEntity notification) {
    return jsonEncode({
      'id': notification.id,
      'type': notification.type.value,
      if (notification.referenceType != null)
        'referenceType': notification.referenceType,
      if (notification.referenceId != null)
        'referenceId': notification.referenceId,
      'message': notification.message,
      if (notification.actor != null) ...{
        'actorId': notification.actor!.id,
        'actorName': notification.actor!.username,
        if (notification.actor!.avatarUrl != null)
          'actorAvatarUrl': notification.actor!.avatarUrl,
      },
    });
  }

  List<String?> takePendingTapPayloads() {
    final pending = List<String?>.from(_pendingTapPayloads);
    _pendingTapPayloads.clear();
    return pending;
  }

  void _emitOrQueueTap(String? payload) {
    if (_tapController.hasListener) {
      _tapController.add(payload);
    } else {
      _pendingTapPayloads.add(payload);
    }
  }

  String? _payloadFromRemoteMessage(RemoteMessage message) {
    final payload = <String, dynamic>{
      ...message.data.map((key, value) => MapEntry(key, value.toString())),
      if (message.messageId != null) 'messageId': message.messageId,
      if (message.notification?.title != null)
        'title': message.notification!.title,
      if (message.notification?.body != null)
        'message': message.notification!.body,
    };

    if (payload.isEmpty) return null;
    return jsonEncode(payload);
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    _foregroundSub?.cancel();
    _openedAppSub?.cancel();
    _tapController.close();
  }
}

bool get _canUseLocalNotifications => Platform.isAndroid || Platform.isIOS;
bool get _canUsePushNotifications => Platform.isAndroid || Platform.isIOS;

String get _platformName {
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'ios';
  return Platform.operatingSystem;
}
