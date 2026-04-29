import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();

    // Android shows notification payloads itself while the app is backgrounded
    // or terminated. Data-only pushes need a local notification.
    if (message.notification == null) {
      await PushNotificationService.instance.initLocalNotifications(
        requestPermissions: false,
      );
      await PushNotificationService.instance.showRemoteMessage(message);
    }
  } catch (e) {
    debugPrint('[PushNotifications] background handler failed: $e');
  }
}

/// Handles Firebase Cloud Messaging and local device notifications.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const String _channelId = 'tunify_notifications';
  static const String _channelName = 'Notifications';
  static const String _channelDescription = 'Tunify activity notifications';
  static const String _tokenEndpoint = String.fromEnvironment(
    'FCM_TOKEN_ENDPOINT',
    defaultValue: '/notifications/device-tokens',
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final _tapController = StreamController<String?>.broadcast();

  /// Stream of notification payloads tapped by the user.
  Stream<String?> get onNotificationTap => _tapController.stream;

  bool _initialized = false;
  bool _firebaseInitialized = false;
  bool _localNotificationsInitialized = false;
  StreamSubscription<RemoteMessage>? _foregroundMessageSub;
  StreamSubscription<RemoteMessage>? _openedMessageSub;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Must be called once at app startup (in bootstrap).
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await initLocalNotifications();
    await _initFirebaseMessaging();
  }

  Future<void> initLocalNotifications({bool requestPermissions = true}) async {
    if (_localNotificationsInitialized) return;
    _localNotificationsInitialized = true;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
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

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    if (requestPermissions && Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> _initFirebaseMessaging() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      await _ensureFirebaseInitialized();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      _foregroundMessageSub ??=
          FirebaseMessaging.onMessage.listen(showRemoteMessage);
      _openedMessageSub ??= FirebaseMessaging.onMessageOpenedApp.listen(
        _handleRemoteMessageTap,
      );

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        scheduleMicrotask(() => _handleRemoteMessageTap(initialMessage));
      }

      final token = await messaging.getToken();
      debugPrint('[PushNotifications] FCM token: $token');
    } catch (e) {
      debugPrint('[PushNotifications] Firebase init skipped: $e');
    }
  }

  Future<void> _ensureFirebaseInitialized() async {
    if (_firebaseInitialized) return;
    await Firebase.initializeApp();
    _firebaseInitialized = true;
  }

  Future<String?> getFcmToken() async {
    if (!Platform.isAndroid && !Platform.isIOS) return null;

    try {
      await _ensureFirebaseInitialized();
      return FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('[PushNotifications] get token failed: $e');
      return null;
    }
  }

  void listenForTokenRefresh(Dio dio) {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    _tokenRefreshSub ??= FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) => unawaited(_sendTokenToBackend(dio, token)),
      onError: (Object error) {
        debugPrint('[PushNotifications] token refresh failed: $error');
      },
    );
  }

  Future<void> syncTokenWithBackend(Dio dio) async {
    final token = await getFcmToken();
    if (token == null || token.isEmpty) return;
    await _sendTokenToBackend(dio, token);
  }

  Future<void> unregisterTokenFromBackend(Dio dio) async {
    final token = await getFcmToken();
    if (token == null || token.isEmpty) return;

    try {
      await dio.delete(
        _tokenEndpoint,
        data: _tokenPayload(token),
      );
    } on DioException catch (e) {
      _logTokenSyncFailure('unregister', e);
    } catch (e) {
      debugPrint('[PushNotifications] unregister token failed: $e');
    }
  }

  Future<void> _sendTokenToBackend(Dio dio, String token) async {
    try {
      await dio.post(
        _tokenEndpoint,
        data: _tokenPayload(token),
      );
      debugPrint('[PushNotifications] FCM token synced');
    } on DioException catch (e) {
      _logTokenSyncFailure('sync', e);
    } catch (e) {
      debugPrint('[PushNotifications] sync token failed: $e');
    }
  }

  Map<String, dynamic> _tokenPayload(String token) {
    return {
      'token': token,
      'fcmToken': token,
      'platform': Platform.isAndroid ? 'android' : 'ios',
    };
  }

  void _logTokenSyncFailure(String action, DioException error) {
    final status = error.response?.statusCode;
    debugPrint(
      '[PushNotifications] token $action failed'
      '${status == null ? '' : ' ($status)'}: ${error.message}',
    );
  }

  Future<void> showRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? _dataString(message, 'title');
    final body =
        notification?.body ??
        _dataString(message, 'body') ??
        _dataString(message, 'message');

    if ((title == null || title.trim().isEmpty) &&
        (body == null || body.trim().isEmpty)) {
      return;
    }

    await show(
      id: _notificationId(message),
      title: title?.trim().isNotEmpty == true ? title!.trim() : 'Tunify',
      body: body?.trim() ?? '',
      payload: _payloadFor(message),
    );
  }

  /// Show a push notification on the device.
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initLocalNotifications(requestPermissions: false);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
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

  void _handleRemoteMessageTap(RemoteMessage message) {
    _tapController.add(_payloadFor(message));
  }

  int _notificationId(RemoteMessage message) {
    return (message.messageId ?? message.sentTime?.toIso8601String() ?? '')
            .hashCode &
        0x7fffffff;
  }

  String? _payloadFor(RemoteMessage message) {
    final id =
        _dataString(message, 'notificationId') ??
        _dataString(message, 'id') ??
        _dataString(message, '_id') ??
        message.messageId;
    if (message.data.isEmpty) return id;

    return jsonEncode({
      if (id != null) 'id': id,
      'data': message.data,
    });
  }

  String? _dataString(RemoteMessage message, String key) {
    final raw = message.data[key];
    final text = raw?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  void dispose() {
    _foregroundMessageSub?.cancel();
    _openedMessageSub?.cancel();
    _tokenRefreshSub?.cancel();
    _tapController.close();
  }
}
