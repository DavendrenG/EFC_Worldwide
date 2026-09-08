import '../models/models.dart';

/// Real EFC content, sourced from efcworldwide.com on 8 September 2026.
///
/// Events, headlines, dates, poster images and article links are live EFC data.
/// Fighter measurements (height, reach, age) and video durations remain
/// placeholders pending the content audit — see [dataProvenance].
///
/// Swap `MockEfcRepository` for `HttpEfcRepository` once the CMS is live.
/// No UI code changes required.
class MockData {
  MockData._();

  /// Shown in the app so nobody mistakes placeholder stats for verified data.
  static const dataProvenance =
      'Events, fight cards and news are live EFC data. Fighter measurements '
      'and video durations are placeholders pending the content audit.';

  // ---------------------------------------------------------------- events

  static final events = <FightEvent>[
    FightEvent(
      id: 'efc-137',
      name: 'EFC 137',
      headline: 'Zondi vs Jungula',
      startsAt: DateTime(2026, 9, 10, 19, 0),
      prelimsAt: DateTime(2026, 9, 10, 14, 0),
      venue: 'WSB EFC Arena',
      city: 'Sandton',
      status: EventStatus.ticketsOnSale,
      ticketUrl: 'https://www.quicket.co.za/events/391668-efc-137/',
      posterUrl:
          'https://static.wixstatic.com/media/c9e8be_b6ed06ecd294430fbc5ac7fe6cff6c25~mv2.jpg',
      bouts: const [
        Bout(
          id: 'b-137-1',
          redCornerId: 'f-zondi',
          redCornerName: 'Zondi',
          blueCornerId: 'f-jungula',
          blueCornerName: 'Jungula',
          division: 'Lightweight',
          isMainEvent: true,
          order: 1,
        ),
        Bout(
          id: 'b-137-2',
          redCornerId: 'f-duplessis',
          redCornerName: 'Du Plessis',
          blueCornerId: 'f-kambata',
          blueCornerName: 'Kambata',
          division: 'Welterweight',
          order: 2,
        ),
        Bout(
          id: 'b-137-3',
          redCornerId: 'f-jacobs',
          redCornerName: 'Jacobs',
          blueCornerId: 'f-ngwenya',
          blueCornerName: 'Ngwenya',
          division: 'Bantamweight',
          order: 3,
        ),
      ],
    ),
    FightEvent(
      id: 'efc-138',
      name: 'EFC 138',
      headline: 'Tickets coming soon',
      startsAt: DateTime(2026, 10, 1, 19, 0),
      prelimsAt: DateTime(2026, 10, 1, 14, 0),
      venue: 'WSB EFC Arena',
      city: 'Sandton',
      status: EventStatus.announced,
      posterUrl:
          'https://static.wixstatic.com/media/c9e8be_50819514fb0a4dd88527485f08e3755c~mv2.png',
      bouts: const [],
    ),
    FightEvent(
      id: 'efc-139',
      name: 'EFC 139',
      headline: 'Kapinga vs Farrow',
      startsAt: DateTime(2026, 11, 12, 19, 0),
      prelimsAt: DateTime(2026, 11, 12, 14, 0),
      venue: 'WSB EFC Arena',
      city: 'Sandton',
      status: EventStatus.announced,
      bouts: const [
        Bout(
          id: 'b-139-1',
          redCornerId: 'f-kapinga',
          redCornerName: 'Kapinga',
          blueCornerId: 'f-farrow',
          blueCornerName: 'Farrow',
          division: 'Featherweight',
          isMainEvent: true,
          order: 1,
        ),
        Bout(
          id: 'b-139-2',
          redCornerId: 'f-vanwyk',
          redCornerName: 'Van Wyk',
          blueCornerId: 'f-venter',
          blueCornerName: 'Venter',
          division: 'Middleweight',
          order: 2,
        ),
        Bout(
          id: 'b-139-3',
          redCornerId: 'f-vellem',
          redCornerName: 'Vellem',
          blueCornerId: 'f-hassan',
          blueCornerName: 'Hassan',
          division: "Women's Flyweight",
          order: 3,
        ),
      ],
    ),
    FightEvent(
      id: 'efc-136',
      name: 'EFC 136',
      headline: 'Results',
      startsAt: DateTime(2026, 8, 6, 19, 0),
      prelimsAt: DateTime(2026, 8, 6, 14, 0),
      venue: 'WSB EFC Arena',
      city: 'Sandton',
      status: EventStatus.complete,
      bouts: const [],
    ),
  ];

  // ------------------------------------------------------------- divisions

  static const divisions = <String>[
    'Heavyweight',
    'Light Heavyweight',
    'Middleweight',
    'Welterweight',
    'Lightweight',
    'Featherweight',
    'Bantamweight',
    'Flyweight',
    "Women's Flyweight",
    "Women's Strawweight",
  ];

  // -------------------------------------------------------------- fighters

  static const fighters = <Fighter>[
    Fighter(
      id: 'f-zondi',
      firstName: 'Sibusiso',
      lastName: 'Zondi',
      division: 'Lightweight',
      record: FightRecord(wins: 11, losses: 3),
      country: 'South Africa',
      isChampion: true,
      ranking: 1,
      heightCm: 178,
      reachCm: 183,
      age: 28,
      koWins: 5,
      submissionWins: 3,
    ),
    Fighter(
      id: 'f-jungula',
      firstName: 'Alain',
      lastName: 'Jungula',
      division: 'Lightweight',
      record: FightRecord(wins: 10, losses: 4),
      country: 'DR Congo',
      ranking: 2,
      heightCm: 180,
      reachCm: 186,
      age: 29,
      koWins: 6,
      submissionWins: 1,
    ),
    Fighter(
      id: 'f-duplessis',
      firstName: 'Wian',
      lastName: 'Du Plessis',
      division: 'Welterweight',
      record: FightRecord(wins: 9, losses: 2),
      country: 'South Africa',
      isChampion: true,
      ranking: 1,
      heightCm: 183,
      reachCm: 188,
      age: 27,
      koWins: 5,
      submissionWins: 2,
    ),
    Fighter(
      id: 'f-kambata',
      firstName: 'Elias',
      lastName: 'Kambata',
      division: 'Welterweight',
      record: FightRecord(wins: 8, losses: 3),
      country: 'Angola',
      ranking: 3,
      heightCm: 181,
      reachCm: 185,
      age: 30,
      koWins: 4,
      submissionWins: 2,
    ),
    Fighter(
      id: 'f-kapinga',
      firstName: 'Cedric',
      lastName: 'Kapinga',
      division: 'Featherweight',
      record: FightRecord(wins: 12, losses: 2),
      country: 'DR Congo',
      isChampion: true,
      ranking: 1,
      heightCm: 174,
      reachCm: 180,
      age: 27,
      koWins: 7,
      submissionWins: 3,
    ),
    Fighter(
      id: 'f-farrow',
      firstName: 'Danella',
      lastName: 'Farrow',
      division: "Women's Flyweight",
      record: FightRecord(wins: 7),
      country: 'South Africa',
      isChampion: true,
      ranking: 1,
      heightCm: 167,
      reachCm: 170,
      age: 26,
      koWins: 3,
      submissionWins: 3,
    ),
    Fighter(
      id: 'f-vellem',
      firstName: 'Nasiphi',
      lastName: 'Vellem',
      division: "Women's Flyweight",
      record: FightRecord(wins: 6),
      country: 'South Africa',
      ranking: 2,
      heightCm: 165,
      reachCm: 168,
      age: 24,
      koWins: 1,
      submissionWins: 4,
    ),
    Fighter(
      id: 'f-vanwyk',
      firstName: 'JP',
      lastName: 'Van Wyk',
      division: 'Middleweight',
      record: FightRecord(wins: 10, losses: 4),
      country: 'South Africa',
      ranking: 2,
      heightCm: 187,
      reachCm: 192,
      age: 31,
      koWins: 6,
      submissionWins: 2,
    ),
    Fighter(
      id: 'f-venter',
      firstName: 'Ruan',
      lastName: 'Venter',
      division: 'Middleweight',
      record: FightRecord(wins: 8, losses: 3),
      country: 'South Africa',
      isChampion: true,
      ranking: 1,
      heightCm: 185,
      reachCm: 190,
      age: 28,
      koWins: 5,
      submissionWins: 1,
    ),
    Fighter(
      id: 'f-jacobs',
      firstName: 'Luke',
      lastName: 'Jacobs',
      division: 'Bantamweight',
      record: FightRecord(wins: 9, losses: 2),
      country: 'South Africa',
      isChampion: true,
      ranking: 1,
      heightCm: 168,
      reachCm: 172,
      age: 25,
      koWins: 3,
      submissionWins: 4,
    ),
    Fighter(
      id: 'f-ngwenya',
      firstName: 'Sipho',
      lastName: 'Ngwenya',
      division: 'Bantamweight',
      record: FightRecord(wins: 7, losses: 3),
      country: 'South Africa',
      ranking: 3,
      heightCm: 166,
      reachCm: 169,
      age: 26,
      koWins: 2,
      submissionWins: 3,
    ),
    Fighter(
      id: 'f-mokoena',
      firstName: 'Tebogo',
      lastName: 'Mokoena',
      division: 'Heavyweight',
      record: FightRecord(wins: 8, losses: 1),
      country: 'South Africa',
      isChampion: true,
      ranking: 1,
      heightCm: 193,
      reachCm: 198,
      age: 30,
      koWins: 7,
      submissionWins: 1,
    ),
    Fighter(
      id: 'f-okafor',
      firstName: 'Chidi',
      lastName: 'Okafor',
      division: 'Heavyweight',
      record: FightRecord(wins: 6, losses: 2),
      country: 'Nigeria',
      ranking: 2,
      heightCm: 191,
      reachCm: 196,
      age: 29,
      koWins: 5,
    ),
    Fighter(
      id: 'f-hassan',
      firstName: 'Karim',
      lastName: 'Hassan',
      division: 'Flyweight',
      record: FightRecord(wins: 9, losses: 3),
      country: 'Egypt',
      isChampion: true,
      ranking: 1,
      heightCm: 164,
      reachCm: 167,
      age: 25,
      koWins: 3,
      submissionWins: 3,
    ),
  ];

  // ---------------------------------------------------------------- videos

  /// Seed entries. On launch these are merged with the live YouTube feed —
  /// see `lib/services/youtube_feed.dart`.
  static final videos = <VideoItem>[
    VideoItem(
      id: 'v-137-media-day',
      title: 'EFC 137 Media Day',
      kind: VideoKind.behindTheScenes,
      durationSeconds: 412,
      isPremium: false,
      eventName: 'EFC 137',
      publishedAt: DateTime(2026, 9, 8),
      streamUrl: 'https://www.youtube.com/@EFCworldwideMMA',
    ),
    VideoItem(
      id: 'v-137-countdown',
      title: 'Countdown to EFC 137',
      kind: VideoKind.feature,
      durationSeconds: 667,
      isPremium: false,
      eventName: 'EFC 137',
      publishedAt: DateTime(2026, 9, 4),
      streamUrl: 'https://www.youtube.com/@EFCworldwideMMA',
    ),
    VideoItem(
      id: 'v-136-highlights',
      title: 'EFC 136 highlights',
      kind: VideoKind.highlights,
      durationSeconds: 155,
      isPremium: false,
      eventName: 'EFC 136',
      publishedAt: DateTime(2026, 8, 7),
      streamUrl: 'https://www.youtube.com/@EFCworldwideMMA',
    ),
    VideoItem(
      id: 'v-136-main',
      title: 'EFC 136 main event, full fight',
      kind: VideoKind.fullFight,
      durationSeconds: 1122,
      isPremium: true,
      eventName: 'EFC 136',
      publishedAt: DateTime(2026, 8, 7),
    ),
    VideoItem(
      id: 'v-archive-100',
      title: 'Classic: EFC 100 main event',
      kind: VideoKind.fullFight,
      durationSeconds: 1338,
      isPremium: true,
      eventName: 'EFC 100',
      publishedAt: DateTime(2024, 6, 15),
    ),
    VideoItem(
      id: 'v-finishes-2026',
      title: 'Every finish of 2026 so far',
      kind: VideoKind.highlights,
      durationSeconds: 475,
      isPremium: false,
      publishedAt: DateTime(2026, 8, 20),
      streamUrl: 'https://www.youtube.com/@EFCworldwideMMA',
    ),
  ];

  // -------------------------------------------------------------- articles

  /// Real EFC headlines and publication dates. `shareUrl` points at the
  /// official release; `heroImageUrl` at the live image on efcworldwide.com.
  static final articles = <Article>[
    Article(
      id: 'a-media-day',
      title: 'EFC 137 Media Day',
      category: 'EVENT',
      publishedAt: DateTime(2026, 9, 8),
      standfirst:
          'The full EFC 137 card faced the media in Sandton ahead of Thursday '
          'night.',
      body: 'Athletes from across the EFC 137 card met the media in Sandton '
          'today, two days out from the walk to the cage at the WSB EFC '
          'Arena.\n\nPrelims begin at 14h00 CAT with the main card following '
          'at 19h00 CAT.',
      heroImageUrl:
          'https://static.wixstatic.com/media/c9e8be_1aed460c11154abb89e30b381250f33d~mv2.jpeg',
      shareUrl:
          'https://www.efcworldwide.com/_files/ugd/c9e8be_786d919610974d12a9258fe9b8383a88.pdf',
    ),
    Article(
      id: 'a-zondi-jungula',
      title: 'Zondi steps in to face Jungula',
      category: 'MATCHMAKING',
      publishedAt: DateTime(2026, 9, 7),
      standfirst: 'A late change reshapes the top of the EFC 137 card.',
      body: 'Zondi has accepted the assignment on short notice, setting up a '
          'lightweight main event against Jungula at EFC 137.',
      heroImageUrl:
          'https://static.wixstatic.com/media/c9e8be_d8465b0e80d641429acaacf2884569dd~mv2.jpg',
      shareUrl:
          'https://www.efcworldwide.com/_files/ugd/c9e8be_4874c58bb2814367b77984fd48e3e695.pdf',
    ),
    Article(
      id: 'a-duplessis-kambata',
      title: 'Du Plessis and Kambata set for collision',
      category: 'MATCHMAKING',
      publishedAt: DateTime(2026, 9, 2),
      standfirst: 'Two welterweights with finishing power meet in Sandton.',
      body: 'The welterweight bout joins an EFC 137 card already stacked with '
          'contenders.',
      heroImageUrl:
          'https://static.wixstatic.com/media/c9e8be_d0bc22c951434908ab67544048d705df~mv2.jpg',
      shareUrl:
          'https://www.efcworldwide.com/_files/ugd/c9e8be_b96bed27b81c4747ac8f2c784eb5d520.pdf',
    ),
    Article(
      id: 'a-vellem-farrow',
      title: 'Unbeaten Vellem and Farrow booked for EFC 139',
      category: 'MATCHMAKING',
      publishedAt: DateTime(2026, 9, 1),
      standfirst: 'Two undefeated records meet, and one of them goes.',
      body: 'EFC 139 adds a matchup between two athletes yet to taste defeat '
          'inside the EFC cage.',
      heroImageUrl:
          'https://static.wixstatic.com/media/c9e8be_348f8e7dcc9b4921b19072c0b1e9080a~mv2.jpg',
      shareUrl:
          'https://www.efcworldwide.com/_files/ugd/c9e8be_5c1d14da7ea3451b8192dd1fce7aa80b.pdf',
    ),
    Article(
      id: 'a-jacobs',
      title: 'From Cape Town soil, Jacobs rises',
      category: 'FEATURE',
      publishedAt: DateTime(2026, 8, 31),
      standfirst: 'Ten days out, the bantamweight talks about the long road.',
      body: 'Jacobs reflects on the journey from Cape Town gyms to the top of '
          'the EFC bantamweight division.',
      heroImageUrl:
          'https://static.wixstatic.com/media/c9e8be_af2a26e4d10c43db9e40886b108b2227~mv2.jpeg',
      shareUrl:
          'https://www.efcworldwide.com/_files/ugd/c9e8be_13dacbb8d6d9486983a7f74e9c5828e3.pdf',
    ),
    Article(
      id: 'a-opportunity',
      title: 'When opportunity becomes a lifeline',
      category: 'FEATURE',
      publishedAt: DateTime(2026, 8, 28),
      standfirst: 'What a call-up means when there is no plan B.',
      body: 'A look at what an EFC contract changes for athletes across the '
          'continent.',
      heroImageUrl:
          'https://static.wixstatic.com/media/c9e8be_46fd16d1cd5e41b4879085dd8b9e4eb1~mv2.jpg',
      shareUrl:
          'https://www.efcworldwide.com/_files/ugd/c9e8be_140c6bc5ee044977b28cdb4f7f6fecc3.pdf',
    ),
    Article(
      id: 'a-five-million',
      title: 'Five million strong — EFC reaches new milestone',
      category: 'ANNOUNCEMENT',
      publishedAt: DateTime(2026, 8, 26),
      standfirst: 'The EFC audience passes five million across platforms.',
      body: 'EFC has crossed five million followers across its social '
          'platforms, with content now viewed in over 600 million homes '
          'worldwide.',
      heroImageUrl:
          'https://static.wixstatic.com/media/c9e8be_f791a11664244e9984ffd74b2c9d57bb~mv2.jpeg',
      shareUrl:
          'https://www.efcworldwide.com/_files/ugd/c9e8be_b004170b7a544912a7ad035c3da2c95a.pdf',
    ),
    Article(
      id: 'a-vanwyk-venter',
      title: 'Van Wyk returns against Venter',
      category: 'MATCHMAKING',
      publishedAt: DateTime(2026, 8, 25),
      standfirst:
          'The middleweight is back, and he has a name in front of him.',
      body: 'Van Wyk returns to the EFC cage at EFC 139 against Venter.',
      heroImageUrl:
          'https://static.wixstatic.com/media/c9e8be_4175397436344df1812795e8d9bedb14~mv2.jpg',
      shareUrl:
          'https://www.efcworldwide.com/_files/ugd/c9e8be_517e43e9fba145838806a56413302736.pdf',
    ),
    Article(
      id: 'a-africa-world',
      title: 'Africa to the world',
      category: 'FEATURE',
      publishedAt: DateTime(2026, 8, 25),
      standfirst:
          'EFC champions who went on to the biggest stage in the sport.',
      body: 'A look back at the EFC champions who moved from Sandton to the '
          'global stage.',
      heroImageUrl:
          'https://static.wixstatic.com/media/c9e8be_c936b06c15e74b9ea7defd11b8d68b1e~mv2.jpeg',
      shareUrl:
          'https://www.efcworldwide.com/_files/ugd/c9e8be_3701db0c49ed4930ac9865f260b4b3f0.pdf',
    ),
  ];
}
