import 'package:flutter/material.dart';

abstract final class EdveoMetrics {
  static const double pageSidePadding = 20.0;
  static const double statusBarSafeTop = 50.0;
  static const double headerBottomGap = 12.0;
  static const double h1BlockTop = 24.0;
  static const double sectionGapSmall = 8.0;
  static const double sectionGapMedium = 16.0;
  static const double resultCardGap = 10.0;
  static const double footerBottom = 28.0;
  static const double minTouchTarget = 44.0;
  static const double searchInputHeight = 50.0;
  static const double resultCardHeight = 66.0;
  static const double avatarSize = 42.0;
  static const double radiusCard = 14.0;
  static const double radiusAvatar = 999.0;
  static const double borderIdle = 1.0;
  static const double borderFocused = 1.5;
  static const double focusRingWidth = 4.0;

  static const BoxShadow topResultShadow = BoxShadow(
    color: Color(0x0A111827),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const Duration resultMountDuration = Duration(milliseconds: 160);
  static const Duration resultMountStagger = Duration(milliseconds: 30);
  static const Duration focusTransitionDuration = Duration(milliseconds: 120);
  static const Curve resultMountCurve = Curves.easeOut;
}
