import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/efc_repository.dart';
import 'data/firestore_repository.dart';
import 'firebase_options.dart';
import 'services/local_notifications.dart';
import 'services/push/push_bootstrap.dart';

/// Content source. Precedence: explicit API base > Firestore > bundled mock.
///
///   flutter run                                    → Firestore (live CMS)
///   flutter run --dart-define=EFC_USE_MOCK=true    → bundled content only
///   flutter run --dart-define=EFC_API_BASE=https://api.efcworldwide.com/v1
const _apiBase = String.fromEnvironment('EFC_API_BASE', defaultValue: '');
const _useMock = bool.fromEnvironment('EFC_USE_MOCK', defaultValue: false);

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

  // Firestore and messaging both need this before first use. Guarded because
  // PushBootstrap may already have initialised the default app — calling
  // initializeApp twice on the same name throws.
  var firebaseReady = false;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    firebaseReady = true;
  } catch (e) {
    // No google-services.json, no Play Services, or a bad config. The app
    // still runs on bundled content rather than showing an error screen.
    debugPrint('EFC: Firebase unavailable, falling back to bundled content. $e');
  }

  final push = await PushBootstrap.resolve();
  await push.requestPermission();
  await LocalNotifications.instance.requestAndroidPermission();

  final EfcRepository repository;
  if (_useMock || !firebaseReady) {
    repository = const MockEfcRepository();
  } else if (_apiBase.isNotEmpty) {
    repository = HttpEfcRepository(baseUrl: _apiBase);
  } else {
    // Reads the same collections the admin panel writes to. Falls back to
    // bundled content per-collection if Firestore is empty or unreachable.
    repository = FirestoreEfcRepository();
  }

  runApp(EfcApp(repository: repository, push: push));
}