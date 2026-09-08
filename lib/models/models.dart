import 'package:flutter/foundation.dart';

/// ---------------------------------------------------------------------------
/// Shared helpers
/// ---------------------------------------------------------------------------
DateTime? _date(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString())?.toLocal();
}

String _str(dynamic v, [String fallback = '']) => v?.toString() ?? fallback;

int _int(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  return int.tryParse(v?.toString() ?? '') ?? fallback;
}

/// ---------------------------------------------------------------------------
/// Event
/// ---------------------------------------------------------------------------
enum EventStatus { announced, ticketsOnSale, live, complete }

EventStatus _eventStatus(String raw) {
  switch (raw) {
    case 'tickets_on_sale':
      return EventStatus.ticketsOnSale;
    case 'live':
      return EventStatus.live;
    case 'complete':
      return EventStatus.complete;
    default:
      return EventStatus.announced;
  }
}

@immutable
class Bout {
  const Bout({
    required this.id,
    required this.redCornerId,
    required this.redCornerName,
    required this.blueCornerId,
    required this.blueCornerName,
    required this.division,
    this.isTitleFight = false,
    this.isMainEvent = false,
    this.order = 0,
    this.result,
  });

  final String id;
  final String redCornerId;
  final String redCornerName;
  final String blueCornerId;
  final String blueCornerName;
  final String division;
  final bool isTitleFight;
  final bool isMainEvent;
  final int order;
  final String? result;

  String get matchup => '$redCornerName vs $blueCornerName';

  factory Bout.fromJson(Map<String, dynamic> j) => Bout(
        id: _str(j['id']),
        redCornerId: _str(j['red_corner_id']),
        redCornerName: _str(j['red_corner_name']),
        blueCornerId: _str(j['blue_corner_id']),
        blueCornerName: _str(j['blue_corner_name']),
        division: _str(j['division']),
        isTitleFight: j['is_title_fight'] == true,
        isMainEvent: j['is_main_event'] == true,
        order: _int(j['order']),
        result: j['result']?.toString(),
      );
}

@immutable
class FightEvent {
  const FightEvent({
    required this.id,
    required this.name,
    required this.headline,
    required this.startsAt,
    required this.prelimsAt,
    required this.venue,
    required this.city,
    required this.status,
    this.posterUrl,
    this.ticketUrl,
    this.bouts = const [],
  });

  final String id;
  final String name;
  final String headline;
  final DateTime startsAt;
  final DateTime? prelimsAt;
  final String venue;
  final String city;
  final EventStatus status;
  final String? posterUrl;
  final String? ticketUrl;
  final List<Bout> bouts;

  bool get isUpcoming => startsAt.isAfter(DateTime.now());
  bool get isLive =>
      status == EventStatus.live ||
      (DateTime.now().isAfter(startsAt) &&
          DateTime.now().difference(startsAt).inHours < 6);

  factory FightEvent.fromJson(Map<String, dynamic> j) => FightEvent(
        id: _str(j['id']),
        name: _str(j['name']),
        headline: _str(j['headline']),
        startsAt: _date(j['starts_at']) ?? DateTime.now(),
        prelimsAt: _date(j['prelims_at']),
        venue: _str(j['venue']),
        city: _str(j['city']),
        status: _eventStatus(_str(j['status'], 'announced')),
        posterUrl: j['poster_url']?.toString(),
        ticketUrl: j['ticket_url']?.toString(),
        bouts: (j['bouts'] as List<dynamic>? ?? [])
            .map((b) => Bout.fromJson(b as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order)),
      );
}

/// ---------------------------------------------------------------------------
/// Fighter
/// ---------------------------------------------------------------------------
@immutable
class FightRecord {
  const FightRecord({this.wins = 0, this.losses = 0, this.draws = 0});

  final int wins;
  final int losses;
  final int draws;

  @override
  String toString() => '$wins-$losses-$draws';

  factory FightRecord.fromJson(Map<String, dynamic>? j) => FightRecord(
        wins: _int(j?['wins']),
        losses: _int(j?['losses']),
        draws: _int(j?['draws']),
      );
}

@immutable
class Fighter {
  const Fighter({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.division,
    required this.record,
    this.nickname,
    this.country,
    this.team,
    this.isChampion = false,
    this.ranking,
    this.heightCm,
    this.reachCm,
    this.age,
    this.koWins = 0,
    this.submissionWins = 0,
    this.portraitUrl,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String division;
  final FightRecord record;
  final String? nickname;
  final String? country;
  final String? team;
  final bool isChampion;
  final int? ranking;
  final int? heightCm;
  final int? reachCm;
  final int? age;
  final int koWins;
  final int submissionWins;
  final String? portraitUrl;

  String get fullName => '$firstName $lastName';
  String get statusLabel =>
      isChampion ? 'Champion' : (ranking != null ? '#$ranking' : 'Contender');

  factory Fighter.fromJson(Map<String, dynamic> j) => Fighter(
        id: _str(j['id']),
        firstName: _str(j['first_name']),
        lastName: _str(j['last_name']),
        division: _str(j['division']),
        record: FightRecord.fromJson(j['record'] as Map<String, dynamic>?),
        nickname: j['nickname']?.toString(),
        country: j['country']?.toString(),
        team: j['team']?.toString(),
        isChampion: j['is_champion'] == true,
        ranking: j['ranking'] == null ? null : _int(j['ranking']),
        heightCm: j['height_cm'] == null ? null : _int(j['height_cm']),
        reachCm: j['reach_cm'] == null ? null : _int(j['reach_cm']),
        age: j['age'] == null ? null : _int(j['age']),
        koWins: _int(j['ko_wins']),
        submissionWins: _int(j['submission_wins']),
        portraitUrl: j['portrait_url']?.toString(),
      );
}

/// ---------------------------------------------------------------------------
/// Video
/// ---------------------------------------------------------------------------
enum VideoKind { fullFight, highlights, feature, behindTheScenes }

VideoKind _videoKind(String raw) {
  switch (raw) {
    case 'full_fight':
      return VideoKind.fullFight;
    case 'feature':
      return VideoKind.feature;
    case 'behind_the_scenes':
      return VideoKind.behindTheScenes;
    default:
      return VideoKind.highlights;
  }
}

extension VideoKindLabel on VideoKind {
  String get label => switch (this) {
        VideoKind.fullFight => 'Full fight',
        VideoKind.highlights => 'Highlights',
        VideoKind.feature => 'Feature',
        VideoKind.behindTheScenes => 'Behind the scenes',
      };
}

@immutable
class VideoItem {
  const VideoItem({
    required this.id,
    required this.title,
    required this.kind,
    required this.durationSeconds,
    required this.isPremium,
    this.eventName,
    this.division,
    this.thumbnailUrl,
    this.streamUrl,
    this.publishedAt,
  });

  final String id;
  final String title;
  final VideoKind kind;
  final int durationSeconds;
  final bool isPremium;
  final String? eventName;
  final String? division;
  final String? thumbnailUrl;
  final String? streamUrl;
  final DateTime? publishedAt;

  String get durationLabel {
    final d = Duration(seconds: durationSeconds);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  String get tierLabel => isPremium ? 'Premium' : 'Free';

  factory VideoItem.fromJson(Map<String, dynamic> j) => VideoItem(
        id: _str(j['id']),
        title: _str(j['title']),
        kind: _videoKind(_str(j['kind'], 'highlights')),
        durationSeconds: _int(j['duration_seconds']),
        isPremium: j['is_premium'] == true,
        eventName: j['event_name']?.toString(),
        division: j['division']?.toString(),
        thumbnailUrl: j['thumbnail_url']?.toString(),
        streamUrl: j['stream_url']?.toString(),
        publishedAt: _date(j['published_at']),
      );
}

/// ---------------------------------------------------------------------------
/// Article
/// ---------------------------------------------------------------------------
@immutable
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.category,
    required this.publishedAt,
    required this.body,
    this.standfirst,
    this.heroImageUrl,
    this.shareUrl,
  });

  final String id;
  final String title;
  final String category;
  final DateTime publishedAt;
  final String body;
  final String? standfirst;
  final String? heroImageUrl;
  final String? shareUrl;

  factory Article.fromJson(Map<String, dynamic> j) => Article(
        id: _str(j['id']),
        title: _str(j['title']),
        category: _str(j['category'], 'News').toUpperCase(),
        publishedAt: _date(j['published_at']) ?? DateTime.now(),
        body: _str(j['body']),
        standfirst: j['standfirst']?.toString(),
        heroImageUrl: j['hero_image_url']?.toString(),
        shareUrl: j['share_url']?.toString(),
      );
}
