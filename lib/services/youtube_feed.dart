import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../data/efc_links.dart';
import '../models/models.dart';

/// Pulls the 15 most recent uploads from the official EFC YouTube channel.
///
/// YouTube publishes an Atom feed per channel with no API key and no quota,
/// which makes it the cheapest way to keep the fight library current until
/// EFC's own video pipeline exists. Titles, publish dates and thumbnails are
/// real; duration is not carried in the feed, so those stay null.
class YoutubeFeed {
  YoutubeFeed({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 12);

  /// Returns an empty list rather than throwing — the fight library must
  /// still render from seed content if the feed is unreachable.
  Future<List<VideoItem>> fetchLatest() async {
    try {
      final res = await _client
          .get(Uri.parse(EfcLinks.youtubeRssFeed))
          .timeout(_timeout);

      if (res.statusCode != 200) return const [];
      return _parse(res.body);
    } catch (_) {
      return const [];
    }
  }

  List<VideoItem> _parse(String xmlBody) {
    final doc = XmlDocument.parse(xmlBody);
    final entries = doc.findAllElements('entry');
    final out = <VideoItem>[];

    for (final entry in entries) {
      final videoId = _text(entry, 'yt:videoId') ?? _text(entry, 'videoId');
      final title = _text(entry, 'title');
      if (videoId == null || title == null) continue;

      final published = _text(entry, 'published');
      final thumb = entry
          .findAllElements('media:thumbnail')
          .firstOrNull
          ?.getAttribute('url');

      out.add(
        VideoItem(
          id: 'yt-$videoId',
          title: title,
          kind: _classify(title),
          durationSeconds: 0, // not present in the Atom feed
          isPremium: false, // everything on the public channel is free
          thumbnailUrl:
              thumb ?? 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
          streamUrl: 'https://www.youtube.com/watch?v=$videoId',
          publishedAt: published == null ? null : DateTime.tryParse(published),
          eventName: _eventFrom(title),
        ),
      );
    }
    return out;
  }

  /// Best-effort bucketing from the title, so the category filters still work
  /// on feed content. EFC titles are consistent enough for this to hold.
  static VideoKind _classify(String title) {
    final t = title.toLowerCase();
    if (t.contains('full fight')) return VideoKind.fullFight;
    if (t.contains('highlight') || t.contains('finishes')) {
      return VideoKind.highlights;
    }
    if (t.contains('weigh') ||
        t.contains('media day') ||
        t.contains('behind') ||
        t.contains('face-off') ||
        t.contains('faceoff')) {
      return VideoKind.behindTheScenes;
    }
    return VideoKind.feature;
  }

  /// Pulls "EFC 137" out of a title so feed videos attach to the right event.
  static String? _eventFrom(String title) {
    final match = RegExp(r'EFC\s?(\d{1,3})', caseSensitive: false)
        .firstMatch(title);
    return match == null ? null : 'EFC ${match.group(1)}';
  }

  static String? _text(XmlElement parent, String tag) {
    final el = parent.findElements(tag).firstOrNull ??
        parent.findAllElements(tag).firstOrNull;
    final value = el?.innerText.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  void dispose() => _client.close();
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
