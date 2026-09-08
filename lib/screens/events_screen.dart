import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import 'event_detail_screen.dart';
import 'screen_scaffold.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final year = DateTime.now().year.toString();

    if (state.status == LoadStatus.loading && state.events.isEmpty) {
      return const Column(
        children: [
          EfcHeader(title: 'Events', meta: ''),
          Expanded(child: LoadingState()),
        ],
      );
    }

    void open(String id) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => EventDetailScreen(eventId: id),
          ),
        );

    return Column(
      children: [
        EfcHeader(title: 'Events', meta: year),
        Expanded(
          child: RefreshIndicator(
            onRefresh: state.refresh,
            color: EfcColors.blood,
            backgroundColor: EfcColors.steel,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (state.upcomingEvents.isEmpty && state.pastEvents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: EmptyState(
                      title: 'No events yet',
                      body: 'The next card will appear here as soon as it is '
                          'announced.',
                    ),
                  ),
                if (state.upcomingEvents.isNotEmpty) ...[
                  const SectionHeader(title: 'Upcoming'),
                  for (final e in state.upcomingEvents)
                    EventRow(event: e, onTap: () => open(e.id)),
                ],
                if (state.pastEvents.isNotEmpty) ...[
                  const SectionHeader(title: 'Results'),
                  for (final e in state.pastEvents)
                    EventRow(event: e, onTap: () => open(e.id)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
