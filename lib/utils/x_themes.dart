import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stillnote/utils/x_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class XThemesManager {
  const XThemesManager._();

  static const ThemeMode themeMode = ThemeMode.light;
  static const String appFontFamily = 'Montserrat';
  static const String titleFontFamily = 'Montserrat';

  static void setSystemUIOverlayStyle(BuildContext context) {
    void dark() {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: XColors.greyDark,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: XColors.greyDark,
          systemNavigationBarDividerColor: XColors.greyDark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
      return;
    }

    void light() {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: XColors.white,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: XColors.white,
          systemNavigationBarDividerColor: XColors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
      return;
    }

    if (themeMode == ThemeMode.system) {
      final themeBrightness = MediaQuery.of(context).platformBrightness;
      if (themeBrightness == Brightness.light) light();
      if (themeBrightness == Brightness.dark) dark();
    }
    if (themeMode == ThemeMode.dark) dark();

    if (themeMode == ThemeMode.light) light();
  }
}

class XThemes {
  const XThemes._();
  static ThemeData appTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.getFont(XThemesManager.appFontFamily).fontFamily,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: XColors.greyDark,
      onPrimary: XColors.white,
      secondary: XColors.greyNormal,
      onSecondary: XColors.greyDeep,
      error: XColors.red,
      onError: XColors.white,
      background: XColors.greyHighlight,
      onBackground: XColors.greyDark,
      surface: XColors.white,
      onSurface: XColors.greyDark,
    ),
    appBarTheme: _appBarTheme,
    navigationBarTheme: _navigationBarThemeData,
    navigationRailTheme: _navigationRailThemeData,
    textSelectionTheme:
        const TextSelectionThemeData(cursorColor: XColors.greyDark),
    dialogTheme: const DialogTheme(
      backgroundColor: XColors.white,
      surfaceTintColor: XColors.white,
    ),
  );

  static final NavigationBarThemeData _navigationBarThemeData =
      NavigationBarThemeData(
    elevation: 0,
    backgroundColor: XColors.white,
    surfaceTintColor: XColors.white,
    indicatorColor: XColors.greyDark.withOpacity(0.08),
  );
  static final NavigationRailThemeData _navigationRailThemeData =
      NavigationRailThemeData(
    elevation: 0,
    backgroundColor: XColors.white,
    indicatorColor: XColors.greyDark.withOpacity(0.08),
  );

  static final AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: XColors.white,
    foregroundColor: XColors.greyDark,
    surfaceTintColor: XColors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 24,
      color: XColors.greyDark,
      fontWeight: FontWeight.bold,
      fontFamily:
          GoogleFonts.getFont(XThemesManager.titleFontFamily).fontFamily,
    ),
    shape: Border(
      bottom: BorderSide(
        width: 1,
        color: XColors.greyNormal.withOpacity(0.3),
      ),
    ),
  );
}

class XDarkThemes {
  const XDarkThemes._();
  static ThemeData appTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.getFont(XThemesManager.appFontFamily).fontFamily,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: XColors.white,
      onPrimary: XColors.greyDark,
      secondary: XColors.greyNormal,
      onSecondary: XColors.white,
      error: XColors.red,
      onError: XColors.white,
      background: XColors.greyDeep,
      onBackground: XColors.greyNormal,
      surface: XColors.greyDark,
      onSurface: XColors.white,
    ),
    appBarTheme: _appBarTheme,
    navigationBarTheme: _navigationBarThemeData,
    navigationRailTheme: _navigationRailThemeData,
    textSelectionTheme:
        const TextSelectionThemeData(cursorColor: XColors.white),
    dialogTheme: const DialogTheme(
      backgroundColor: XColors.greyDark,
      surfaceTintColor: XColors.greyDark,
    ),
  );

  static final NavigationBarThemeData _navigationBarThemeData =
      NavigationBarThemeData(
    elevation: 0,
    backgroundColor: XColors.greyDark,
    surfaceTintColor: XColors.greyDark,
    indicatorColor: XColors.white.withOpacity(0.08),
  );

  static final NavigationRailThemeData _navigationRailThemeData =
      NavigationRailThemeData(
    elevation: 0,
    backgroundColor: XColors.greyDark,
    indicatorColor: XColors.white.withOpacity(0.08),
  );

  static final AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: XColors.greyDark,
    foregroundColor: XColors.white,
    surfaceTintColor: XColors.greyDark,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 18,
      color: XColors.white,
      fontWeight: FontWeight.bold,
      fontFamily:
          GoogleFonts.getFont(XThemesManager.titleFontFamily).fontFamily,
    ),
    shape: Border(
      bottom: BorderSide(
        width: 1,
        color: XColors.greyNormal.withOpacity(0.8),
      ),
    ),
  );
}
