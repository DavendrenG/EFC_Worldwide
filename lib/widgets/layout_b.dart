import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'common.dart';

/// ---------------------------------------------------------------------------
/// Layout B — image-led.
///
/// The rule behind every widget here: a photograph carries the screen and text
/// sits on top of it, rather than text sitting beside an empty box. Each tile
/// shows at most one piece of metadata; anything else was noise.
/// ---------------------------------------------------------------------------

/// Full-bleed event hero. Poster fills the frame, detail sits over a scrim.
class EventHero extends StatelessWidget {
  const EventHero({
    super.key,
    required this.event,
    this.onTickets,
    this.onOpen,
  });

  final FightEvent event;
  final VoidCallback? onTickets;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final starts = event.startsAt.toLocal();
    return GestureDetector(
      onTap: onOpen,
      child: SizedBox(
        height: 330,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ArtworkBox(imageUrl: event.posterUrl),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: EfcColors.heroScrim),
            ),
            Positioned(
              left: EfcSpacing.screenH,
              right: EfcSpacing.screenH,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: EfcColors.blood,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    child: Text(
                      'NEXT EVENT',
                      style: EfcText.utility(
                          size: 9.5, color: Colors.white, letterSpacing: 1.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(event.name.toUpperCase(),
                      style: EfcText.display(size: 34, height: 0.95)),
                  if (event.headline.isNotEmpty)
                    Text(
                      event.headline.toUpperCase(),
                      style: EfcText.display(
                          size: 17, height: 1.05, color: EfcColors.boneDim),
                    ),
                  const SizedBox(height: 7),
                  Text(
                    '${_dayMonth(starts)} · ${event.venue}, ${event.city}',
                    style: EfcText.body(size: 14.5, color: EfcColors.boneDim),
                  ),
                  const SizedBox(height: 11),
                  CountdownStrip(target: event.startsAt),
                  if (event.ticketUrl != null) ...[
                    const SizedBox(height: 12),
                    EfcButton(label: 'Get tickets', onPressed: onTickets),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  static const _days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

  static String _dayMonth(DateTime d) =>
      '${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';
}

/// Countdown as a flat strip over the hero — no boxes, no borders.
class CountdownStrip extends StatefulWidget {
  const CountdownStrip({super.key, required this.target});
  final DateTime target;

  @override
  State<CountdownStrip> createState() => _CountdownStripState();
}

class _CountdownStripState extends State<CountdownStrip> {
  late Duration _left;

  @override
  void initState() {
    super.initState();
    _left = widget.target.difference(DateTime.now());
    _tick();
  }

  void _tick() {
    if (!mounted) return;
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _left = widget.target.difference(DateTime.now()));
      _tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_left.isNegative) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 9),
        color: EfcColors.blood,
        child: Text('LIVE NOW',
            textAlign: TextAlign.center,
            style: EfcText.display(size: 15, color: Colors.white)),
      );
    }

    String p(int n) => n.toString().padLeft(2, '0');
    final cells = <List<String>>[
      ['${_left.inDays}', 'DAYS'],
      [p(_left.inHours % 24), 'HRS'],
      [p(_left.inMinutes % 60), 'MIN'],
      [p(_left.inSeconds % 60), 'SEC'],
    ];

    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x1FFFFFFF))),
      ),
      child: Row(
        children: [
          for (final c in cells)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c[0], style: EfcText.display(size: 20, height: 1)),
                  Text(c[1],
                      style: EfcText.utility(size: 8, letterSpacing: 1.2)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Large image-led card. Title sits over the photograph, one date beneath it.
class LeadCard extends StatelessWidget {
  const LeadCard({
    super.key,
    required this.title,
    required this.meta,
    this.imageUrl,
    this.height = 178,
    this.onTap,
    this.showPlay = false,
  });

  final String title;
  final String meta;
  final String? imageUrl;
  final double height;
  final VoidCallback? onTap;
  final bool showPlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            EfcSpacing.screenH, 0, EfcSpacing.screenH, 12),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ArtworkBox(imageUrl: imageUrl),
              const DecoratedBox(
                decoration: BoxDecoration(gradient: EfcColors.cardScrim),
              ),
              if (showPlay)
                Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xEBD8342A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow,
                        color: Colors.white, size: 24),
                  ),
                ),
              Positioned(
                left: 13,
                right: 13,
                bottom: 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title.toUpperCase(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: EfcText.display(size: 17, height: 1.1),
                    ),
                    const SizedBox(height: 5),
                    Text(meta.toUpperCase(),
                        style: EfcText.utility(
                            size: 9.5,
                            color: EfcColors.boneDim,
                            letterSpacing: 1.0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact list row with a thumbnail. Used beneath a [LeadCard].
class ThumbRow extends StatelessWidget {
  const ThumbRow({
    super.key,
    required this.title,
    required this.meta,
    this.imageUrl,
    this.onTap,
  });

  final String title;
  final String meta;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: EfcSpacing.screenH, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 96,
              height: 62,
              child: ArtworkBox(imageUrl: imageUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: EfcText.body(
                        size: 16.5, height: 1.25, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(meta.toUpperCase(),
                      style: EfcText.utility(size: 9, letterSpacing: 1.0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Portrait 3:4 tile for the fight library rails — a fight poster is portrait,
/// so the tile is too. Duration bottom-right, lock bottom-left, nothing else.
class PosterTile extends StatelessWidget {
  const PosterTile({
    super.key,
    required this.video,
    this.locked = false,
    this.onTap,
  });

  final VideoItem video;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 132,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 176,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ArtworkBox(imageUrl: video.thumbnailUrl),
                  if (video.durationSeconds > 0)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        color: const Color(0xD9000000),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        child: Text(video.durationLabel,
                            style: EfcText.utility(
                                size: 9,
                                color: EfcColors.bone,
                                letterSpacing: 0.4)),
                      ),
                    ),
                  if (locked)
                    const Positioned(
                      left: 6,
                      bottom: 6,
                      child: Icon(Icons.lock,
                          size: 13, color: EfcColors.brass),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Text(
              video.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: EfcText.body(
                  size: 14.5, height: 1.25, weight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Athlete row modelled on a rankings list — a face and a record read faster
/// than a card, and it scales to a 150-strong roster without endless scrolling.
class AthleteRow extends StatelessWidget {
  const AthleteRow({super.key, required this.fighter, this.onTap});

  final Fighter fighter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showRank = !fighter.isChampion && fighter.ranking != null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: EfcSpacing.screenH, vertical: 9),
        child: Row(
          children: [
            if (showRank) ...[
              Container(
                color: EfcColors.steel,
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                child: Text('${fighter.ranking}',
                    style: EfcText.display(size: 15)),
              ),
              const SizedBox(width: 10),
            ],
            SizedBox(
              width: 66,
              height: 66,
              child: ArtworkBox(imageUrl: fighter.portraitUrl),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fighter.fullName.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: EfcText.display(size: 17, height: 1.1),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${fighter.record} · ${fighter.division}',
                    style: EfcText.utility(size: 11, letterSpacing: 0.3),
                  ),
                ],
              ),
            ),
            if (fighter.isChampion)
              Container(
                color: EfcColors.brass,
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Text('CHAMP',
                    style: EfcText.utility(
                        size: 8.5,
                        color: Colors.black,
                        letterSpacing: 0.9)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Schedule row. Deliberately text-only — a schedule is data, and images here
/// would slow the scan rather than help it.
class ScheduleRow extends StatelessWidget {
  const ScheduleRow({
    super.key,
    required this.event,
    this.trailing,
    this.onTap,
  });

  final FightEvent event;
  final Widget? trailing;
  final VoidCallback? onTap;

  static const _months = [
    'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'
  ];

  @override
  Widget build(BuildContext context) {
    final d = event.startsAt.toLocal();
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: EfcSpacing.screenH, vertical: 15),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: EfcColors.line)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              child: Column(
                children: [
                  Text(d.day.toString().padLeft(2, '0'),
                      style: EfcText.display(size: 22, height: 1)),
                  Text(_months[d.month - 1],
                      style: EfcText.utility(size: 8.5, letterSpacing: 1.0)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(event.name.toUpperCase(),
                      style: EfcText.display(size: 18, height: 1.05)),
                  const SizedBox(height: 2),
                  Text(
                    event.headline.isEmpty
                        ? 'Card to be announced'
                        : event.headline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: EfcText.body(size: 14.5, color: EfcColors.mute),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ),
    );
  }
}
