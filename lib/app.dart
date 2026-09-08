import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/efc_repository.dart';
import 'screens/root_shell.dart';
import 'services/local_notifications.dart';
import 'services/push/push_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'package:collection/collection.dart';

class EfcApp extends StatefulWidget {
  const EfcApp({
    super.key,
    required this.repository,
    required this.push,
  });

  final EfcRepository repository;
  final PushService push;

  @override
  State<EfcApp> createState() => _EfcAppState();
}

class _EfcAppState extends State<EfcApp> {
  late final AppState _state;
  final _subs = <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
    _state = AppState(repository: widget.repository, push: widget.push);
    _state.load();

    // Route on notification tap, from push or from a foreground local alert.
    _subs.add(widget.push.onMessageOpened.listen((m) => _handle(m.deepLink)));
    _subs.add(LocalNotifications.instance.onTapped.listen(_handle));
  }

  /// Deep links use the form `efc://<section>/<id>`, e.g. `efc://event/efc-137`.
  void _handle(String? link) {
    if (link == null || link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri == null) return;

    final section = uri.host.isNotEmpty ? uri.host : uri.pathSegments.firstOrNull;
    final tabForSection = switch (section) {
      'event' || 'events' || 'schedule' => 1,
      'fighter' || 'athlete' || 'athletes' => 2,
      'video' || 'watch' => 3,
      'article' || 'news' => 4,
      _ => 0,
    };

    // Wait a frame so the shell exists before switching tabs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RootShell.shellKey.currentState?.goToTab(tabForSection);
    });
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<AppState>.value(
        value: _state,
        child: MaterialApp(
          title: 'EFC',
          debugShowCheckedModeBanner: false,
          theme: EfcTheme.build(),
          navigatorKey: RootShell.navigatorKey,
          home: RootShell(key: RootShell.shellKey),
          // Respect the user's font size, but stop extreme scaling from
          // breaking the condensed display type.
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );
}
