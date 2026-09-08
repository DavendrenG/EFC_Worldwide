import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// Sticky in-app header: display title left, mono meta right.
class EfcHeader extends StatelessWidget {
  const EfcHeader({
    super.key,
    required this.title,
    this.meta,
    this.leading,
  });

  final String title;
  final String? meta;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: EfcSpacing.screenH,
          vertical: EfcSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: EfcColors.canvas,
          border: Border(bottom: BorderSide(color: EfcColors.line)),
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: EfcText.display(size: 16, letterSpacing: 0.9),
              ),
            ),
            if (meta != null) UtilityLabel(meta!, letterSpacing: 1.0),
          ],
        ),
      );
}
