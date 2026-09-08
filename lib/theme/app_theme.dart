import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Typography roles from the prototype:
///   display  - Anton, uppercase, tight leading. Headlines and numerals.
///   body     - Barlow Semi Condensed. Running copy and list titles.
///   utility  - IBM Plex Mono. Labels, timestamps, metadata, eyebrows.
class EfcText {
  EfcText._();

  static TextStyle display({
    double size = 20,
    Color color = EfcColors.bone,
    double letterSpacing = 0.6,
    double height = 1.0,
  }) =>
      GoogleFonts.anton(
        fontSize: size,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontWeight: FontWeight.w400,
      );

  static TextStyle body({
    double size = 15,
    Color color = EfcColors.boneDim,
    FontWeight weight = FontWeight.w400,
    double height = 1.35,
  }) =>
      GoogleFonts.barlowSemiCondensed(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
      );

  static TextStyle utility({
    double size = 10,
    Color color = EfcColors.mute,
    double letterSpacing = 1.4,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        color: color,
        letterSpacing: letterSpacing,
        fontWeight: weight,
      );
}

class EfcTheme {
  EfcTheme._();

  static ThemeData build() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: EfcColors.canvas,
      canvasColor: EfcColors.canvas,
      colorScheme: base.colorScheme.copyWith(
        primary: EfcColors.blood,
        secondary: EfcColors.brass,
        surface: EfcColors.steel,
        onSurface: EfcColors.bone,
        error: EfcColors.blood,
      ),
      dividerTheme: const DividerThemeData(
        color: EfcColors.line,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: EfcColors.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: EfcText.display(size: 17, letterSpacing: 0.9),
        iconTheme: const IconThemeData(color: EfcColors.bone, size: 20),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: EfcColors.blood,
        selectionColor: Color(0x55D8342A),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: EfcColors.blood,
        linearTrackColor: EfcColors.line,
      ),
      splashColor: const Color(0x22D8342A),
      highlightColor: Colors.transparent,
      textTheme: base.textTheme.apply(
        bodyColor: EfcColors.bone,
        displayColor: EfcColors.bone,
      ),
    );
  }
}
