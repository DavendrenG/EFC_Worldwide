import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/layout_b.dart';
import 'screen_scaffold.dart';
import 'video_player_screen.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  int _tab = 0;
  String _query = '';

  static const _tabs = <String>[
    'All',
    'Full fights',
    'Highlights',
    'Features',
    'Behind the scenes',
    'Free',
  ];

  List<VideoItem> _filtered(AppState state) {
    final list = switch (_tab) {
      1 => state.videosOfKind(VideoKind.fullFight),
      2 => state.videosOfKind(VideoKind.highlights),
      3 => state.videosOfKind(VideoKind.feature),
      4 => state.videosOfKind(VideoKind.behindTheScenes),
      5 => state.videosOfKind(null, freeOnly: true),
      _ => state.videosOfKind(null),
    };
    if (_query.trim().isEmpty) return list;
    final q = _query.toLowerCase();
    return list
        .where(
          (v) =>
              v.title.toLowerCase().contains(q) ||
              (v.eventName ?? '').toLowerCase().contains(q) ||
              (v.division ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.status == LoadStatus.loading && state.videos.isEmpty) {
      return const Column(
        children: [
          EfcHeader(title: 'Fight library'),
          Expanded(child: LoadingState()),
        ],
      );
    }

    final list = _filtered(state);

    return Column(
      children: [
        EfcHeader(
          title: 'Fight library',
          meta: '${state.videos.length} items',
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: state.refresh,
            color: EfcColors.blood,
            backgroundColor: EfcColors.steel,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                ChipTabs(
                  items: _tabs,
                  selectedIndex: _tab,
                  onSelected: (i) => setState(() => _tab = i),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: EfcText.body(size: 14, color: EfcColors.bone),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search fighter, event or division',
                      hintStyle: EfcText.utility(size: 11, letterSpacing: 0.6),
                      prefixIcon: const Icon(Icons.search,
                          size: 17, color: EfcColors.mute),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 11),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: EfcColors.line),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: EfcColors.blood),
                      ),
                    ),
                  ),
                ),
                if (list.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: EmptyState(
                      title: 'Nothing matches',
                      body: 'Try a different fighter, event or division.',
                    ),
                  )
                else ...[
                  // One wide card anchors the screen, the rest are portrait
                  // poster tiles — a fight poster is portrait, so is the tile.
                  LeadCard(
                    title: list.first.title,
                    meta: list.first.durationSeconds > 0
                        ? '${list.first.durationLabel} \u00b7 '
                            '${list.first.tierLabel}'
                        : list.first.tierLabel,
                    imageUrl: list.first.thumbnailUrl,
                    height: 172,
                    showPlay: !list.first.isPremium,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VideoPlayerScreen(video: list.first),
                      ),
                    ),
                  ),
                  if (list.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: SizedBox(
                        height: 236,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: EfcSpacing.screenH),
                          itemCount: list.length - 1,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final v = list[i + 1];
                            return PosterTile(
                              video: v,
                              locked: v.isPremium,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => VideoPlayerScreen(video: v),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
