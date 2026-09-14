import 'package:flutter/material.dart';

/// نظام الألوان — بهوية «نبض العطاء» الأخضر فقط (من Secondary في اللوجو):
/// خلفيات ليلية خضراء، والتوهج/التمييز/القوس كلها بدرجات الأخضر.
class AppColors {
  AppColors._();

  // ─── ألوان الهوية الرسمية من اللوجو ───
  static const Color primary = Color(0xFF5B2C82);
  static const Color primaryLight = Color(0xFF7B4CA2);
  static const Color primaryDark = Color(0xFF3A1259);
  static const Color primarySurface = Color(0xFFF3EDF7);

  // الأخضر — هوية الساعة الكاملة
  static const Color secondary = Color(0xFF7CB342);
  static const Color secondaryLight = Color(0xFFAED581);
  static const Color secondaryDark = Color(0xFF558B2F);

  // الكريمي — للدفء والنصوص الفاتحة
  static const Color accent = Color(0xFFF5E6C8);
  static const Color accentLight = Color(0xFFFFF8EE);

  // ─── خلفيات ليلية خضراء ───
  static const Color bgDeep = Color(0xFF07140C);
  static const Color bgPanel = Color(0xFF0E2216);
  static const Color bgPanel2 = Color(0xFF142B1B);

  static const Color nabadPrimary = secondary; // للتوافق
  static const Color nabadPrimaryLight = secondaryLight;
  static const Color nabadSoft = Color(0xFFCFECA8);

  // ─── الأدوار الوظيفية (كلها بدرجات الأخضر) ───
  static const Color gold = secondary; // التمييز والتوهج
  static const Color goldSoft = secondaryLight; // الأفتح للحدود والنصوص
  static const Color ember = secondaryDark; // العميق للتدرجات
  static const Color ivory = Color(0xFFF2FBF0); // النصوص الرئيسية
  static const Color muted = Color(0xFF9FB8A4); // النصوص الثانوية
  static const Color line = Color(0x3CAED581); // خطوط بنقاء 22%

  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgPanel, bgPanel2],
  );

  static const LinearGradient activeCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1C3B24), Color(0xFF0F2316)],
  );

  static const LinearGradient domeFillGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [ember, secondary, goldSoft],
  );
}