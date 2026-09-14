import 'package:flutter/material.dart';

/// نظام الألوان — بهوية «نبض العطاء» (بنفسجي) المستمدة من ألوان المؤسسة:
/// البنفسجي الأساسي #5B2C82 ومشتقاته، مع خلفية ليلية بنفسجية عميقة.
class AppColors {
  AppColors._();

  static const Color bgDeep = Color(0xFF0A0818);
  static const Color bgPanel = Color(0xFF151139);
  static const Color bgPanel2 = Color(0xFF1E1850);

  // بنفسج «نبض العطاء» بدرجاتها: أساسي / فاتح / متوسط
  static const Color nabadPrimary = Color(0xFF5B2C82);
  static const Color nabadPrimaryLight = Color(0xFF9D7BEB);
  static const Color nabadSoft = Color(0xFFCBAFFF);

  static const Color gold = Color(0xFF9D7BEB); // البنفسجي الفاتح المميز
  static const Color goldSoft = Color(0xFFCBAFFF);
  static const Color ember = Color(0xFF4C1D95); // بنفسجي عميق للتدرجات والقوة
  static const Color ivory = Color(0xFFF4F0FF);
  static const Color muted = Color(0xFF9C93C4);
  static const Color line = Color(0x3C9D7BEB); // accent بشفافية 22%

  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgPanel, bgPanel2],
  );

  static const LinearGradient activeCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF272159), Color(0xFF1B1741)],
  );

  static const LinearGradient domeFillGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [ember, gold, goldSoft],
  );
}