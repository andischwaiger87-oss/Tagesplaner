import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Farbthemen (Kachel-/Akzentfarbe wählbar).
const List<Color> kSeeds = [
  Color(0xFF2E7D6F), // Teal
  Color(0xFF3B6FB0), // Blau
  Color(0xFF8E5BA8), // Lila
  Color(0xFFC9772E), // Orange
  Color(0xFF4F7A52), // Grün
];
const Color kAccent = Color(0xFFEC6A53); // kräftiges Korall für die Hauptaktion
const Color kInk = Color(0xFF132019);

class AppTheme {
  static Color tile(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return cs.brightness == Brightness.dark ? const Color(0xFF26302E) : cs.primary;
  }

  static ThemeData build({required int themeIndex, required bool highContrast}) {
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
      textTheme: GoogleFonts.lexendTextTheme(baseTextTheme)
          .apply(bodyColor: text, displayColor: text),
      splashFactory: InkSparkle.splashFactory,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: seed.withOpacity(dark ? .30 : .16),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: text),
        ),
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: text)),
        height: 74,
      ),
    );
  }
}
