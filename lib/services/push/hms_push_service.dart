import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:huawei_push/huawei_push.dart' as hms;

import '../local_notifications.dart';
import 'push_service.dart';

/// Huawei Mobile Services push, for AppGallery builds on devices without
/// Google Play Services. Android only - every call is guarded so that
/// including this file on iOS is harmless.
class HmsPushService implements PushService {
  final _opened = StreamController<PushMessage>.broadcast();
  final _foreground = StreamController<PushMessage>.broadcast();
  final _subs = <StreamSubscription<dynamic>>[];

  String? _token;
  bool _available = false;

  @override
  String get vendor => 'hms';

  @override
  bool get isAvailable => _available;

  @override
  String? get token => _token;

  @override
  Future<void> initialise() async {
    try {
      hms.Push.enableLogger();

      final tokenCompleter = Completer<String?>();
      _subs.add(
        hms.Push.getTokenStream.listen(
          (String token) {
            _token = token;
            _available = token.isNotEmpty;
            if (!tokenCompleter.isCompleted) tokenCompleter.complete(token);
            // TODO: POST the token to the EFC backend.
          },
          onError: (Object e) {
            debugPrint('HMS token error: $e');
            if (!tokenCompleter.isCompleted) tokenCompleter.complete(null);
          },
        ),
      );

      await hms.Push.turnOnPush();
      hms.Push.getToken('');

      // Data messages while the app is in the foreground.
      _subs.add(
        hms.Push.onMessageReceivedStream.listen((hms.RemoteMessage m) {
          final msg = _mapRemote(m);
          _foreground.add(msg);
          LocalNotifications.instance.show(
            title: msg.title ?? 'EFC',
            body: msg.body ?? '',
            payload: msg.deepLink,
          );
        }),
      );

      // Tapping a notification that carries a custom intent / data payload.
      _subs.add(
        hms.Push.onNotificationOpenedApp.listen((dynamic event) {
          _opened.add(_mapDynamic(event));
        }),
      );

      final initial = await hms.Push.getInitialNotification();
      if (initial != null) {
        _opened.add(_mapDynamic(initial));
      }

      await tokenCompleter.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () => null,
      );

      for (final t in PushTopics.defaults) {
        await subscribe(t);
      }
    } catch (e) {
      _available = false;
      debugPrint('HMS push unavailable: $e');
    }
  }

  PushMessage _mapRemote(hms.RemoteMessage m) {
    final data = <String, dynamic>{};
    final raw = m.data;
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          data.addAll(decoded.cast<String, dynamic>());
        }
      } catch (_) {
        data['raw'] = raw;
      }
    }
    return PushMessage.fromData(
      data,
      title: m.notification?.title,
      body: m.notification?.body,
    );
  }

  PushMessage _mapDynamic(dynamic event) {
    if (event is Map) {
      return PushMessage.fromData(event.cast<String, dynamic>());
    }
    if (event is String) {
      try {
        final decoded = jsonDecode(event);
        if (decoded is Map) {
          return PushMessage.fromData(decoded.cast<String, dynamic>());
        }
      } catch (_) {
        return PushMessage(deepLink: event);
      }
    }
    return const PushMessage();
  }

  @override
  Future<bool> requestPermission() async {
    try {
      // HMS does not gate on a runtime prompt below Android 13; the
      // POST_NOTIFICATIONS permission is requested by the local notifications
      // plugin on 13+.
      await hms.Push.turnOnPush();
      return true;
    } catch (e) {
      debugPrint('HMS permission failed: $e');
      return false;
    }
  }

  @override
  Future<void> subscribe(String topic) async {
    try {
      await hms.Push.subscribe(topic);
    } catch (e) {
      debugPrint('HMS subscribe failed for $topic: $e');
    }
  }

  @override
  Future<void> unsubscribe(String topic) async {
    try {
      await hms.Push.unsubscribe(topic);
    } catch (e) {
      debugPrint('HMS unsubscribe failed for $topic: $e');
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
