import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'common.dart';

/// Featured event block on the home screen: red rule, event number, matchup,
/// venue metadata and countdown.
class EventPoster extends StatelessWidget {
  const EventPoster({
    super.key,
    required this.event,
    required this.countdown,
    this.onTickets,
    this.onRemind,
    this.remindLabel = 'Remind me',
  });

  final FightEvent event;
  final Widget countdown;
  final VoidCallback? onTickets;
  final VoidCallback? onRemind;
  final String remindLabel;

  @override
  Widget build(BuildContext context) {
    final dateLine =
        DateFormat('EEEE d MMMM yyyy').format(event.startsAt).toUpperCase();
    final prelims = event.prelimsAt == null
        ? null
        : 'PRELIMS ${DateFormat('HH:mm').format(event.prelimsAt!)} CAT';
    final main = 'MAIN CARD ${DateFormat('HH:mm').format(event.startsAt)} CAT';

    return Container(
      decoration: const BoxDecoration(
        gradient: EfcColors.posterGradient,
        border: Border(bottom: BorderSide(color: EfcColors.line)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: EfcColors.blood),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UtilityLabel(
                      event.isUpcoming
                          ? 'Next event \u00b7 Main card'
                          : 'Latest event',
                      color: EfcColors.blood,
                      letterSpacing: 2.0,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.name.toUpperCase(),
                      style: EfcText.display(size: 38, height: 0.95),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.headline.toUpperCase(),
                      style: EfcText.display(
                        size: 19,
                        color: const Color(0xFFD8D2C6),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      dateLine,
                      style: EfcText.utility(size: 11, letterSpacing: 0.8),
                    ),
                    Text(
                      '${event.venue.toUpperCase()} \u00b7 '
                      '${event.city.toUpperCase()}',
                      style: EfcText.utility(size: 11, letterSpacing: 0.8),
                    ),
                    Text(
                      prelims == null ? main : '$prelims \u00b7 $main',
                      style: EfcText.utility(size: 11, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 16),
                    countdown,
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: EfcButton(
                            label: 'Get tickets',
                            onPressed: onTickets,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: EfcButton(
                            label: remindLabel,
                            ghost: true,
                            onPressed: onRemind,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact horizontal-rail tile used by "Continue watching".
class RailTile extends StatelessWidget {
  const RailTile({super.key, required this.video, this.onTap});

  final VideoItem video;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 148,
          decoration: BoxDecoration(
            color: EfcColors.steel,
            border: Border.all(color: EfcColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ArtworkBox(height: 74, caption: video.durationLabel),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: EfcText.body(size: 13.5, color: EfcColors.bone),
                ),
              ),
            ],
          ),
        ),
      );
}

/// Grid card used on Athletes and Watch.
class GridCard extends StatelessWidget {
  const GridCard({
    super.key,
    required this.title,
    this.subtitle,
    this.caption,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final String? caption;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: EfcColors.steel,
            border: Border.all(color: EfcColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  ArtworkBox(height: 88, caption: caption),
                  if (trailing != null)
                    Positioned(top: 6, right: 6, child: trailing!),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: EfcText.body(
                        size: 13.5,
                        color: EfcColors.bone,
                        height: 1.25,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      UtilityLabel(subtitle!, size: 9.5, letterSpacing: 0.8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

/// Row on the Events screen: date block, title, metadata, status pill.
class EventRow extends StatelessWidget {
  const EventRow({super.key, required this.event, this.onTap});

  final FightEvent event;
  final VoidCallback? onTap;

  Pill get _pill {
    if (event.isLive) return const Pill('Live', variant: PillVariant.live);
    switch (event.status) {
      case EventStatus.ticketsOnSale:
        return const Pill('Tickets');
      case EventStatus.complete:
        return const Pill('Watch', variant: PillVariant.free);
      case EventStatus.live:
        return const Pill('Live', variant: PillVariant.live);
      case EventStatus.announced:
        return const Pill('Soon', variant: PillVariant.neutral);
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('dd').format(event.startsAt);
    final month = DateFormat('MMM').format(event.startsAt).toUpperCase();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: EfcSpacing.screenH,
          vertical: EfcSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: EfcColors.line)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(border: Border.all(color: EfcColors.line)),
              child: Column(
                children: [
                  Text(day, style: EfcText.display(size: 19)),
                  const SizedBox(height: 2),
                  UtilityLabel(month, size: 8.5, letterSpacing: 1.2),
                ],
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name.toUpperCase(),
                    style: EfcText.display(size: 15, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${event.venue.toUpperCase()} \u00b7 '
                    '${event.headline.toUpperCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: EfcText.utility(size: 10, letterSpacing: 0.6),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _pill,
          ],
        ),
      ),
    );
  }
}

/// News list row.
class ArticleRow extends StatelessWidget {
  const ArticleRow({super.key, required this.article, this.onTap});

  final Article article;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final date =
        DateFormat('dd MMM yyyy').format(article.publishedAt).toUpperCase();
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: EfcSpacing.screenH,
          vertical: 13,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: EfcColors.line)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UtilityLabel(
              '$date \u00b7 ${article.category}',
              size: 9.5,
              letterSpacing: 1.2,
            ),
            const SizedBox(height: 5),
            Text(
              article.title.toUpperCase(),
              style: EfcText.display(size: 15.5, height: 1.15, letterSpacing: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

/// Head-to-head comparison block, red corner vs blue corner.
class TaleOfTape extends StatelessWidget {
  const TaleOfTape({super.key, required this.red, required this.blue});

  final Fighter red;
  final Fighter blue;

  Widget _corner(Fighter f, bool isRed) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                (isRed ? EfcColors.cornerRed : EfcColors.cornerBlue)
                    .withValues(alpha: 0.28),
                Colors.transparent,
              ],
            ),
            border: Border(
              left: isRed
                  ? const BorderSide(color: EfcColors.cornerRed, width: 3)
                  : BorderSide.none,
              right: isRed
                  ? BorderSide.none
                  : const BorderSide(color: EfcColors.cornerBlue, width: 3),
            ),
          ),
          child: Column(
            children: [
              UtilityLabel(isRed ? 'Red corner' : 'Blue corner', size: 9.5),
              const SizedBox(height: 4),
              Text(
                '${f.firstName}\n${f.lastName}'.toUpperCase(),
                textAlign: TextAlign.center,
                style: EfcText.display(size: 17, height: 1.05),
              ),
            ],
          ),
        ),
      );

  Widget _row(String label, String left, String right) => Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: EfcColors.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Text(
                  left,
                  textAlign: TextAlign.center,
                  style: EfcText.utility(size: 12, color: EfcColors.bone,
                      letterSpacing: 0.4),
                ),
              ),
            ),
            SizedBox(
              width: 110,
              child: Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: EfcText.utility(size: 9, letterSpacing: 1.4),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Text(
                  right,
                  textAlign: TextAlign.center,
                  style: EfcText.utility(size: 12, color: EfcColors.bone,
                      letterSpacing: 0.4),
                ),
              ),
            ),
          ],
        ),
      );

  String _cm(int? v) => v == null ? '\u2014' : '$v cm';
  String _n(int? v) => v == null ? '\u2014' : '$v';

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(EfcSpacing.lg),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_corner(red, true), _corner(blue, false)],
            ),
            _row('Record', red.record.toString(), blue.record.toString()),
            _row('Reach', _cm(red.reachCm), _cm(blue.reachCm)),
            _row('Height', _cm(red.heightCm), _cm(blue.heightCm)),
            _row('Age', _n(red.age), _n(blue.age)),
            _row('KO / TKO', '${red.koWins}', '${blue.koWins}'),
            _row('Submissions', '${red.submissionWins}',
                '${blue.submissionWins}'),
          ],
        ),
      );
}
