import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
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
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.92,
                      ),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final v = list[i];
                        return GridCard(
                          title: v.title,
                          subtitle: '${v.kind.label} \u00b7 ${v.tierLabel}',
                          caption: v.durationLabel,
                          trailing: v.isPremium
                              ? const Pill('Premium')
                              : const Pill('Free', variant: PillVariant.free),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => VideoPlayerScreen(video: v),
                            ),
                          ),
                        );
                      },
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
