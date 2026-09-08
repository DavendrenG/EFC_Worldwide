import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../local_notifications.dart';
import 'fcm_push_service.dart';
import 'hms_push_service.dart';
import 'push_service.dart';

/// Chooses the right push vendor for the device at runtime.
///
/// Order of resolution:
///   1. `--dart-define=EFC_PUSH_VENDOR=fcm|hms|none` forces a vendor.
///   2. iOS always uses FCM (which sits on top of APNs).
///   3. Android tries FCM first; if Google Play Services is missing - as on a
///      Huawei device shipped after the 2019 trade restrictions - the FCM token
///      request fails and we fall back to HMS Push Kit.
///   4. Anything else gets the no-op service.
class PushBootstrap {
  PushBootstrap._();

  static const _forcedVendor =
      String.fromEnvironment('EFC_PUSH_VENDOR', defaultValue: 'auto');

  static Future<PushService> resolve() async {
    await LocalNotifications.instance.initialise();

    if (_forcedVendor == 'none') return NoopPushService();
    if (_forcedVendor == 'hms') return _tryHms() ?? NoopPushService();
    if (_forcedVendor == 'fcm') {
      return await _tryFcm() ?? NoopPushService();
    }

    if (!kIsWeb && Platform.isIOS) {
      return await _tryFcm() ?? NoopPushService();
    }

    if (!kIsWeb && Platform.isAndroid) {
      final fcm = await _tryFcm();
      if (fcm != null && fcm.isAvailable) return fcm;

      debugPrint('Google services unavailable - falling back to HMS Push Kit.');
      final hms = _tryHms();
      if (hms != null) {
        await hms.initialise();
        if (hms.isAvailable) return hms;
      }
    }

    return NoopPushService();
  }

  static Future<PushService?> _tryFcm() async {
    try {
      await Firebase.initializeApp();
      final service = FcmPushService();
      await service.initialise();
      return service;
    } catch (e) {
      debugPrint('FCM init failed: $e');
      return null;
    }
  }

  static PushService? _tryHms() {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      return HmsPushService();
    } catch (e) {
      debugPrint('HMS init failed: $e');
      return null;
    }
  }
}
