/// Responsive Design Utilities
///
/// Provides breakpoints, sizing, and layout utilities for all device sizes
library;

import 'package:flutter/material.dart';

/// Device breakpoints
class Breakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double widescreen = 1440;

  Breakpoints._();
}

/// Device type enumeration
enum DeviceType { mobile, tablet, desktop }

/// Extension on BuildContext for responsive utilities
extension ResponsiveContext on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get safe area padding
  EdgeInsets get safePadding => MediaQuery.of(this).padding;

  /// Check if device is mobile
  bool get isMobile => screenWidth < Breakpoints.tablet;

  /// Check if device is tablet
  bool get isTablet =>
      screenWidth >= Breakpoints.tablet && screenWidth < Breakpoints.desktop;

  /// Check if device is desktop
  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  /// Get device type
  DeviceType get deviceType {
    if (isMobile) return DeviceType.mobile;
    if (isTablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Check if landscape orientation
  bool get isLandscape => screenWidth > screenHeight;

  /// Check if portrait orientation
  bool get isPortrait => screenHeight > screenWidth;

  /// Get responsive value based on device type
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Get scaled font size
  double scaledFont(double size) {
    final scale = screenWidth / 375; // Base on iPhone 8 width
    return (size * scale).clamp(size * 0.8, size * 1.3);
  }

  /// Get scaled spacing
  double scaledSpacing(double size) {
    if (isMobile) return size;
    if (isTablet) return size * 1.2;
    return size * 1.5;
  }

  /// Get content max width (for centered layouts on large screens)
  double get contentMaxWidth {
    if (isMobile) return screenWidth;
    if (isTablet) return 600;
    return 800;
  }

  /// Get card size for games
  Size get cardSize {
    if (screenWidth < 360) return const Size(50, 75);
    if (isMobile) return const Size(60, 90);
    if (isTablet) return const Size(70, 105);
    return const Size(80, 120);
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context, context.deviceType);
  }
}

/// Responsive layout with different widgets for each device type
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
    if (context.isDesktop && desktop != null) return desktop!;
    if (context.isTablet && tablet != null) return tablet!;
    return mobile;
  }
}

/// Centered content with max width for large screens
class CenteredContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const CenteredContent({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Responsive grid that adjusts columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    final columns = context.responsive(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      children: children,
    );
  }
}

/// Adaptive padding that scales with screen size
class AdaptivePadding extends StatelessWidget {
  final Widget child;
  final double horizontal;
  final double vertical;

  const AdaptivePadding({
    super.key,
    required this.child,
    this.horizontal = 16,
    this.vertical = 16,
  });

  @override
  Widget build(BuildContext context) {
    final hPadding = context.scaledSpacing(horizontal);
    final vPadding = context.scaledSpacing(vertical);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      child: child,
    );
  }
}

/// Safe area wrapper with optional padding
class SafeScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool useSafeArea;

  const SafeScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: useSafeArea ? SafeArea(child: body) : body,
    );
  }
}

/// Flexible card that adapts to screen size
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = context.responsive<EdgeInsets>(
      mobile: const EdgeInsets.all(12),
      tablet: const EdgeInsets.all(16),
      desktop: const EdgeInsets.all(20),
    );

    final defaultMargin = context.responsive<EdgeInsets>(
      mobile: const EdgeInsets.all(8),
      tablet: const EdgeInsets.all(12),
      desktop: const EdgeInsets.all(16),
    );

    return Card(
      margin: margin ?? defaultMargin,
      child: Padding(padding: padding ?? defaultPadding, child: child),
    );
  }
}
