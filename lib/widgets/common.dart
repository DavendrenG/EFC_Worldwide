import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Mono uppercase label used for eyebrows, timestamps and metadata.
class UtilityLabel extends StatelessWidget {
  const UtilityLabel(
    this.text, {
    super.key,
    this.color = EfcColors.mute,
    this.size = 10,
    this.letterSpacing = 1.4,
  });

  final String text;
  final Color color;
  final double size;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: EfcText.utility(
          size: size,
          color: color,
          letterSpacing: letterSpacing,
        ),
      );
}

/// Section header: mono label on the left, optional action on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          EfcSpacing.screenH,
          20,
          EfcSpacing.screenH,
          11,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Display face, not mono — mono everywhere read as dense and
            // technical, and buried the hierarchy between title and body.
            Text(title.toUpperCase(),
                style: EfcText.display(size: 17, letterSpacing: 0.4)),
            if (action != null)
              GestureDetector(
                onTap: onAction,
                behavior: HitTestBehavior.opaque,
                child: UtilityLabel(
                  action!,
                  size: 9.5,
                  color: EfcColors.blood,
                  letterSpacing: 1.2,
                ),
              ),
          ],
        ),
      );
}

/// Small outlined tag. Variants match the prototype's pill styles.
enum PillVariant { brass, live, free, neutral }

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.variant = PillVariant.brass});

  final String text;
  final PillVariant variant;

  @override
  Widget build(BuildContext context) {
    final (Color border, Color fg, Color bg) = switch (variant) {
      PillVariant.brass => (EfcColors.brass, EfcColors.brass, Colors.transparent),
      PillVariant.live => (EfcColors.blood, Colors.white, EfcColors.blood),
      PillVariant.free => (EfcColors.freeLine, EfcColors.free, Colors.transparent),
      PillVariant.neutral => (EfcColors.line, EfcColors.mute, Colors.transparent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: border),
        color: bg,
        borderRadius: EfcRadius.pill,
      ),
      child: Text(
        text.toUpperCase(),
        style: EfcText.utility(size: 9, color: fg, letterSpacing: 1.0),
      ),
    );
  }
}

/// Primary / ghost action button, square-cornered per the prototype.
class EfcButton extends StatelessWidget {
  const EfcButton({
    super.key,
    required this.label,
    this.onPressed,
    this.ghost = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ghost
                ? Colors.transparent
                : (enabled ? EfcColors.blood : EfcColors.steel),
            border: Border.all(
              color: ghost
                  ? EfcColors.line
                  : (enabled ? EfcColors.blood : EfcColors.line),
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: EfcText.display(
              size: 13,
              letterSpacing: 1.1,
              color: ghost
                  ? EfcColors.bone
                  : (enabled ? Colors.white : EfcColors.mute),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling filter chips (divisions, video categories).
class ChipTabs extends StatelessWidget {
  const ChipTabs({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
        // Tall enough that the label survives the largest text scale we
        // allow. A 46px box clipped the chips on default Samsung settings.
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: EfcSpacing.screenH,
            vertical: EfcSpacing.sm,
          ),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, i) {
            final on = i == selectedIndex;
            return GestureDetector(
              onTap: () => onSelected(i),
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: on ? EfcColors.blood : EfcColors.line),
                  color: on ? const Color(0x29D8342A) : Colors.transparent,
                ),
                child: Text(
                  items[i].toUpperCase(),
                  style: EfcText.utility(
                    size: 10,
                    color: on ? Colors.white : EfcColors.mute,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              ),
            );
          },
        ),
      );
}

/// Placeholder artwork block. Swap in CachedNetworkImage when the CMS
/// starts returning real image URLs.
class ArtworkBox extends StatelessWidget {
  const ArtworkBox({
    super.key,
    this.height,
    this.caption,
    this.imageUrl,
  });

  /// Null height means "fill the parent" — required when used inside a Stack
  /// with StackFit.expand, which is how every Layout B hero works.
  final double? height;
  final String? caption;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    Widget content = Container(
      decoration: const BoxDecoration(gradient: EfcColors.thumbGradient),
    );

    if (hasImage) {
      content = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        // Fade in rather than popping, so a scroll past unloaded art is calm.
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (_, __) => Container(
          decoration: const BoxDecoration(gradient: EfcColors.thumbGradient),
        ),
        errorWidget: (_, __, ___) => Container(
          decoration: const BoxDecoration(gradient: EfcColors.thumbGradient),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
          if (caption != null)
            Positioned(
              left: 7,
              bottom: 7,
              child: Container(
                color: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: UtilityLabel(
                  caption!,
                  size: 8.5,
                  color: EfcColors.bone,
                  letterSpacing: 1.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Full-bleed hairline divider matching the prototype's 1px rules.
class HairLine extends StatelessWidget {
  const HairLine({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: EfcColors.line);
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CONTENT DIDN\u2019T LOAD',
                style: EfcText.display(size: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: EfcText.body(),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 18),
                EfcButton(label: 'Try again', onPressed: onRetry),
              ],
            ],
          ),
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title.toUpperCase(), style: EfcText.display(size: 18)),
              const SizedBox(height: 8),
              Text(body, style: EfcText.body(), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
