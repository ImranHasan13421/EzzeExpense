// ============================================================
//  core/theme.dart — Fully Adaptive Theme (Light + Dark)
//  Accent: Emerald #00A88A  |  Balanced radius
//  Dark:  Deep green-black, glowing emerald
//  Light: Crisp white/mint, rich emerald accents
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Shared accent colours ─────────────────────────────────────
const Color kAccent      = Color(0xFF008FA8); // main emerald — readable on both
const Color kAccentLight = Color(0xFF00B8C9); // lighter glow
const Color kAccentDeep  = Color(0xFF006F79); // deep teal for light bg

// ── Semantic colours ──────────────────────────────────────────
const Color kDanger  = Color(0xFFD32F2F); // red   — strong on both
const Color kWarning = Color(0xFFE65100); // deep orange
const Color kPurple  = Color(0xFF6A1B9A); // purple
const Color kBlue    = Color(0xFF1565C0); // blue

// ── Dark palette ──────────────────────────────────────────────
const _dBgDeep      = Color(0xFF080D0B);
const _dBgBase      = Color(0xFF0D1510);
const _dBgCard      = Color(0xFF141F1A);
const _dBgCardAlt   = Color(0xFF1A2920);
const _dBgInput     = Color(0xFF111C16);
const _dTextPrimary = Color(0xFFE2F0EB);
const _dTextSecond  = Color(0xFF7A9E92);
const _dTextHint    = Color(0xFF4A6B60);
const _dDivider     = Color(0xFF1E2E28);
const _dBorder      = Color(0xFF1E3028);

// ── Light palette ─────────────────────────────────────────────
const _lBgBase      = Color(0xFFF2F9F7); // very light mint
const _lBgCard      = Color(0xFFFFFFFF); // white cards
const _lBgCardAlt   = Color(0xFFE8F5F2); // soft mint alt
const _lBgInput     = Color(0xFFFFFFFF); // white input
const _lTextPrimary = Color(0xFF0A1F1A); // near-black, green-tinted
const _lTextSecond  = Color(0xFF3D7268); // medium green-grey
const _lTextHint    = Color(0xFF90B8B1); // soft hint
const _lDivider     = Color(0xFFD4ECE7); // light divider
const _lBorder      = Color(0xFFBFE0DA); // light border

// ── EzzeTheme context helper ──────────────────────────────────
// Use EzzeTheme.of(context) inside widgets to get adaptive colours
class EzzeTheme {
  final bool isDark;
  const EzzeTheme._(this.isDark);

  factory EzzeTheme.of(BuildContext context) {
    return EzzeTheme._(Theme.of(context).brightness == Brightness.dark);
  }

  Color get bgDeep      => isDark ? _dBgDeep      : const Color(0xFFE6F4F1);
  Color get bgBase      => isDark ? _dBgBase      : _lBgBase;
  Color get bgCard      => isDark ? _dBgCard      : _lBgCard;
  Color get bgCardAlt   => isDark ? _dBgCardAlt   : _lBgCardAlt;
  Color get bgInput     => isDark ? _dBgInput     : _lBgInput;
  Color get textPrimary => isDark ? _dTextPrimary : _lTextPrimary;
  Color get textSecond  => isDark ? _dTextSecond  : _lTextSecond;
  Color get textHint    => isDark ? _dTextHint    : _lTextHint;
  Color get divider     => isDark ? _dDivider     : _lDivider;
  Color get border      => isDark ? _dBorder      : _lBorder;
  Color get accentGlow  => isDark
      ? const Color(0x2500C9A7) : const Color(0x1A00A88A);
  Color get dangerLight => isDark
      ? const Color(0x22D32F2F) : const Color(0x18D32F2F);
  Color get warningLight => isDark
      ? const Color(0x22E65100) : const Color(0x18E65100);

  // Adaptive card decorations
  BoxDecoration glowCard({double radius = 16}) => BoxDecoration(
    color:        bgCard,
    borderRadius: BorderRadius.circular(radius),
    border:       Border.all(color: border, width: 1),
    boxShadow: isDark
        ? const [BoxShadow(
            color: Color(0x1A00C9A7), blurRadius: 12, offset: Offset(0, 4))]
        : [BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8, offset: const Offset(0, 2))],
  );

  BoxDecoration accentCard({double radius = 16}) => BoxDecoration(
    color: isDark
        ? const Color(0xFF0E2420) : const Color(0xFFDDF2EE),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
        color: kAccent.withOpacity(isDark ? 0.35 : 0.45), width: 1),
    boxShadow: isDark
        ? const [BoxShadow(
            color: Color(0x2200C9A7), blurRadius: 16, offset: Offset(0, 4))]
        : [BoxShadow(
            color: kAccent.withOpacity(0.12),
            blurRadius: 10, offset: const Offset(0, 3))],
  );

  BoxDecoration headerGradient() => BoxDecoration(
    gradient: LinearGradient(
      colors: isDark
          ? [const Color(0xFF0A1812), _dBgBase]
          : [const Color(0xFFB2DFDB), _lBgBase],
      begin: Alignment.topCenter,
      end:   Alignment.bottomCenter,
    ),
  );
}

// ── Static gradient (accent always same) ─────────────────────
const LinearGradient kAccentGradient = LinearGradient(
  colors: [kAccent, kAccentLight],
  begin:  Alignment.topLeft,
  end:    Alignment.bottomRight,
);

// ── ThemeData builder ─────────────────────────────────────────
ThemeData buildTheme(bool isDark) {
  final t = EzzeTheme._(isDark);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor:              Colors.transparent,
    statusBarBrightness:         isDark ? Brightness.dark  : Brightness.light,
    statusBarIconBrightness:     isDark ? Brightness.light : Brightness.dark,
    systemNavigationBarColor:    t.bgBase,
    systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
  ));

  return ThemeData(
    useMaterial3:            true,
    brightness:              isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: t.bgBase,

    colorScheme: isDark
        ? ColorScheme.dark(
            primary:    kAccent,      onPrimary:  _dBgDeep,
            secondary:  kAccentLight, onSecondary: _dBgDeep,
            surface:    t.bgCard,     onSurface:  t.textPrimary,
            surfaceContainerHighest: t.bgCardAlt,
            error:      kDanger,      onError:    Colors.white,
          )
        : ColorScheme.light(
            primary:    kAccent,      onPrimary:  Colors.white,
            secondary:  kAccentDeep,  onSecondary: Colors.white,
            surface:    t.bgCard,     onSurface:  t.textPrimary,
            surfaceContainerHighest: t.bgCardAlt,
            error:      kDanger,      onError:    Colors.white,
          ),

    // Cards
    cardTheme: CardThemeData(
      color:       t.bgCard,
      elevation:   isDark ? 0 : 1,
      shadowColor: isDark ? Colors.transparent : Colors.black12,
      margin:      EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: t.border, width: 1),
      ),
    ),

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor:  t.bgBase,
      foregroundColor:  t.textPrimary,
      elevation:        0,
      centerTitle:      false,
      surfaceTintColor: Colors.transparent,
      shadowColor:      Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor:          Colors.transparent,
        statusBarBrightness:     isDark ? Brightness.dark  : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        color:         t.textPrimary,
        fontSize:      20,
        fontWeight:    FontWeight.w700,
        letterSpacing: -0.3,
      ),
      iconTheme:        IconThemeData(color: t.textSecond),
      actionsIconTheme: IconThemeData(color: t.textSecond),
    ),

    // Bottom nav
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: t.bgBase,
      indicatorColor:  kAccent.withOpacity(isDark ? 0.2 : 0.13),
      iconTheme: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected))
          return const IconThemeData(color: kAccent, size: 24);
        return IconThemeData(color: t.textHint, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected))
          return const TextStyle(
              color: kAccent, fontSize: 11, fontWeight: FontWeight.w600);
        return TextStyle(
            color: t.textHint, fontSize: 11, fontWeight: FontWeight.w400);
      }),
      surfaceTintColor: Colors.transparent,
      elevation:        0,
      height:           68,
    ),

    // FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kAccent,
      foregroundColor: isDark ? _dBgDeep : Colors.white,
      elevation:       8,
      shape:           const CircleBorder(),
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled:    true,
      fillColor: t.bgInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: t.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: t.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kAccent, width: 1.5),
      ),
      labelStyle:      TextStyle(color: t.textSecond, fontSize: 14),
      hintStyle:       TextStyle(color: t.textHint,   fontSize: 14),
      prefixIconColor: t.textSecond,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Chips
    chipTheme: ChipThemeData(
      backgroundColor:     t.bgCardAlt,
      selectedColor:       kAccent.withOpacity(0.15),
      labelStyle:          TextStyle(color: t.textSecond, fontSize: 13),
      secondaryLabelStyle: const TextStyle(color: kAccent, fontSize: 13),
      side:                BorderSide(color: t.border, width: 1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      checkmarkColor: kAccent,
    ),

    // Divider
    dividerTheme:
        DividerThemeData(color: t.divider, thickness: 1, space: 1),

    // Text
    textTheme: TextTheme(
      displayLarge:  TextStyle(color: t.textPrimary, fontWeight: FontWeight.w800),
      displayMedium: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w700),
      titleLarge:    TextStyle(color: t.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
      titleMedium:   TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
      titleSmall:    TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
      bodyLarge:     TextStyle(color: t.textPrimary, fontSize: 15),
      bodyMedium:    TextStyle(color: t.textSecond,  fontSize: 14),
      bodySmall:     TextStyle(color: t.textSecond,  fontSize: 12),
      labelLarge:    TextStyle(color: t.textSecond,  fontWeight: FontWeight.w600, fontSize: 13),
      labelSmall:    TextStyle(color: t.textHint,    fontSize: 11),
    ),

    // Switch / Radio
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? kAccent : t.textHint),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? kAccent.withOpacity(0.3)
              : t.bgCardAlt),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? kAccent : t.textHint),
    ),

    // ListTile
    listTileTheme: ListTileThemeData(
      iconColor:         t.textSecond,
      textColor:         t.textPrimary,
      subtitleTextStyle: TextStyle(color: t.textSecond, fontSize: 13),
    ),

    // Progress
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color:            kAccent,
      linearTrackColor: t.bgCardAlt,
    ),

    iconTheme: IconThemeData(color: t.textSecond, size: 22),
  );
}
