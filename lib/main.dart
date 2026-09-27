import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/efc_repository.dart';
import 'services/local_notifications.dart';
import 'services/push/push_bootstrap.dart';

/// Point this at the EFC CMS to go live:
///   flutter run --dart-define=EFC_API_BASE=https://api.efcworldwide.com/v1
/// Leaving it empty runs the app on bundled mock content.
const _apiBase = String.fromEnvironment('EFC_API_BASE', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  final push = await PushBootstrap.resolve();
  await push.requestPermission();
  await LocalNotifications.instance.requestAndroidPermission();

  final repository = _apiBase.isEmpty
      ? const MockEfcRepository()
      : HttpEfcRepository(baseUrl: _apiBase);

  runApp(EfcApp(repository: repository, push: push));
}
