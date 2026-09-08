import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/efc_repository.dart';
import '../models/models.dart';
import '../services/favorites_store.dart';
import '../services/push/push_service.dart';
import 'package:collection/collection.dart';

enum LoadStatus { idle, loading, ready, failed }

class AppState extends ChangeNotifier {
  AppState({
    required EfcRepository repository,
    required PushService push,
    FavoritesStore? favorites,
  })  : _repo = repository,
        _push = push,
        _favorites = favorites ?? FavoritesStore();

  final EfcRepository _repo;
  final PushService _push;
  final FavoritesStore _favorites;

  LoadStatus status = LoadStatus.idle;
  String? errorMessage;

  List<FightEvent> events = const [];
  List<Fighter> fighters = const [];
  List<VideoItem> videos = const [];
  List<Article> articles = const [];
  Set<String> followedFighterIds = <String>{};

  PushService get push => _push;

  /// The event the home screen leads with: next upcoming, else most recent.
  FightEvent? get featuredEvent {
    if (events.isEmpty) return null;
    final upcoming = events.where((e) => e.isUpcoming).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    if (upcoming.isNotEmpty) return upcoming.first;
    final past = [...events]..sort((a, b) => b.startsAt.compareTo(a.startsAt));
    return past.first;
  }

  List<FightEvent> get upcomingEvents {
    final list = events.where((e) => e.isUpcoming).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return list;
  }

  List<FightEvent> get pastEvents {
    final list = events.where((e) => !e.isUpcoming).toList()
      ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
    return list;
  }

  List<Fighter> get champions => fighters.where((f) => f.isChampion).toList();

  List<Fighter> fightersInDivision(String division) =>
      fighters.where((f) => f.division == division).toList()
        ..sort((a, b) {
          if (a.isChampion != b.isChampion) return a.isChampion ? -1 : 1;
          return (a.ranking ?? 99).compareTo(b.ranking ?? 99);
        });

  Fighter? fighterById(String id) =>
      fighters.where((f) => f.id == id).firstOrNull;

  List<Article> get sortedArticles {
    final list = [...articles]
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return list;
  }

  Future<void> load() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      // Kick all four off together, then await each with its real type.
      final eventsFuture = _repo.events();
      final fightersFuture = _repo.fighters();
      final videosFuture = _repo.videos();
      final articlesFuture = _repo.articles();

      events = await eventsFuture;
      fighters = await fightersFuture;
      videos = await videosFuture;
      articles = await articlesFuture;
      followedFighterIds = await _favorites.load();
      status = LoadStatus.ready;
    } catch (e) {
      errorMessage = 'Could not load EFC content. Pull down to try again.';
      status = LoadStatus.failed;
      debugPrint('AppState.load failed: $e');
    }
    notifyListeners();
  }

  Future<void> refresh() => load();

  bool isFollowing(String fighterId) => followedFighterIds.contains(fighterId);

  Future<void> toggleFollow(String fighterId) async {
    final topic = PushTopics.fighter(fighterId);
    if (followedFighterIds.contains(fighterId)) {
      followedFighterIds.remove(fighterId);
      await _push.unsubscribe(topic);
    } else {
      followedFighterIds.add(fighterId);
      await _push.subscribe(topic);
    }
    await _favorites.save(followedFighterIds);
    notifyListeners();
  }

  List<VideoItem> videosOfKind(VideoKind? kind, {bool freeOnly = false}) {
    var list = videos.where((v) => kind == null || v.kind == kind);
    if (freeOnly) list = list.where((v) => !v.isPremium);
    final result = list.toList()
      ..sort(
        (a, b) => (b.publishedAt ?? DateTime(2000))
            .compareTo(a.publishedAt ?? DateTime(2000)),
      );
    return result;
  }
}
