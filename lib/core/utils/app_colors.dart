import 'package:flutter/material.dart';

class AppColors {
  // Palette de couleurs principale
  static const Color primaryBlack = Color(0xFF141414);
  static const Color secondaryBeige = Color(0xFFF7F0EB);
  static const Color accentOrange = Color(0xFFFF5A1A);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Variations pour les interfaces
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningYellow = Color(0xFFFF9800);

  // background colors
  static const Color backgroundBeige = Color(0xFFF7F0EB);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundBlack = Color(0xFF141414);

  // Couleurs pour les éléments d'interface
  static const Color cardBackground = secondaryBeige;
  static const Color buttonPrimary = accentOrange;
  static const Color buttonSecondary = primaryBlack;
  static const Color textPrimary = primaryBlack;
  static const Color textSecondary = Color(0xFF666666);
  static const Color background = pureWhite;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentOrange, Color(0xFFE55D3A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successGreen, Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
