import 'package:flutter/material.dart';

/// Signal — unified Material 3 color scheme (single dark theme)
class AppColors {
  AppColors._();

  // ── Brand base ─────────────────────────────────────────
  static const Color primary = Color(0xFFFF6B35);        // Vibrant orange
  static const Color primaryLight = Color(0xFFFF8C42);    // Light orange
  static const Color primaryDeep = Color(0xFFE63946);     // Deep red-orange

  // ── M3: Primary ────────────────────────────────────────
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF5C2413);
  static const Color onPrimaryContainer = Color(0xFFFFDAC4);

  // ── M3: Secondary (mint/cyan → success, keep, save) ─────
  static const Color secondary = Color(0xFF00D9FF);
  static const Color onSecondary = Color(0xFF00363D);
  static const Color secondaryContainer = Color(0xFF004E5C);
  static const Color onSecondaryContainer = Color(0xFFB8F0FF);

  // ── M3: Tertiary (amber/gold → warning, unsorted) ───────
  static const Color tertiary = Color(0xFFFFB703);
  static const Color onTertiary = Color(0xFF3D2E00);
  static const Color tertiaryContainer = Color(0xFF5C4400);
  static const Color onTertiaryContainer = Color(0xFFFFE9B3);

  // ── M3: Error (rose/hot pink → delete, destructive) ─────
  static const Color error = Color(0xFFFF006E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFF5C0030);
  static const Color onErrorContainer = Color(0xFFFFD1E4);

  // ── M3: Background / Surface ────────────────────────────
  static const Color background = Color(0xFF0F0F1E);
  static const Color onBackground = Color(0xFFF2F2F7);

  static const Color surface = Color(0xFF1A1A2E);
  static const Color onSurface = Color(0xFFF2F2F7);

  static const Color surfaceVariant = Color(0xFF2D3561);
  static const Color onSurfaceVariant = Color(0xFFB0B0C7);

  // Surface container tonal scale (M3 updated baseline)
  static const Color surfaceContainerLowest = Color(0xFF0A0A14);
  static const Color surfaceContainerLow = Color(0xFF15152A);
  static const Color surfaceContainer = Color(0xFF1A1A2E);      // = surface
  static const Color surfaceContainerHigh = Color(0xFF16213E);  // = old surfaceElevated
  static const Color surfaceContainerHighest = Color(0xFF212C4A);

  // ── M3: Outline / misc ───────────────────────────────────
  static const Color outline = Color(0xFF6C6C8C);
  static const Color outlineVariant = Color(0xFF2D3561);  // = divider
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color surfaceTint = primary;

  static const Color inverseSurface = Color(0xFFF2F2F7);
  static const Color onInverseSurface = Color(0xFF1A1A2E);
  static const Color inversePrimary = Color(0xFFFFB199);

  // ── Legacy aliases (kept so old references don't break) ──
  static const Color surfaceElevated = surfaceContainerHigh;
  static const Color divider = outlineVariant;
  static const Color mint = secondary;
  static const Color rose = error;
  static const Color amber = tertiary;
  static const Color grey = Color(0xFF222832);

  // ── App-specific text aliases (NOT M3 roles) ─────────────
  // Use these for body text on background/surface — don't reuse
  // onPrimary/onSecondary/etc. for this, they mean something else.
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textHint = Color(0xFF808080);

  // ── Folder tag palette (cycle for user folders) ──────────
  static const List<Color> folderColors = [
    Color(0xFF7C5CFC),
    Color(0xFF3DDC97),
    Color(0xFFFF5C7A),
    Color(0xFFFFB74D),
    Color(0xFF4FC3F7),
    Color(0xFFFF7CCB),
  ];

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDeep],
  );

  static const LinearGradient keepGradient = LinearGradient(
    colors: [secondary, Color(0xFF5FE0A5)],
  );

  static const LinearGradient deleteGradient = LinearGradient(
    colors: [error, Color(0xFFFF8E8E)],
  );
}