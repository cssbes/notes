import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color accent = Color(0xFF007AFF);
  static const Color accentLight = Color(0xFF4DA3FF);
  static const Color accentDark = Color(0xFF0055CC);

  static const Color favorite = Color(0xFFFF9500);
  static const Color pinned = Color(0xFF34C759);
  static const Color archived = Color(0xFF8E8E93);
  static const Color deleted = Color(0xFFFF3B30);
  static const Color tagPurple = Color(0xFFAF52DE);
  static const Color tagGreen = Color(0xFF34C759);
  static const Color tagOrange = Color(0xFFFF9500);
  static const Color tagTeal = Color(0xFF5AC8FA);

  static const List<Color> tagColors = [
    accent,
    tagGreen,
    tagOrange,
    deleted,
    tagPurple,
    tagTeal,
    Color(0xFFFF2D55),
    Color(0xFF5856D6),
  ];

  static const Color lightBackground = Color(0xFFF2F4F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFE8ECF0);
  static const Color lightDivider = Color(0xFFD1D5DB);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2E);
  static const Color darkDivider = Color(0xFF38383A);

  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF0A0A0A);
  static const Color amoledCard = Color(0xFF141414);
}
