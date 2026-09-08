import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import 'efc_repository.dart';

/// Live implementation backed by Cloud Firestore.
///
/// The admin panel writes to the same collections, so anything published there
/// appears in the app within a second — no deploy, no app update.
///
/// Falls back to [fallback] whenever a collection is empty or unreachable, so
/// a cold Firestore or a dropped connection still renders a usable app.
class FirestoreEfcRepository implements EfcRepository {
  FirestoreEfcRepository({
    FirebaseFirestore? firestore,
    this.fallback = const MockEfcRepository(latency: Duration.zero),
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final EfcRepository fallback;

  static const _events = 'events';
  static const _fighters = 'fighters';
  static const _videos = 'videos';
  static const _articles = 'articles';

  /// Runs [read] and drops back to [orElse] on any failure or empty result.
  Future<List<T>> _guard<T>(
    Future<List<T>> Function() read,
    Future<List<T>> Function() orElse,
  ) async {
    try {
      final result = await read();
      return result.isEmpty ? await orElse() : result;
    } catch (_) {
      return orElse();
    }
  }

  // ---------------------------------------------------------------- events

  @override
  Future<List<FightEvent>> events() => _guard(
        () async {
          final snap = await _db
              .collection(_events)
              .orderBy('starts_at')
              .get();
          return snap.docs.map((d) => FightEvent.fromJson(_withId(d))).toList();
        },
        fallback.events,
      );

  @override
  Future<FightEvent?> event(String id) async {
    try {
      final doc = await _db.collection(_events).doc(id).get();
      if (doc.exists) return FightEvent.fromJson(_withId(doc));
    } catch (_) {/* fall through */}
    return fallback.event(id);
  }

  /// Live stream of the schedule — used by the events screen so a result
  /// posted during an event lands without a pull-to-refresh.
  Stream<List<FightEvent>> watchEvents() => _db
      .collection(_events)
      .orderBy('starts_at')
      .snapshots()
      .map((s) => s.docs.map((d) => FightEvent.fromJson(_withId(d))).toList());

  // -------------------------------------------------------------- fighters

  @override
  Future<List<Fighter>> fighters() => _guard(
        () async {
          final snap = await _db.collection(_fighters).get();
          return snap.docs.map((d) => Fighter.fromJson(_withId(d))).toList();
        },
        fallback.fighters,
      );

  @override
  Future<Fighter?> fighter(String id) async {
    try {
      final doc = await _db.collection(_fighters).doc(id).get();
      if (doc.exists) return Fighter.fromJson(_withId(doc));
    } catch (_) {/* fall through */}
    return fallback.fighter(id);
  }

  // ---------------------------------------------------------------- videos

  @override
  Future<List<VideoItem>> videos() => _guard(
        () async {
          final snap = await _db
              .collection(_videos)
              .orderBy('published_at', descending: true)
              .get();
          return snap.docs.map((d) => VideoItem.fromJson(_withId(d))).toList();
        },
        fallback.videos,
      );

  // -------------------------------------------------------------- articles

  @override
  Future<List<Article>> articles() => _guard(
        () async {
          final snap = await _db
              .collection(_articles)
              .where('published', isEqualTo: true)
              .orderBy('published_at', descending: true)
              .limit(60)
              .get();
          return snap.docs.map((d) => Article.fromJson(_withId(d))).toList();
        },
        fallback.articles,
      );

  @override
  Future<Article?> article(String id) async {
    try {
      final doc = await _db.collection(_articles).doc(id).get();
      if (doc.exists) return Article.fromJson(_withId(doc));
    } catch (_) {/* fall through */}
    return fallback.article(id);
  }

  /// Live news stream. Publishing from the admin panel pushes into this
  /// within about a second — the moment that sells the product in a demo.
  Stream<List<Article>> watchArticles() => _db
      .collection(_articles)
      .where('published', isEqualTo: true)
      .orderBy('published_at', descending: true)
      .limit(60)
      .snapshots()
      .map((s) => s.docs.map((d) => Article.fromJson(_withId(d))).toList());

  /// Firestore stores Timestamps; the models expect ISO strings or millis.
  /// Also folds the document id into the payload, since models require it.
  Map<String, dynamic> _withId(DocumentSnapshot<Map<String, dynamic>> doc) {
    final raw = doc.data() ?? <String, dynamic>{};
    final out = <String, dynamic>{'id': doc.id};

    raw.forEach((key, value) {
      if (value is Timestamp) {
        out[key] = value.toDate().toIso8601String();
      } else if (value is List) {
        out[key] = value
            .map((e) => e is Map ? _normaliseMap(e) : e)
            .toList();
      } else if (value is Map) {
        out[key] = _normaliseMap(value);
      } else {
        out[key] = value;
      }
    });
    return out;
  }

  Map<String, dynamic> _normaliseMap(Map<dynamic, dynamic> input) {
    final out = <String, dynamic>{};
    input.forEach((k, v) {
      out['$k'] = v is Timestamp ? v.toDate().toIso8601String() : v;
    });
    return out;
  }
}
