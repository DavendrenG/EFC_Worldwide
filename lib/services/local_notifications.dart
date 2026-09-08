import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Renders notifications while the app is in the foreground, and owns the
/// Android notification channel that both FCM and HMS post into.
class LocalNotifications {
  LocalNotifications._();
  static final instance = LocalNotifications._();

  static const channelId = 'efc_main';
  static const channelName = 'EFC alerts';
  static const channelDescription =
      'Fight announcements, fight-week reminders and live results.';

  final _plugin = FlutterLocalNotificationsPlugin();
  final _tapped = StreamController<String?>.broadcast();
  bool _ready = false;

  /// Emits the payload (deep link) of a tapped local notification.
  Stream<String?> get onTapped => _tapped.stream;

  Future<void> initialise() async {
    if (_ready) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
      onDidReceiveNotificationResponse: (r) => _tapped.add(r.payload),
    );

    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
      ),
    );

    _ready = true;
  }

  /// Android 13+ runtime permission. Safe to call repeatedly.
  Future<bool> requestAndroidPermission() async {
    final impl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await impl?.requestNotificationsPermission() ?? true;
  }

  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_ready) await initialise();
    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
        ),
        payload: payload,
      );
    } catch (e) {
      debugPrint('Local notification failed: $e');
    }
  }

  Future<void> dispose() async => _tapped.close();
}
