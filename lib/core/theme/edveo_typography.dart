import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edveo_colors.dart';

abstract final class EdveoTypography {
  static TextStyle get logoWordmark => GoogleFonts.plusJakartaSans(
        fontSize: 17, fontWeight: FontWeight.w700,
        letterSpacing: -0.2, color: EdveoColors.textPrimary);

  static TextStyle get logoTagline => GoogleFonts.plusJakartaSans(
        fontSize: 11.5, fontWeight: FontWeight.w400,
        letterSpacing: 0.4, color: EdveoColors.textSecondary);

  static TextStyle get screenH1 => GoogleFonts.plusJakartaSans(
        fontSize: 24, fontWeight: FontWeight.w700,
        letterSpacing: -0.4, color: EdveoColors.textPrimary);

  static TextStyle get screenSub => GoogleFonts.plusJakartaSans(
        fontSize: 13.5, fontWeight: FontWeight.w400, color: EdveoColors.textSecondary);

  static TextStyle get sectionEyebrow => GoogleFonts.plusJakartaSans(
        fontSize: 11, fontWeight: FontWeight.w600,
        letterSpacing: 1.0, color: EdveoColors.textFaint);

  static TextStyle get inputValue => GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w400, color: EdveoColors.textPrimary);

  static TextStyle get inputPlaceholder => GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w400, color: EdveoColors.textSecondary);

  static TextStyle get cardTitle => GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w600, color: EdveoColors.textPrimary);

  static TextStyle get cardMeta => GoogleFonts.plusJakartaSans(
        fontSize: 12.5, fontWeight: FontWeight.w400, color: EdveoColors.textSecondary);

  static TextStyle get avatarInitials => GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: Colors.white);

  static TextStyle get footerText => GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w400, color: EdveoColors.textSecondary);

  static TextStyle get footerLink => GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w600, color: EdveoColors.textLink);
}
