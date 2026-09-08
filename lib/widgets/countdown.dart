import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'common.dart';

/// Four-cell countdown to the main card, exactly as in the prototype.
/// Flips to a LIVE NOW banner once the event starts.
class EventCountdown extends StatefulWidget {
  const EventCountdown({super.key, required this.target});

  final DateTime target;

  @override
  State<EventCountdown> createState() => _EventCountdownState();
}

class _EventCountdownState extends State<EventCountdown> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.target.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = widget.target.difference(DateTime.now()));
    });
  }

  @override
  void didUpdateWidget(covariant EventCountdown old) {
    super.didUpdateWidget(old);
    if (old.target != widget.target) {
      _remaining = widget.target.difference(DateTime.now());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return Container(
        width: double.infinity,
        color: EfcColors.blood,
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        child: Text(
          'LIVE NOW',
          style: EfcText.display(
            size: 16,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
        ),
      );
    }

    final cells = <(String, String)>[
      (_remaining.inDays.toString(), 'Days'),
      (_pad(_remaining.inHours.remainder(24)), 'Hrs'),
      (_pad(_remaining.inMinutes.remainder(60)), 'Min'),
      (_pad(_remaining.inSeconds.remainder(60)), 'Sec'),
    ];

    return Semantics(
      label: 'Countdown: ${_remaining.inDays} days remaining',
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0D10),
                  border: Border.all(color: EfcColors.line),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  children: [
                    Text(
                      cells[i].$1,
                      style: EfcText.display(size: 22),
                    ),
                    const SizedBox(height: 3),
                    UtilityLabel(cells[i].$2, size: 8.5),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
