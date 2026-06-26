import 'package:flutter/material.dart';

/// Visual identity for the debug toolkit.
///
/// The toolkit renders inside its own [Theme] (see `DebugScope`) so it looks
/// consistent and clearly distinct from the host app, regardless of the host
/// app's own theming. A dark palette with a high-visibility accent is used so
/// the overlay never blends into the app being debugged.
abstract final class DebugTheme {
  /// Accent / brand colour used for the floating button and primary actions.
  static const Color accent = Color(0xFF00C2A8);

  /// Background colour of debug surfaces.
  static const Color surface = Color(0xFF101418);

  /// Slightly elevated surface colour (cards, app bars).
  static const Color elevated = Color(0xFF1B2128);

  /// The [ThemeData] applied to the whole toolkit UI.
  static ThemeData get themeData {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        secondary: accent,
        surface: surface,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: elevated,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: elevated,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      listTileTheme: const ListTileThemeData(iconColor: accent),
      dividerTheme: const DividerThemeData(
        color: Colors.white12,
        space: 1,
        thickness: 1,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(),
      ),
    );
  }
}
