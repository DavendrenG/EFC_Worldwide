import 'dart:async';

/// Topics the CMS can publish to. Keep these in sync with the backend.
class PushTopics {
  PushTopics._();

  static const allFans = 'efc_all';
  static const eventAnnouncements = 'efc_events';
  static const fightWeek = 'efc_fight_week';
  static const liveResults = 'efc_live_results';
  static const news = 'efc_news';

  /// Per-fighter topic so a fan can follow one athlete.
  static String fighter(String fighterId) =>
      'efc_fighter_${fighterId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_')}';

  static const defaults = <String>[
    allFans,
    eventAnnouncements,
    fightWeek,
    liveResults,
  ];
}

/// A push message normalised across FCM and HMS so the app only handles
/// one shape. `deepLink` drives in-app routing, e.g. `efc://event/efc-137`.
class PushMessage {
  const PushMessage({
    this.title,
    this.body,
    this.deepLink,
    this.data = const {},
  });

  final String? title;
  final String? body;
  final String? deepLink;
  final Map<String, String> data;

  factory PushMessage.fromData(
    Map<String, dynamic> data, {
    String? title,
    String? body,
  }) {
    final flat = <String, String>{
      for (final e in data.entries) e.key: e.value?.toString() ?? '',
    };
    return PushMessage(
      title: title,
      body: body,
      deepLink: flat['deep_link'] ?? flat['deeplink'] ?? flat['link'],
      data: flat,
    );
  }
}

/// Implemented once per push vendor.
abstract class PushService {
  /// Vendor name, for diagnostics and the debug screen.
  String get vendor;

  /// True once a token has been obtained.
  bool get isAvailable;

  /// Device push token, for targeting a single device from the CMS.
  String? get token;

  Future<void> initialise();
  Future<bool> requestPermission();
  Future<void> subscribe(String topic);
  Future<void> unsubscribe(String topic);

  /// Fired when a push is tapped and the app opens.
  Stream<PushMessage> get onMessageOpened;

  /// Fired when a push arrives with the app in the foreground.
  Stream<PushMessage> get onForegroundMessage;

  Future<void> dispose();
}

/// Used on platforms with no push vendor available (e.g. desktop, or an
/// Android device with neither GMS nor HMS). Everything no-ops safely.
class NoopPushService implements PushService {
  final _opened = StreamController<PushMessage>.broadcast();
  final _foreground = StreamController<PushMessage>.broadcast();

  @override
  String get vendor => 'none';

  @override
  bool get isAvailable => false;

  @override
  String? get token => null;

  @override
  Future<void> initialise() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> subscribe(String topic) async {}

  @override
  Future<void> unsubscribe(String topic) async {}

  @override
  Stream<PushMessage> get onMessageOpened => _opened.stream;

  @override
  Stream<PushMessage> get onForegroundMessage => _foreground.stream;

  @override
  Future<void> dispose() async {
    await _opened.close();
    await _foreground.close();
  }
}
