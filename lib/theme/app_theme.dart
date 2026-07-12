import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Farbthemen (Kachel-/Akzentfarbe wählbar).
const List<Color> kSeeds = [
  Color(0xFF2E7D6F), // Teal
  Color(0xFF3B6FB0), // Blau
  Color(0xFF8E5BA8), // Lila
  Color(0xFFC9772E), // Orange
  Color(0xFF4F7A52), // Grün
  Color(0xFFB0466A), // Beere
  Color(0xFF4A63B0), // Indigo
  Color(0xFF00897B), // Petrol
  Color(0xFF7A5C3E), // Braun
  Color(0xFF546E7A), // Schiefer
];

/// Wählbare, gut lesbare Schriftarten. Atkinson Hyperlegible ist eigens für
/// Sehschwäche entwickelt; die anderen sind klar und freundlich.
const List<String> kFonts = [
  'Lexend',
  'Atkinson Hyperlegible',
  'Nunito',
  'Poppins',
  'Mulish',
];

/// Liefert ein TextTheme für die gewählte Schrift – mit sicherem Rückfall.
TextTheme _fontTextTheme(String family, TextTheme base) {
  try { return GoogleFonts.getTextTheme(family, base); }
  catch (_) { return GoogleFonts.lexendTextTheme(base); }
}

TextStyle _fontStyle(String family, {double? fontSize, FontWeight? fontWeight, Color? color}) {
  try { return GoogleFonts.getFont(family, fontSize: fontSize, fontWeight: fontWeight, color: color); }
  catch (_) { return GoogleFonts.lexend(fontSize: fontSize, fontWeight: fontWeight, color: color); }
}
const Color kAccent = Color(0xFFEC6A53); // kräftiges Korall für die Hauptaktion
const Color kInk = Color(0xFF132019);

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context,
      Animation<double> animation, Animation<double> secondaryAnimation, Widget child) => child;
}

const PageTransitionsTheme _noTransitions = PageTransitionsTheme(builders: {
  TargetPlatform.android: _NoTransitionsBuilder(),
  TargetPlatform.iOS: _NoTransitionsBuilder(),
  TargetPlatform.macOS: _NoTransitionsBuilder(),
  TargetPlatform.windows: _NoTransitionsBuilder(),
  TargetPlatform.linux: _NoTransitionsBuilder(),
});

class AppTheme {
  static Color tile(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return cs.brightness == Brightness.dark ? const Color(0xFF26302E) : cs.primary;
  }

  static ThemeData build({required int themeIndex, required bool highContrast, bool reduceMotion = false, String fontFamily = 'Lexend'}) {
    final seed = kSeeds[themeIndex.clamp(0, kSeeds.length - 1)];
    final dark = highContrast;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: dark ? const Color(0xFFFFD24A) : seed,
    ).copyWith(
      surface: dark ? const Color(0xFF161D1B) : Colors.white,
    );
    final bg = dark ? const Color(0xFF0F1413) : const Color(0xFFF1F4F3);
    final text = dark ? Colors.white : kInk;
    final baseTextTheme = (dark ? ThemeData.dark() : ThemeData.light()).textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? bg : Colors.transparent,
      textTheme: _fontTextTheme(fontFamily, baseTextTheme)
          .apply(bodyColor: text, displayColor: text),
      splashFactory: reduceMotion ? NoSplash.splashFactory : InkSparkle.splashFactory,
      pageTransitionsTheme: reduceMotion ? _noTransitions : null,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: seed.withOpacity(dark ? .30 : .16),
        labelTextStyle: WidgetStatePropertyAll(
          _fontStyle(fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: text),
        ),
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: text)),
        height: 74,
      ),
    );
  }
}
