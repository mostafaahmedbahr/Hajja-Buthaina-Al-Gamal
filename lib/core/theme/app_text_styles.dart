import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// خطوط النصوص: Cairo بكل الواجهة (نفس خط هوية «نبض العطاء») —
/// مع أوزان بولد كبيرة لعناصر الهوية ووضوح ممتاز من مسافة بعيدة.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle mosqueTitle = GoogleFonts.cairo(
    fontWeight: FontWeight.w800,
    fontSize: 30,
    color: AppColors.gold,
    height: 1.15,
  );

  static TextStyle mosqueSubtitle = GoogleFonts.cairo(
    fontSize: 14,
    color: AppColors.muted,
    letterSpacing: .3,
  );

  static TextStyle clockTime = GoogleFonts.cairo(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.ivory,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle clockMeridiem = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.ember,
  );

  static TextStyle dateGregorian = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
  );

  static TextStyle dateHijri = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.goldSoft,
  );

  static TextStyle domeLabel = GoogleFonts.cairo(
    fontSize: 13,
    color: AppColors.muted,
    letterSpacing: 1,
  );

  static TextStyle domePrayerName = GoogleFonts.cairo(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.goldSoft,
  );

  static TextStyle domeCountdown = GoogleFonts.cairo(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.ivory,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle domeTargetTime = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
  );

  static TextStyle cardPrayerName = GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.goldSoft,
  );

  static TextStyle cardPrayerTime = GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.ivory,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle cardIqama = GoogleFonts.cairo(
    fontSize: 11,
    color: AppColors.muted,
  );

  static TextStyle tickerText = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.goldSoft,
  );
  static TextStyle tickerText18 = GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.goldSoft,
  );

  static TextStyle bodyMedium = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.gold,
  );

  static TextStyle azkarLarge = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.ivory,
    height: 1.6,
  );

  static TextStyle o = GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.goldSoft,
    fontStyle: FontStyle.italic,
  );

  static TextStyle buttonLarge = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
}