import 'package:flutter/material.dart';

/// Defines how lane dividers are drawn.
enum DividerStyle { solid, dashed, glow, doubleLine }

/// Defines the shape style for car rendering.
enum CarBodyStyle { rounded, boxy, tapered, outlineOnly }

/// Defines the shape of exhaust/collection particles.
enum ParticleShape { circle, square }

class GameTheme {
  final String id;
  final String name;

  // ── Background ──
  final Color backgroundColor;

  // ── Lane ──
  final Color leftLaneTint;
  final Color rightLaneTint;
  final double laneTintOpacity;
  final Color laneDividerColor;
  final DividerStyle laneDividerStyle;
  final double laneDividerWidth;
  final Color centerDividerColor;
  final DividerStyle centerDividerStyle;
  final double centerDividerWidth;
  final bool hasScrollingLanes;
  final bool hasGridLines; // neon grid
  final Color? gridLineColor;
  final bool hasVignette;

  // ── Car ──
  final Color leftCarColor;
  final Color rightCarColor;
  final CarBodyStyle carBodyStyle;
  final double carStrokeWidth;
  final bool carHasGlow;
  final Color windshieldColor;
  final Color headlightColor;
  final bool hasWheels;
  final bool carHasShadow;
  final bool carHasGradient;

  // ── Objects ──
  final Color circleFillColor;
  final Color circleStrokeColor;
  final double circleStrokeWidth;
  final bool circleHasGlow;
  final bool circleIsFilled;
  final Color circleCenterColor;
  final Color squareFillColor;
  final Color squareStrokeColor;
  final double squareStrokeWidth;
  final bool squareHasGlow;
  final Color squareXColor;
  final double squareXStrokeWidth;
  final bool squareHasRotation;
  final double squareRotationDegrees;
  final bool objectHasShadow;

  // ── Particles ──
  final Color collectionParticleColor;
  final int collectionParticleCount;
  final double collectionParticleSize;
  final bool collectionHasTrails;
  final ParticleShape collectionParticleShape;
  final Color collisionParticleColor;
  final int collisionParticleCount;
  final double collisionParticleSize;
  final bool collisionHasGravity;
  final bool exhaustEnabled;
  final Color exhaustColor;
  final ParticleShape exhaustParticleShape;
  final bool speedLinesEnabled;
  final Color speedLineColor;
  final double speedLineWidth;

  // ── UI ──
  final Color overlayBackgroundColor;
  final double overlayOpacity;
  final bool overlayHasGradient;
  final Color? overlayGradientColor; // for radial/linear gradient
  final Color titleColor;
  final bool titleHasGlow;
  final bool titleHasOutline;
  final Color? titleOutlineColor;
  final double titleLetterSpacing;
  final Color buttonBackgroundColor;
  final Color buttonTextColor;
  final Color buttonBorderColor;
  final double buttonBorderWidth;
  final double buttonBorderRadius;
  final Color chipSelectedColor;
  final Color chipSelectedTextColor;
  final Color chipUnselectedColor;
  final Color chipUnselectedTextColor;
  final Color chipBorderColor;
  final double chipBorderWidth;
  final double chipBorderRadius;
  final Color scoreTextColor;
  final Color highScoreAccentColor;
  final Color secondaryTextColor;
  final bool textIsUppercase;
  final Color scorePopupColor;

  const GameTheme({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.leftLaneTint,
    required this.rightLaneTint,
    this.laneTintOpacity = 0.2,
    required this.laneDividerColor,
    this.laneDividerStyle = DividerStyle.solid,
    this.laneDividerWidth = 2,
    required this.centerDividerColor,
    this.centerDividerStyle = DividerStyle.solid,
    this.centerDividerWidth = 2,
    this.hasScrollingLanes = false,
    this.hasGridLines = false,
    this.gridLineColor,
    this.hasVignette = false,
    required this.leftCarColor,
    required this.rightCarColor,
    this.carBodyStyle = CarBodyStyle.rounded,
    this.carStrokeWidth = 0,
    this.carHasGlow = false,
    required this.windshieldColor,
    required this.headlightColor,
    this.hasWheels = false,
    this.carHasShadow = false,
    this.carHasGradient = false,
    required this.circleFillColor,
    required this.circleStrokeColor,
    this.circleStrokeWidth = 4,
    this.circleHasGlow = false,
    this.circleIsFilled = true,
    required this.circleCenterColor,
    required this.squareFillColor,
    required this.squareStrokeColor,
    this.squareStrokeWidth = 3,
    this.squareHasGlow = false,
    required this.squareXColor,
    this.squareXStrokeWidth = 4,
    this.squareHasRotation = false,
    this.squareRotationDegrees = 0,
    this.objectHasShadow = false,
    required this.collectionParticleColor,
    this.collectionParticleCount = 10,
    this.collectionParticleSize = 3,
    this.collectionHasTrails = false,
    this.collectionParticleShape = ParticleShape.circle,
    required this.collisionParticleColor,
    this.collisionParticleCount = 40,
    this.collisionParticleSize = 3,
    this.collisionHasGravity = false,
    this.exhaustEnabled = true,
    required this.exhaustColor,
    this.exhaustParticleShape = ParticleShape.circle,
    this.speedLinesEnabled = false,
    this.speedLineColor = Colors.white,
    this.speedLineWidth = 1,
    required this.overlayBackgroundColor,
    this.overlayOpacity = 0.85,
    this.overlayHasGradient = false,
    this.overlayGradientColor,
    required this.titleColor,
    this.titleHasGlow = false,
    this.titleHasOutline = false,
    this.titleOutlineColor,
    this.titleLetterSpacing = 4,
    required this.buttonBackgroundColor,
    required this.buttonTextColor,
    required this.buttonBorderColor,
    this.buttonBorderWidth = 0,
    this.buttonBorderRadius = 8,
    required this.chipSelectedColor,
    required this.chipSelectedTextColor,
    required this.chipUnselectedColor,
    required this.chipUnselectedTextColor,
    required this.chipBorderColor,
    this.chipBorderWidth = 1,
    this.chipBorderRadius = 8,
    required this.scoreTextColor,
    required this.highScoreAccentColor,
    required this.secondaryTextColor,
    this.textIsUppercase = false,
    required this.scorePopupColor,
  });

  // ════════════════════════════════════════════
  //  NEON / SYNTHWAVE
  // ════════════════════════════════════════════
  static const neon = GameTheme(
    id: 'neon',
    name: 'NEON',

    backgroundColor: Color(0xFF0A0A1A),

    leftLaneTint: Color(0xFF00FFFF),
    rightLaneTint: Color(0xFFFF00FF),
    laneTintOpacity: 0.06,
    laneDividerColor: Color(0xFF00FFFF),
    laneDividerStyle: DividerStyle.glow,
    laneDividerWidth: 1.5,
    centerDividerColor: Color(0xFFAA00FF),
    centerDividerStyle: DividerStyle.glow,
    centerDividerWidth: 2,
    hasScrollingLanes: true,
    hasGridLines: true,
    gridLineColor: Color(0xFF1A1A3A),
    hasVignette: false,

    leftCarColor: Color(0xFF00FFFF),
    rightCarColor: Color(0xFFFF00FF),
    carBodyStyle: CarBodyStyle.outlineOnly,
    carStrokeWidth: 2.5,
    carHasGlow: true,
    windshieldColor: Color(0xFF66FFFF),
    headlightColor: Color(0xFFFFFFFF),
    hasWheels: false,
    carHasShadow: false,
    carHasGradient: false,

    circleFillColor: Color(0xFF00FF88),
    circleStrokeColor: Color(0xFF00FF88),
    circleStrokeWidth: 3,
    circleHasGlow: true,
    circleIsFilled: false,
    circleCenterColor: Color(0xFFFFFFFF),
    squareFillColor: Color(0xFFFF4400),
    squareStrokeColor: Color(0xFFFF6600),
    squareStrokeWidth: 3,
    squareHasGlow: true,
    squareXColor: Color(0xFFFF6600),
    squareXStrokeWidth: 3,
    squareHasRotation: false,
    squareRotationDegrees: 0,
    objectHasShadow: false,

    collectionParticleColor: Color(0xFF00FF88),
    collectionParticleCount: 12,
    collectionParticleSize: 2.5,
    collectionHasTrails: true,
    collectionParticleShape: ParticleShape.circle,
    collisionParticleColor: Color(0xFFFF4400),
    collisionParticleCount: 45,
    collisionParticleSize: 2.5,
    collisionHasGravity: false,
    exhaustEnabled: true,
    exhaustColor: Color(0xFF00FFFF),
    exhaustParticleShape: ParticleShape.circle,
    speedLinesEnabled: true,
    speedLineColor: Color(0xFF00FFFF),
    speedLineWidth: 1.5,

    overlayBackgroundColor: Color(0xFF0A0A1A),
    overlayOpacity: 0.95,
    overlayHasGradient: true,
    overlayGradientColor: Color(0xFF2A0040),
    titleColor: Color(0xFFFF00AA),
    titleHasGlow: true,
    titleHasOutline: false,
    titleLetterSpacing: 8,
    buttonBackgroundColor: Colors.transparent,
    buttonTextColor: Color(0xFFFFFFFF),
    buttonBorderColor: Color(0xFF00FFFF),
    buttonBorderWidth: 2,
    buttonBorderRadius: 4,
    chipSelectedColor: Color(0xFF00FFFF),
    chipSelectedTextColor: Color(0xFF0A0A1A),
    chipUnselectedColor: Colors.transparent,
    chipUnselectedTextColor: Color(0xFF00FFFF),
    chipBorderColor: Color(0xFF00FFFF),
    chipBorderWidth: 1.5,
    chipBorderRadius: 4,
    scoreTextColor: Color(0xFF00FF88),
    highScoreAccentColor: Color(0xFF00FFFF),
    secondaryTextColor: Color(0xFF00FFFF),
    textIsUppercase: false,
    scorePopupColor: Color(0xFF00FF88),
  );

  // ════════════════════════════════════════════
  //  FLAT MODERN
  // ════════════════════════════════════════════
  static const flatModern = GameTheme(
    id: 'flat_modern',
    name: 'MODERN',

    backgroundColor: Color(0xFFF5F5F5),

    leftLaneTint: Color(0xFFFF6B6B),
    rightLaneTint: Color(0xFF4ECDC4),
    laneTintOpacity: 0.12,
    laneDividerColor: Color(0xFFBDBDBD),
    laneDividerStyle: DividerStyle.solid,
    laneDividerWidth: 1.5,
    centerDividerColor: Color(0xFF9E9E9E),
    centerDividerStyle: DividerStyle.solid,
    centerDividerWidth: 2,
    hasScrollingLanes: false,
    hasGridLines: false,
    hasVignette: false,

    leftCarColor: Color(0xFFFF6B6B),
    rightCarColor: Color(0xFF4ECDC4),
    carBodyStyle: CarBodyStyle.rounded,
    carStrokeWidth: 0,
    carHasGlow: false,
    windshieldColor: Color(0xFF333333),
    headlightColor: Color(0xFFFFFFFF),
    hasWheels: false,
    carHasShadow: false,
    carHasGradient: false,

    circleFillColor: Color(0xFF2ECC71),
    circleStrokeColor: Color(0xFF2ECC71),
    circleStrokeWidth: 0,
    circleHasGlow: false,
    circleIsFilled: true,
    circleCenterColor: Color(0xFFFFFFFF),
    squareFillColor: Color(0xFFE74C3C),
    squareStrokeColor: Color(0xFFE74C3C),
    squareStrokeWidth: 0,
    squareHasGlow: false,
    squareXColor: Color(0xFFFFFFFF),
    squareXStrokeWidth: 3.5,
    squareHasRotation: false,
    squareRotationDegrees: 0,
    objectHasShadow: false,

    collectionParticleColor: Color(0xFF2ECC71),
    collectionParticleCount: 8,
    collectionParticleSize: 3,
    collectionHasTrails: false,
    collectionParticleShape: ParticleShape.square,
    collisionParticleColor: Color(0xFF9E9E9E),
    collisionParticleCount: 20,
    collisionParticleSize: 3,
    collisionHasGravity: false,
    exhaustEnabled: false,
    exhaustColor: Colors.transparent,
    exhaustParticleShape: ParticleShape.circle,
    speedLinesEnabled: true,
    speedLineColor: Color(0xFFBDBDBD),
    speedLineWidth: 0.5,

    overlayBackgroundColor: Color(0xFFFFFFFF),
    overlayOpacity: 0.95,
    overlayHasGradient: false,
    titleColor: Color(0xFF212121),
    titleHasGlow: false,
    titleHasOutline: false,
    titleLetterSpacing: 4,
    buttonBackgroundColor: Color(0xFFFF6B6B),
    buttonTextColor: Color(0xFFFFFFFF),
    buttonBorderColor: Colors.transparent,
    buttonBorderWidth: 0,
    buttonBorderRadius: 12,
    chipSelectedColor: Color(0xFF4ECDC4),
    chipSelectedTextColor: Color(0xFFFFFFFF),
    chipUnselectedColor: Color(0xFFEEEEEE),
    chipUnselectedTextColor: Color(0xFF757575),
    chipBorderColor: Colors.transparent,
    chipBorderWidth: 0,
    chipBorderRadius: 20,
    scoreTextColor: Color(0xFF212121),
    highScoreAccentColor: Color(0xFFFF6B6B),
    secondaryTextColor: Color(0xFF757575),
    textIsUppercase: false,
    scorePopupColor: Color(0xFF4ECDC4),
  );

  // ════════════════════════════════════════════
  //  RETRO PIXEL-ISH
  // ════════════════════════════════════════════
  static const retro = GameTheme(
    id: 'retro',
    name: 'RETRO',

    backgroundColor: Color(0xFF0D1B2A),

    leftLaneTint: Color(0xFFCC0000),
    rightLaneTint: Color(0xFF0044CC),
    laneTintOpacity: 0.2,
    laneDividerColor: Color(0xFFFFFFFF),
    laneDividerStyle: DividerStyle.dashed,
    laneDividerWidth: 3,
    centerDividerColor: Color(0xFFFFFFFF),
    centerDividerStyle: DividerStyle.doubleLine,
    centerDividerWidth: 3,
    hasScrollingLanes: true,
    hasGridLines: false,
    hasVignette: false,

    leftCarColor: Color(0xFFFF0000),
    rightCarColor: Color(0xFF0066FF),
    carBodyStyle: CarBodyStyle.boxy,
    carStrokeWidth: 3,
    carHasGlow: false,
    windshieldColor: Color(0xFF88CCFF),
    headlightColor: Color(0xFFFFFF00),
    hasWheels: true,
    carHasShadow: false,
    carHasGradient: false,

    circleFillColor: Color(0xFFFFDD00),
    circleStrokeColor: Color(0xFF000000),
    circleStrokeWidth: 3,
    circleHasGlow: false,
    circleIsFilled: true,
    circleCenterColor: Color(0xFF000000),
    squareFillColor: Color(0xFFFF0000),
    squareStrokeColor: Color(0xFF000000),
    squareStrokeWidth: 3,
    squareHasGlow: false,
    squareXColor: Color(0xFF000000),
    squareXStrokeWidth: 5,
    squareHasRotation: true,
    squareRotationDegrees: 8,
    objectHasShadow: false,

    collectionParticleColor: Color(0xFFFFDD00),
    collectionParticleCount: 6,
    collectionParticleSize: 5,
    collectionHasTrails: false,
    collectionParticleShape: ParticleShape.square,
    collisionParticleColor: Color(0xFFFF4400),
    collisionParticleCount: 15,
    collisionParticleSize: 6,
    collisionHasGravity: false,
    exhaustEnabled: true,
    exhaustColor: Color(0xFFCCCCCC),
    exhaustParticleShape: ParticleShape.square,
    speedLinesEnabled: true,
    speedLineColor: Color(0xFFFFFFFF),
    speedLineWidth: 3,

    overlayBackgroundColor: Color(0xFF0D1B2A),
    overlayOpacity: 0.95,
    overlayHasGradient: false,
    titleColor: Color(0xFFFFDD00),
    titleHasGlow: false,
    titleHasOutline: true,
    titleOutlineColor: Color(0xFF000000),
    titleLetterSpacing: 6,
    buttonBackgroundColor: Color(0xFFFFDD00),
    buttonTextColor: Color(0xFF000000),
    buttonBorderColor: Color(0xFF000000),
    buttonBorderWidth: 3,
    buttonBorderRadius: 0,
    chipSelectedColor: Color(0xFFFFDD00),
    chipSelectedTextColor: Color(0xFF000000),
    chipUnselectedColor: Color(0xFF1B2838),
    chipUnselectedTextColor: Color(0xFFFFFFFF),
    chipBorderColor: Color(0xFFFFFFFF),
    chipBorderWidth: 2,
    chipBorderRadius: 0,
    scoreTextColor: Color(0xFFFFFFFF),
    highScoreAccentColor: Color(0xFFFFDD00),
    secondaryTextColor: Color(0xFFCCCCCC),
    textIsUppercase: true,
    scorePopupColor: Color(0xFFFFDD00),
  );

  // ════════════════════════════════════════════
  //  REALISTIC-LITE
  // ════════════════════════════════════════════
  static const realistic = GameTheme(
    id: 'realistic',
    name: 'REALISTIC',

    backgroundColor: Color(0xFF1A1A1A),

    leftLaneTint: Color(0xFF2A2A2A),
    rightLaneTint: Color(0xFF2A2A2A),
    laneTintOpacity: 0.5,
    laneDividerColor: Color(0xFFFFFFFF),
    laneDividerStyle: DividerStyle.dashed,
    laneDividerWidth: 2,
    centerDividerColor: Color(0xFFFFCC00),
    centerDividerStyle: DividerStyle.doubleLine,
    centerDividerWidth: 2,
    hasScrollingLanes: true,
    hasGridLines: false,
    hasVignette: true,

    leftCarColor: Color(0xFFC0392B),
    rightCarColor: Color(0xFF2980B9),
    carBodyStyle: CarBodyStyle.tapered,
    carStrokeWidth: 0,
    carHasGlow: false,
    windshieldColor: Color(0xFF555555),
    headlightColor: Color(0xFFFFEE88),
    hasWheels: true,
    carHasShadow: true,
    carHasGradient: true,

    circleFillColor: Color(0xFFFFD700),
    circleStrokeColor: Color(0xFFDAA520),
    circleStrokeWidth: 0,
    circleHasGlow: false,
    circleIsFilled: true,
    circleCenterColor: Color(0xFFFFFFFF),
    squareFillColor: Color(0xFF8B0000),
    squareStrokeColor: Color(0xFF555555),
    squareStrokeWidth: 1.5,
    squareHasGlow: false,
    squareXColor: Color(0xFFCCCCCC),
    squareXStrokeWidth: 4,
    squareHasRotation: false,
    squareRotationDegrees: 0,
    objectHasShadow: true,

    collectionParticleColor: Color(0xFFFFD700),
    collectionParticleCount: 12,
    collectionParticleSize: 2.5,
    collectionHasTrails: false,
    collectionParticleShape: ParticleShape.circle,
    collisionParticleColor: Color(0xFFFF6600),
    collisionParticleCount: 35,
    collisionParticleSize: 3,
    collisionHasGravity: true,
    exhaustEnabled: true,
    exhaustColor: Color(0xFF888888),
    exhaustParticleShape: ParticleShape.circle,
    speedLinesEnabled: true,
    speedLineColor: Color(0xFF666666),
    speedLineWidth: 0.8,

    overlayBackgroundColor: Color(0xFF1A1A1A),
    overlayOpacity: 0.92,
    overlayHasGradient: true,
    overlayGradientColor: Color(0xFF2A2A2A),
    titleColor: Color(0xFFEEEEEE),
    titleHasGlow: false,
    titleHasOutline: false,
    titleLetterSpacing: 4,
    buttonBackgroundColor: Color(0xFF333333),
    buttonTextColor: Color(0xFFEEEEEE),
    buttonBorderColor: Color(0xFF555555),
    buttonBorderWidth: 1,
    buttonBorderRadius: 10,
    chipSelectedColor: Color(0xFF555555),
    chipSelectedTextColor: Color(0xFFFFFFFF),
    chipUnselectedColor: Color(0xFF2A2A2A),
    chipUnselectedTextColor: Color(0xFFAAAAAA),
    chipBorderColor: Color(0xFF444444),
    chipBorderWidth: 1,
    chipBorderRadius: 8,
    scoreTextColor: Color(0xFFFFF8DC),
    highScoreAccentColor: Color(0xFFFFD700),
    secondaryTextColor: Color(0xFFAAAAAA),
    textIsUppercase: false,
    scorePopupColor: Color(0xFFFFD700),
  );

  /// All available themes, ordered for cycling.
  static const List<GameTheme> all = [neon, flatModern, retro, realistic];

  /// Find a theme by its persisted id.
  static GameTheme fromId(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => neon);
  }
}
