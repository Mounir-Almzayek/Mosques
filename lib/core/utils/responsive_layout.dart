import 'package:flutter/material.dart';

class ResponsiveLayout {
  static bool isMobile(BuildContext context) {
    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide < 600;
  }

  static bool isTablet(BuildContext context) {
    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600 && shortestSide < 900;
  }

  static bool isDesktop(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // Desktop based on width or large aspect ratio on medium screens
    return size.width >= 900 || (size.aspectRatio > 1.2 && size.width >= 800);
  }

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  static double adaptiveFontSize(BuildContext context, double baseSize) {
    return value(
      context,
      mobile: baseSize,
      tablet: getTabletFontSize(baseSize),
      desktop: getDesktopFontSize(baseSize),
    );
  }

  static double adaptiveIconSize(BuildContext context, double baseSize) {
    return value(
      context,
      mobile: baseSize,
      tablet: getTabletIconSize(baseSize),
      desktop: getDesktopIconSize(baseSize),
    );
  }

  static double getTabletFontSize(double mobileSize) => mobileSize * 0.8;
  static double getDesktopFontSize(double mobileSize) => mobileSize * 0.3;

  static double getTabletIconSize(double mobileSize) => mobileSize * 0.8;
  static double getDesktopIconSize(double mobileSize) => mobileSize * 0.3;
}

extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveLayout.isMobile(this);
  bool get isTablet => ResponsiveLayout.isTablet(this);
  bool get isDesktop => ResponsiveLayout.isDesktop(this);
  bool get isLandscape => ResponsiveLayout.isLandscape(this);
  bool get isPortrait => ResponsiveLayout.isPortrait(this);

  T responsive<T>(T mobile, {T? tablet, T? desktop}) => ResponsiveLayout.value(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );

  double adaptiveFont(double base) =>
      ResponsiveLayout.adaptiveFontSize(this, base);
  double adaptiveIcon(double base) =>
      ResponsiveLayout.adaptiveIconSize(this, base);

  /// Helper for orientation based layout
  T orientation<T>({required T portrait, required T landscape}) =>
      isPortrait ? portrait : landscape;

  /// Smart check for rotation:
  /// Landscape on a phone often needs special handling compared to tablet landscape.
  bool get isPhoneLandscape => isMobile && isLandscape;

  /// Decide if we should show a sidebar based on width and orientation
  bool get shouldShowSideBar => isDesktop || (isTablet && isLandscape);

  /// A powerful helper that handles layout based on device AND orientation in one place
  T layout<T>({
    required T mobilePortrait,
    T? mobileLandscape,
    T? tabletPortrait,
    T? tabletLandscape,
    T? desktop,
  }) {
    if (isDesktop) {
      return desktop ??
          tabletLandscape ??
          tabletPortrait ??
          mobileLandscape ??
          mobilePortrait;
    }
    if (isTablet) {
      if (isLandscape) {
        return tabletLandscape ??
            tabletPortrait ??
            mobileLandscape ??
            mobilePortrait;
      }
      return tabletPortrait ?? mobilePortrait;
    }
    if (isLandscape) return mobileLandscape ?? mobilePortrait;
    return mobilePortrait;
  }

  /// Specialized helper for simple orientation switching
  T onOrientation<T>({required T portrait, required T landscape}) =>
      isPortrait ? portrait : landscape;
}
