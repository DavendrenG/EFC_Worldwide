import 'package:efc_app/data/efc_repository.dart';
import 'package:efc_app/models/models.dart';
import 'package:efc_app/services/push/push_service.dart';
import 'package:efc_app/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockEfcRepository', () {
    const repo = MockEfcRepository(latency: Duration.zero);

    test('returns seeded events', () async {
      final events = await repo.events();
      expect(events, isNotEmpty);
      expect(events.any((e) => e.name == 'EFC 137'), isTrue);
    });

    test('returns seeded fighters and articles', () async {
      expect(await repo.fighters(), isNotEmpty);
      expect(await repo.articles(), isNotEmpty);
    });
  });

  group('AppState', () {
    late AppState state;

    setUp(() {
      state = AppState(
        repository: const MockEfcRepository(latency: Duration.zero),
        push: NoopPushService(),
      );
    });

    test('load() populates content and reaches ready', () async {
      await state.load();
      expect(state.status, LoadStatus.ready);
      expect(state.events, isNotEmpty);
      expect(state.fighters, isNotEmpty);
    });

    test('featuredEvent prefers the next upcoming card', () async {
      await state.load();
      final featured = state.featuredEvent;
      expect(featured, isNotNull);
      if (state.upcomingEvents.isNotEmpty) {
        expect(featured!.id, state.upcomingEvents.first.id);
      }
    });

    test('champions are filtered correctly', () async {
      await state.load();
      expect(state.champions.every((f) => f.isChampion), isTrue);
    });

    test('videosOfKind filters by kind and tier', () async {
      await state.load();
      final fullFights = state.videosOfKind(VideoKind.fullFight);
      expect(fullFights.every((v) => v.kind == VideoKind.fullFight), isTrue);

      final free = state.videosOfKind(null, freeOnly: true);
      expect(free.every((v) => !v.isPremium), isTrue);
    });
  });

  group('Models', () {
    test('duration label formats under and over an hour', () {
      const short = VideoItem(
        id: 'a',
        title: 't',
        kind: VideoKind.highlights,
        durationSeconds: 155,
        isPremium: false,
      );
      expect(short.durationLabel, '02:35');

      const long = VideoItem(
        id: 'b',
        title: 't',
        kind: VideoKind.fullFight,
        durationSeconds: 3725,
        isPremium: true,
      );
      expect(long.durationLabel, '1:02:05');
    });

    test('push topic names are sanitised', () {
      expect(PushTopics.fighter('f-sanchez'), 'efc_fighter_f-sanchez');
      expect(PushTopics.fighter('bad id!'), 'efc_fighter_bad_id_');
    });

    test('FightEvent.fromJson parses a CMS payload', () {
      final e = FightEvent.fromJson({
        'id': 'efc-139',
        'name': 'EFC 139',
        'headline': 'A vs B',
        'starts_at': '2026-11-12T19:00:00+02:00',
        'venue': 'WSB EFC Arena',
        'city': 'Sandton',
        'status': 'tickets_on_sale',
        'bouts': [
          {
            'id': 'b1',
            'red_corner_name': 'A',
            'blue_corner_name': 'B',
            'division': 'Lightweight',
            'is_main_event': true,
            'order': 1,
          },
        ],
      });
      expect(e.name, 'EFC 139');
      expect(e.status, EventStatus.ticketsOnSale);
      expect(e.bouts.single.matchup, 'A vs B');
    });
  });
}
