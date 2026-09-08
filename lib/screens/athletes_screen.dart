import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import 'fighter_detail_screen.dart';
import 'screen_scaffold.dart';

class AthletesScreen extends StatefulWidget {
  const AthletesScreen({super.key});

  @override
  State<AthletesScreen> createState() => _AthletesScreenState();
}

class _AthletesScreenState extends State<AthletesScreen> {
  int _tab = 0;

  List<String> get _tabs => ['Champions', ...MockData.divisions];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.status == LoadStatus.loading && state.fighters.isEmpty) {
      return const Column(
        children: [
          EfcHeader(title: 'Athletes'),
          Expanded(child: LoadingState()),
        ],
      );
    }

    final list = _tab == 0
        ? state.champions
        : state.fightersInDivision(_tabs[_tab]);

    // Head-to-head preview uses the main event of the next card.
    Fighter? red;
    Fighter? blue;
    final next = state.featuredEvent;
    if (next != null && next.bouts.isNotEmpty) {
      final main = next.bouts.firstWhere(
        (b) => b.isMainEvent,
        orElse: () => next.bouts.first,
      );
      red = state.fighterById(main.redCornerId);
      blue = state.fighterById(main.blueCornerId);
    }

    return Column(
      children: [
        EfcHeader(
          title: 'Athletes',
          meta: '${state.fighters.length} listed',
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
                if (_tab == 0 && red != null && blue != null) ...[
                  const SectionHeader(title: 'Next main event'),
                  TaleOfTape(red: red, blue: blue),
                  const HairLine(),
                ],
                if (list.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: EmptyState(
                      title: 'Nobody here yet',
                      body: 'Athletes appear as soon as they are added in '
                          'the CMS.',
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      EfcSpacing.screenH,
                      EfcSpacing.md,
                      EfcSpacing.screenH,
                      0,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.80,
                      ),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final f = list[i];
                        return GridCard(
                          title: f.fullName,
                          subtitle: f.statusLabel,
                          caption: f.division,
                          trailing: f.isChampion
                              ? const Pill('Champ')
                              : null,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  FighterDetailScreen(fighterId: f.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: UtilityLabel(
                    'Records and measurements are placeholders until the '
                    'CMS is populated.',
                    size: 9.5,
                    letterSpacing: 0.6,
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
