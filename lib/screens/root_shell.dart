import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'athletes_screen.dart';
import 'events_screen.dart';
import 'home_screen.dart';
import 'news_screen.dart';
import 'watch_screen.dart';

/// Bottom tab shell. Index order matches the prototype:
/// Home / Events / Athletes / Watch / News.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  /// Lets the deep-link handler in [EfcApp] switch tabs from outside the tree.
  static final shellKey = GlobalKey<RootShellState>();
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<RootShell> createState() => RootShellState();
}

class RootShellState extends State<RootShell> {
  int _index = 0;

  void goToTab(int i) {
    if (i < 0 || i > 4) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _index,
            children: const [
              HomeScreen(),
              EventsScreen(),
              AthletesScreen(),
              WatchScreen(),
              NewsScreen(),
            ],
          ),
        ),
        bottomNavigationBar: _TabBar(index: _index, onTap: goToTab),
      );
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const _items = <(IconData, String)>[
    (Icons.stadium_outlined, 'Home'),
    (Icons.calendar_today_outlined, 'Events'),
    (Icons.groups_outlined, 'Athletes'),
    (Icons.play_arrow_outlined, 'Watch'),
    (Icons.article_outlined, 'News'),
  ];

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B0D10),
          border: Border(top: BorderSide(color: EfcColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == index,
                    button: true,
                    label: _items[i].$2,
                    child: InkWell(
                      onTap: () => onTap(i),
                      child: Container(
                        padding: const EdgeInsets.only(top: 9, bottom: 11),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: i == index
                                  ? EfcColors.blood
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _items[i].$1,
                              size: 19,
                              color: i == index
                                  ? Colors.white
                                  : EfcColors.mute,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _items[i].$2.toUpperCase(),
                              style: EfcText.utility(
                                size: 8.5,
                                color: i == index
                                    ? Colors.white
                                    : EfcColors.mute,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}
