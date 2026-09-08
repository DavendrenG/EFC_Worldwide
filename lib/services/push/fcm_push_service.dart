import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../local_notifications.dart';
import 'push_service.dart';

/// Must be a top-level function - the OS spawns an isolate for it.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Data-only messages can be surfaced here. Notification-type messages are
  // rendered by the OS automatically, so nothing more is needed.
}

/// Google Mobile Services push. Covers Android (Play Services) and iOS (APNs).
class FcmPushService implements PushService {
  FcmPushService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  final _opened = StreamController<PushMessage>.broadcast();
  final _foreground = StreamController<PushMessage>.broadcast();
  final _subs = <StreamSubscription<dynamic>>[];

  String? _token;
  bool _available = false;

  @override
  String get vendor => 'fcm';

  @override
  bool get isAvailable => _available;

  @override
  String? get token => _token;

  @override
  Future<void> initialise() async {
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    _token = await _messaging.getToken();
    _available = _token != null;

    _subs.add(
      _messaging.onTokenRefresh.listen((t) {
        _token = t;
        // TODO: POST the refreshed token to the EFC backend.
      }),
    );

    _subs.add(
      FirebaseMessaging.onMessage.listen((m) {
        final msg = _map(m);
        _foreground.add(msg);
        // iOS shows nothing in the foreground by default; Android needs a
        // channel. Render it ourselves for consistent behaviour.
        LocalNotifications.instance.show(
          title: msg.title ?? 'EFC',
          body: msg.body ?? '',
          payload: msg.deepLink,
        );
      }),
    );

    _subs.add(FirebaseMessaging.onMessageOpenedApp.listen((m) {
      _opened.add(_map(m));
    }));

    // App launched from terminated state by tapping a push.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _opened.add(_map(initial));
    }

    for (final t in PushTopics.defaults) {
      await subscribe(t);
    }
  }

  PushMessage _map(RemoteMessage m) => PushMessage.fromData(
        m.data,
        title: m.notification?.title,
        body: m.notification?.body,
      );

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<void> subscribe(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('FCM subscribe failed for $topic: $e');
    }
  }

  @override
  Future<void> unsubscribe(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('FCM unsubscribe failed for $topic: $e');
    }
  }

  @override
  Stream<PushMessage> get onMessageOpened => _opened.stream;

  @override
  Stream<PushMessage> get onForegroundMessage => _foreground.stream;

  @override
  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    await _opened.close();
    await _foreground.close();
  }
}
