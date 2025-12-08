// Responsive Breakpoints
//
// Defines responsive breakpoints and provides utilities for
// responsive layouts across mobile, tablet, and desktop.

import 'package:flutter/material.dart';

/// Responsive breakpoint values
class Breakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1440;
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
  wide,
}

/// Responsive utility class
class Responsive {
  /// Get current device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < Breakpoints.mobile) return DeviceType.mobile;
    if (width < Breakpoints.tablet) return DeviceType.tablet;
    if (width < Breakpoints.desktop) return DeviceType.desktop;
    return DeviceType.wide;
  }

  /// Check if current device is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.tablet;

  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.tablet && width < Breakpoints.desktop;
  }

  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.desktop;

  /// Check if device has touch input
  static bool hasTouch(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.desktop;

  /// Get number of columns for grid layouts
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < Breakpoints.mobile) return 1;
    if (width < Breakpoints.tablet) return 2;
    if (width < Breakpoints.desktop) return 3;
    return 4;
  }

  /// Get padding based on screen size
  static EdgeInsets getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < Breakpoints.mobile) {
      return const EdgeInsets.all(12);
    } else if (width < Breakpoints.tablet) {
      return const EdgeInsets.all(16);
    } else if (width < Breakpoints.desktop) {
      return const EdgeInsets.all(24);
    }
    return const EdgeInsets.all(32);
  }

  /// Get max content width for centered layouts
  static double getMaxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 720;
      case DeviceType.desktop:
        return 960;
      case DeviceType.wide:
        return 1200;
    }
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.getDeviceType(context);
    
    // Use specific widgets if provided
    if (deviceType == DeviceType.mobile && mobile != null) return mobile!;
    if ((deviceType == DeviceType.tablet) && tablet != null) return tablet!;
    if ((deviceType == DeviceType.desktop || deviceType == DeviceType.wide) && desktop != null) {
      return desktop!;
    }
    
    // Fall back to builder
    return builder(context, deviceType);
  }
}

/// Responsive layout that switches between layouts
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
      case DeviceType.wide:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive visibility widget
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool visibleOnMobile;
  final bool visibleOnTablet;
  final bool visibleOnDesktop;
  final Widget replacement;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
    this.replacement = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.getDeviceType(context);
    
    final isVisible = switch (deviceType) {
      DeviceType.mobile => visibleOnMobile,
      DeviceType.tablet => visibleOnTablet,
      DeviceType.desktop || DeviceType.wide => visibleOnDesktop,
    };
    
    return isVisible ? child : replacement;
  }
}

/// Centered content container with max width
class CenteredContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const CenteredContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.getMaxContentWidth(context),
        ),
        padding: padding ?? Responsive.getPadding(context),
        child: child,
      ),
    );
  }
}

/// Game table layout that adapts to screen size
class ResponsiveGameTable extends StatelessWidget {
  final Widget gameBoard;
  final Widget playerHand;
  final Widget? sidebar; // Scores, chat
  final Widget? topBar; // Timer, room info

  const ResponsiveGameTable({
    super.key,
    required this.gameBoard,
    required this.playerHand,
    this.sidebar,
    this.topBar,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    if (isDesktop && sidebar != null) {
      // Desktop: sidebar layout
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                if (topBar != null) topBar!,
                Expanded(child: gameBoard),
                playerHand,
              ],
            ),
          ),
          SizedBox(
            width: 320,
            child: sidebar!,
          ),
        ],
      );
    }

    // Mobile/Tablet: stacked layout
    return Column(
      children: [
        if (topBar != null) topBar!,
        Expanded(child: gameBoard),
        playerHand,
      ],
    );
  }
}
