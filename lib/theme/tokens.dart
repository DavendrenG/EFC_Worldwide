import 'package:flutter/material.dart';

/// Design tokens lifted directly from the approved EFC prototype.
/// Nothing in the UI layer should hard-code a colour or size that is not here.
class EfcColors {
  EfcColors._();

  static const ink = Color(0xFF08090B);
  static const canvas = Color(0xFF101317);
  static const steel = Color(0xFF191D22);
  static const line = Color(0xFF242A30);
  static const bone = Color(0xFFF2EDE3);
  static const boneDim = Color(0xFFB9B3A8);
  static const mute = Color(0xFF7E878F);
  static const blood = Color(0xFFD8342A);
  static const brass = Color(0xFFC89B3C);
  static const cornerRed = Color(0xFFC4342B);
  static const cornerBlue = Color(0xFF2D6C9E);
  static const free = Color(0xFF7FD3A0);
  static const freeLine = Color(0xFF3E7D58);

  /// Poster gradient used on the featured event block.
  static const posterGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1D2228), Color(0xFF101317)],
    stops: [0.0, 0.65],
  );

  /// Scrim laid over a full-bleed hero so overlaid text stays readable
  /// regardless of what the photograph underneath looks like.
  static const heroScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x2608090B),
      Color(0x1A08090B),
      Color(0xEB08090B),
    ],
    stops: [0.0, 0.35, 0.88],
  );

  /// Lighter scrim for cards where the title sits lower in the frame.
  static const cardScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x0008090B), Color(0xE608090B)],
    stops: [0.30, 0.92],
  );

  /// Placeholder gradient behind artwork that has not loaded yet.
  static const thumbGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A3138), Color(0xFF171B20)],
  );
}

class EfcSpacing {
  EfcSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 22.0;
  static const xxl = 32.0;

  static const screenH = 16.0;
}

class EfcRadius {
  EfcRadius._();

  /// The prototype is deliberately square. Radius is used sparingly.
  static const none = BorderRadius.zero;
  static const pill = BorderRadius.all(Radius.circular(2));
}
