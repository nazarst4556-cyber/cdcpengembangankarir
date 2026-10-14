import 'package:flutter/material.dart';

/// ══════════════════════════════════════════════════════════════════
/// RESPONSIVE BREAKPOINT & DEVICE UTILITY ENGINE
/// Tailored for Mobile (iOS/Android), iPad/Tablet, Windows/Mac Desktop
/// ══════════════════════════════════════════════════════════════════

enum DeviceScreenType {
  mobileCompact, // < 380px (iPhone SE, compact Androids)
  mobile,        // 380px - 650px (iPhone 13/14/15/16 Pro, Galaxy S-series)
  tablet,        // 650px - 1024px (iPad, iPad Mini, iPad Air, Galaxy Tab)
  desktop,       // 1024px - 1440px (Windows PC, MacBooks, 1080p displays)
  ultraWide,     // > 1440px (Ultrawide monitors, 4K displays)
}

class Responsive {
  static const double compactMobileBreakpoint = 380.0;
  static const double mobileBreakpoint = 650.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;

  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < compactMobileBreakpoint) return DeviceScreenType.mobileCompact;
    if (width < mobileBreakpoint) return DeviceScreenType.mobile;
    if (width < tabletBreakpoint) return DeviceScreenType.tablet;
    if (width < desktopBreakpoint) return DeviceScreenType.desktop;
    return DeviceScreenType.ultraWide;
  }

  static bool isCompactMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < compactMobileBreakpoint;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static bool isUltraWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  /// Helper to get a responsive value based on current device type
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? mobileCompact,
    T? tablet,
    T? desktop,
    T? ultraWide,
  }) {
    final device = getDeviceType(context);
    switch (device) {
      case DeviceScreenType.mobileCompact:
        return mobileCompact ?? mobile;
      case DeviceScreenType.mobile:
        return mobile;
      case DeviceScreenType.tablet:
        return tablet ?? desktop ?? mobile;
      case DeviceScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceScreenType.ultraWide:
        return ultraWide ?? desktop ?? tablet ?? mobile;
    }
  }

  /// Responsive page padding
  static EdgeInsets pagePadding(BuildContext context) {
    return value<EdgeInsets>(
      context,
      mobileCompact: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      tablet: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      desktop: const EdgeInsets.symmetric(horizontal: 56, vertical: 32),
      ultraWide: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
    );
  }
}

/// Extension on BuildContext for quick access to responsive properties
extension ResponsiveContext on BuildContext {
  DeviceScreenType get deviceType => Responsive.getDeviceType(this);
  bool get isMobileCompact => Responsive.isCompactMobile(this);
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  bool get isUltraWide => Responsive.isUltraWide(this);

  T responsive<T>({
    required T mobile,
    T? mobileCompact,
    T? tablet,
    T? desktop,
    T? ultraWide,
  }) {
    return Responsive.value<T>(
      this,
      mobile: mobile,
      mobileCompact: mobileCompact,
      tablet: tablet,
      desktop: desktop,
      ultraWide: ultraWide,
    );
  }
}

/// Container that centers content and limits max width on desktop/ultrawide
class ResponsiveCenterContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenterContainer({
    super.key,
    required this.child,
    this.maxWidth = 1320.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
