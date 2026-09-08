import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class FighterDetailScreen extends StatelessWidget {
  const FighterDetailScreen({super.key, required this.fighterId});

  final String fighterId;

  Widget _stat(String label, String value) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(border: Border.all(color: EfcColors.line)),
          child: Column(
            children: [
              Text(value, style: EfcText.display(size: 20)),
              const SizedBox(height: 4),
              UtilityLabel(label, size: 8.5),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final f = state.fighterById(fighterId);

    if (f == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ATHLETE')),
        body: const EmptyState(
          title: 'Athlete not found',
          body: 'This profile is no longer listed.',
        ),
      );
    }

    final following = state.isFollowing(f.id);

    return Scaffold(
      appBar: AppBar(title: Text(f.lastName.toUpperCase())),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const ArtworkBox(height: 190),
          Padding(
            padding: const EdgeInsets.all(EfcSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UtilityLabel(
                  '${f.division} \u00b7 ${f.statusLabel}',
                  color: EfcColors.blood,
                  letterSpacing: 1.8,
                ),
                const SizedBox(height: 6),
                Text(
                  f.fullName.toUpperCase(),
                  style: EfcText.display(size: 32, height: 0.98),
                ),
                if (f.nickname != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '\u201c${f.nickname}\u201d'.toUpperCase(),
                    style: EfcText.display(
                      size: 16,
                      color: EfcColors.brass,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
                if (f.country != null) ...[
                  const SizedBox(height: 8),
                  UtilityLabel(f.country!, size: 10.5, letterSpacing: 1.2),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    _stat('Record', f.record.toString()),
                    const SizedBox(width: 8),
                    _stat('KO / TKO', '${f.koWins}'),
                    const SizedBox(width: 8),
                    _stat('Subs', '${f.submissionWins}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _stat('Height', f.heightCm == null
                        ? '\u2014'
                        : '${f.heightCm}'),
                    const SizedBox(width: 8),
                    _stat('Reach',
                        f.reachCm == null ? '\u2014' : '${f.reachCm}'),
                    const SizedBox(width: 8),
                    _stat('Age', f.age == null ? '\u2014' : '${f.age}'),
                  ],
                ),
                const SizedBox(height: 18),
                EfcButton(
                  label: following ? 'Following' : 'Follow this athlete',
                  ghost: following,
                  onPressed: () async {
                    await state.toggleFollow(f.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: EfcColors.steel,
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          following
                              ? 'You will no longer get alerts for '
                                  '${f.lastName}.'
                              : 'You will get a push when ${f.lastName} '
                                  'is booked.',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                UtilityLabel(
                  'Following an athlete subscribes you to their fight '
                  'announcements.',
                  size: 9.5,
                  letterSpacing: 0.6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
