import 'dart:math' as math;

/// نظام القياس المتجاوب للويب.
///
/// التصميم المرجعي على شاشة 1366×768 (شاشة لابتوب/تلفزيون نموذجية):
/// كل العناصر (الخطوط والفراغات والأحجام) تتدرّج تلقائيًا عبر عامل واحد
/// يضمن وضوح المؤشرات من أصغر شاشة ويب حتى أكبر شاشة (4K).
class ResponsiveMetrics {
  ResponsiveMetrics._();

  static const double _refWidth = 1366;
  static const double _refHeight = 768;

  /// عامل قياس موحّد يأخذ أصغر نسبة بين (العرض/1366) و (الارتفاع/768)،
  /// بحيث لا يتجاوز أي عنصر حدود الشاشة مهما اختلفت الأبعاد.
  static double fit(double width, double height) =>
      math.min(width / _refWidth, height / _refHeight).clamp(0.45, 3.2);
}