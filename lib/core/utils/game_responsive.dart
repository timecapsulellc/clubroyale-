/// Responsive Layout Service for Marriage Game
///
/// Provides responsive sizing calculations based on screen dimensions
/// Ensures consistent UI across mobile, tablet, and desktop
library;

import 'package:flutter/material.dart';

/// Responsive layout breakpoints and calculations
class GameResponsive {
  final BuildContext context;
  late final MediaQueryData _mq;
  
  GameResponsive(this.context) {
    _mq = MediaQuery.of(context);
  }
  
  // Screen dimensions
  double get screenWidth => _mq.size.width;
  double get screenHeight => _mq.size.height;
  double get pixelRatio => _mq.devicePixelRatio;
  double get safeBottom => _mq.padding.bottom;
  double get safeTop => _mq.padding.top;
  
  // Device type detection
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;
  bool get isLandscape => screenWidth > screenHeight;
  bool get isSmallHeight => screenHeight < 500;
  bool get isTinyHeight => screenHeight < 400;
  
  // Card Dimensions (Responsive)
  double get cardWidth {
    if (isTinyHeight) return 40;
    if (isSmallHeight) return 48;
    if (isMobile) return screenWidth * 0.12;
    if (isTablet) return screenWidth * 0.08;
    return 80; // Desktop max
  }
  
  double get cardHeight => cardWidth * 1.4; // Maintain standard card aspect ratio
  
  // Hand card sizing (slightly larger for player's own hand)
  double get handCardWidth {
    if (isTinyHeight) return 45;
    if (isSmallHeight) return 55;
    if (isMobile) return screenWidth * 0.14;
    if (isTablet) return screenWidth * 0.10;
    return 100;
  }
  
  double get handCardHeight => handCardWidth * 1.4;
  
  // Center area deck/discard cards
  double get centerCardWidth {
    if (isTinyHeight) return 55;
    if (isSmallHeight) return 70;
    if (isMobile) return 90;
    if (isTablet) return 100;
    return 120;
  }
  
  double get centerCardHeight => centerCardWidth * 1.44;
  
  // Touch Targets (Minimum 48×48 per accessibility guidelines)
  double get minTouchTarget => 48.0;
  
  // Button Sizes
  double get circularButtonSize {
    if (isTinyHeight) return 36;
    if (isSmallHeight) return 44;
    if (isMobile) return 56;
    return 64;
  }
  
  double get primaryButtonHeight => isSmallHeight ? 40 : 52;
  
  // Spacing
  double get cardOverlap => handCardWidth * 0.55; // 55% overlap in fan
  double get cardSpacing => isSmallHeight ? 4 : 8;
  double get sectionPadding => isSmallHeight ? 8 : 16;
  
  // Player Hand Positioning
  double get playerHandBottom {
    if (isTinyHeight) return safeBottom + 60;
    if (isSmallHeight) return safeBottom + 100;
    if (isMobile) return safeBottom + 120;
    return safeBottom + 140;
  }
  
  // Height allocation for hand area
  double get handAreaHeight {
    if (isTinyHeight) return 80;
    if (isSmallHeight) return 120;
    if (isMobile) return 160;
    return 180;
  }
  
  // Opponent Display
  double get opponentAvatarSize {
    if (isTinyHeight) return 32;
    if (isSmallHeight) return 40;
    if (isMobile) return 48;
    return 60;
  }
  
  double get opponentCardSize => cardWidth * 0.7; // Smaller than player's
  
  // Font sizes
  double get titleFontSize => isSmallHeight ? 14 : 18;
  double get bodyFontSize => isSmallHeight ? 10 : 12;
  double get captionFontSize => isSmallHeight ? 8 : 10;
  
  // Maximum opponents per row
  int get maxOpponentsPerRow {
    if (screenWidth < 450) return 3;
    if (screenWidth < 700) return 4;
    if (screenWidth < 1000) return 5;
    return 7;
  }
  
  // Action sidebar width
  double get sidebarWidth {
    if (isTinyHeight) return 50;
    if (isSmallHeight) return 60;
    return 76;
  }
  
  // Game log width
  double get gameLogWidth {
    if (isMobile) return 160;
    if (isTablet) return 200;
    return 240;
  }
  
  // Whether to show certain elements
  bool get showMeldSuggestions => screenHeight >= 500;
  bool get showPrimarySetsProgress => screenHeight >= 450;
  bool get showFullOpponentInfo => screenWidth >= 600;
  
  // Helper method for responsive value
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }
  
  // Scale factor for overall UI
  double get uiScale {
    if (isTinyHeight) return 0.65;
    if (isSmallHeight) return 0.8;
    if (isMobile) return 0.9;
    return 1.0;
  }
}

/// Extension to easily access responsive values
extension ResponsiveContext on BuildContext {
  GameResponsive get responsive => GameResponsive(this);
}

/// Constants for z-index layering (higher = in front)
class GameZIndex {
  static const int background = 0;
  static const int table = 1;
  static const int opponentSets = 2;
  static const int centerArea = 3;
  static const int opponentCards = 4;
  static const int gameLogMinimized = 5;
  static const int meldSuggestions = 8;
  static const int playerCards = 10;
  static const int actionButtons = 11;
  static const int turnIndicator = 12;
  static const int jokerPanel = 13;
  static const int gameLogExpanded = 15;
  static const int toasts = 20;
  static const int loadingOverlay = 25;
  static const int modals = 30;
  static const int tutorial = 40;
}
