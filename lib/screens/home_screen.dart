import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import '../widgets/countdown.dart';
import 'article_screen.dart';
import 'event_detail_screen.dart';
import 'root_shell.dart';
import 'screen_scaffold.dart';
import 'video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openTickets(String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: EfcColors.steel,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.status == LoadStatus.loading && state.events.isEmpty) {
      return const Column(
        children: [
          EfcHeader(title: 'EFC', meta: 'JHB \u00b7 CAT'),
          Expanded(child: LoadingState()),
        ],
      );
    }

    if (state.status == LoadStatus.failed && state.events.isEmpty) {
      return Column(
        children: [
          const EfcHeader(title: 'EFC', meta: 'JHB \u00b7 CAT'),
          Expanded(
            child: ErrorState(
              message: state.errorMessage ?? 'Something went wrong.',
              onRetry: state.refresh,
            ),
          ),
        ],
      );
    }

    final featured = state.featuredEvent;
    final continueWatching = state.videos.take(4).toList();
    final latest = state.sortedArticles.take(3).toList();

    return Column(
      children: [
        const EfcHeader(title: 'EFC', meta: 'JHB \u00b7 CAT'),
        Expanded(
          child: RefreshIndicator(
            onRefresh: state.refresh,
            color: EfcColors.blood,
            backgroundColor: EfcColors.steel,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (featured != null)
                  EventPoster(
                    event: featured,
                    countdown: EventCountdown(target: featured.startsAt),
                    onTickets: featured.ticketUrl == null
                        ? () => _toast('Tickets for ${featured.name} '
                            'are not on sale yet.')
                        : () => _openTickets(featured.ticketUrl),
                    onRemind: () => _toast(
                      'You\u2019ll get a push when ${featured.name} '
                      'fight week starts.',
                    ),
                  ),
                if (continueWatching.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Continue watching',
                    action: 'All',
                    onAction: () => context
                        .findAncestorStateOfType<RootShellState>()
                        ?.goToTab(3),
                  ),
                  SizedBox(
                    height: 152,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: EfcSpacing.screenH,
                      ),
                      itemCount: continueWatching.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => RailTile(
                        video: continueWatching[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                VideoPlayerScreen(video: continueWatching[i]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (state.upcomingEvents.length > 1) ...[
                  SectionHeader(
                    title: 'Also coming up',
                    action: 'Schedule',
                    onAction: () => context
                        .findAncestorStateOfType<RootShellState>()
                        ?.goToTab(1),
                  ),
                  for (final e in state.upcomingEvents.skip(1).take(2))
                    EventRow(
                      event: e,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EventDetailScreen(eventId: e.id),
                        ),
                      ),
                    ),
                ],
                SectionHeader(
                  title: 'Latest',
                  action: 'News',
                  onAction: () => context
                      .findAncestorStateOfType<RootShellState>()
                      ?.goToTab(4),
                ),
                for (final a in latest)
                  ArticleRow(
                    article: a,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ArticleScreen(article: a),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
