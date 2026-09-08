import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/countdown.dart';
import 'package:collection/collection.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  Future<void> _openTickets(String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final event = state.events.where((e) => e.id == eventId).firstOrNull;

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('EVENT')),
        body: const EmptyState(
          title: 'Event not found',
          body: 'It may have been removed from the schedule.',
        ),
      );
    }

    final main = event.bouts.where((b) => b.isMainEvent).firstOrNull;
    final undercard = event.bouts.where((b) => !b.isMainEvent).toList();

    return Scaffold(
      appBar: AppBar(title: Text(event.name.toUpperCase())),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: EfcColors.posterGradient,
              border: Border(bottom: BorderSide(color: EfcColors.line)),
            ),
            padding: const EdgeInsets.all(EfcSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.headline.toUpperCase(),
                  style: EfcText.display(size: 28, height: 0.98),
                ),
                const SizedBox(height: 10),
                Text(
                  DateFormat('EEEE d MMMM yyyy')
                      .format(event.startsAt)
                      .toUpperCase(),
                  style: EfcText.utility(size: 11, letterSpacing: 0.8),
                ),
                Text(
                  '${event.venue.toUpperCase()} \u00b7 '
                  '${event.city.toUpperCase()}',
                  style: EfcText.utility(size: 11, letterSpacing: 0.8),
                ),
                const SizedBox(height: 16),
                if (event.isUpcoming) EventCountdown(target: event.startsAt),
                if (event.isUpcoming) const SizedBox(height: 14),
                if (event.ticketUrl != null)
                  EfcButton(
                    label: 'Get tickets',
                    onPressed: () => _openTickets(event.ticketUrl),
                  ),
              ],
            ),
          ),
          if (main != null) ...[
            const SectionHeader(title: 'Main event'),
            _BoutRow(bout: main),
          ],
          if (undercard.isNotEmpty) ...[
            const SectionHeader(title: 'Card'),
            for (final b in undercard) _BoutRow(bout: b),
          ],
          if (event.bouts.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: EmptyState(
                title: 'Card not announced',
                body: 'Bouts appear here as matchmaking confirms them.',
              ),
            ),
        ],
      ),
    );
  }
}

class _BoutRow extends StatelessWidget {
  const _BoutRow({required this.bout});

  final Bout bout;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: EfcSpacing.screenH,
          vertical: EfcSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: EfcColors.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bout.matchup.toUpperCase(),
                    style: EfcText.display(size: 16, letterSpacing: 0.4),
                  ),
                  const SizedBox(height: 3),
                  UtilityLabel(
                    bout.result == null
                        ? bout.division
                        : '${bout.division} \u00b7 ${bout.result}',
                    size: 10,
                    letterSpacing: 0.8,
                  ),
                ],
              ),
            ),
            if (bout.isTitleFight)
              const Pill('Title') ,
          ],
        ),
      );
}
