/// Every official EFC destination, in one place.
/// Sourced from efcworldwide.com — verify before each release.
class EfcLinks {
  EfcLinks._();

  // ------------------------------------------------------------------ core
  static const website = 'https://www.efcworldwide.com';
  static const schedule = 'https://www.efcworldwide.com/schedule';
  static const champions = 'https://www.efcworldwide.com/efc-champions';
  static const athletesByDivision =
      'https://www.efcworldwide.com/athletes-by-division';
  static const newsArchive = 'https://www.efcworldwide.com/news-archives';
  static const videoArchive = 'https://www.efcworldwide.com/video-archives';
  static const watch = 'https://www.efcworldwide.com/watch';
  static const contact = 'https://www.efcworldwide.com/contact-us';
  static const becomeAnAthlete =
      'https://www.efcworldwide.com/become-an-efc-athlete';
  static const experience = 'https://www.efcworldwide.com/efc-experience';
  static const arena = 'http://www.efcarena.co.za';

  // ---------------------------------------------------------------- social
  static const facebook = 'https://www.facebook.com/EFCworldwide/';
  static const x = 'https://x.com/EFCworldwide';
  static const instagram = 'https://www.instagram.com/efcworldwide/';
  static const youtube = 'https://www.youtube.com/@EFCworldwideMMA';
  static const tiktok = 'https://www.tiktok.com/@efcworldwide';

  /// Channel ID behind the YouTube RSS feed.
  static const youtubeChannelId = 'UCu0pxhi-kgipKBtGeoR55hA';
  static const youtubeRssFeed =
      'https://www.youtube.com/feeds/videos.xml?channel_id=$youtubeChannelId';

  // ------------------------------------------------------------- broadcast
  static const discoverSport = 'https://www.discoversport.com/user/efc';
  static const discoverSportLive =
      'https://www.efcworldwide.com/discover-sport-live';
  static const superSportGuide = 'https://supersport.com/tv-guide';

  // -------------------------------------------------------------- partners
  static const worldSportsBetting = 'https://www.worldsportsbetting.co.za';
  static const theCapital = 'https://thecapital.co.za';
  static const knoxHydrate = 'https://www.knoxhydrate.com';

  // --------------------------------------------------------------- tickets
  static const efc137Tickets =
      'https://www.quicket.co.za/events/391668-efc-137/';

  /// Ordered for the Follow section of the app.
  static const socialChannels = <EfcChannel>[
    EfcChannel('Instagram', instagram, 'efcworldwide'),
    EfcChannel('YouTube', youtube, 'EFCworldwideMMA'),
    EfcChannel('Facebook', facebook, 'EFCworldwide'),
    EfcChannel('X', x, 'EFCworldwide'),
    EfcChannel('TikTok', tiktok, 'efcworldwide'),
  ];

  static const partners = <EfcChannel>[
    EfcChannel('World Sports Betting', worldSportsBetting, 'Official partner'),
    EfcChannel('The Capital Hotels', theCapital, 'Official partner'),
    EfcChannel('Knox Hydrate', knoxHydrate, 'Official partner'),
  ];

  static const broadcasters = <EfcChannel>[
    EfcChannel('DiscoverSport', discoverSport, 'Watch live and on demand'),
    EfcChannel('SuperSport', superSportGuide, 'TV guide'),
  ];
}

class EfcChannel {
  const EfcChannel(this.name, this.url, this.handle);
  final String name;
  final String url;
  final String handle;
}
