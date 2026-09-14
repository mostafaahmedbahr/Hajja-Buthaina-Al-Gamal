import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/mosque_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// شريط أذكار يعرض كل ذكر لمدة ٣٠ ثانية ثم ينتقل إلى التالي مع تأثير fade.
class AzkarTickerWidget extends StatefulWidget {
  const AzkarTickerWidget({super.key});

  @override
  State<AzkarTickerWidget> createState() => _AzkarTickerWidgetState();
}

class _AzkarTickerWidgetState extends State<AzkarTickerWidget>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _fadeController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _transitionToNext();
    });
  }

  void _transitionToNext() {
    _fadeController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % MosqueConfig.azkarList.length;
      });
      _fadeController.reverse(from: 1.0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentZikr = MosqueConfig.azkarList[_currentIndex];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
        gradient: LinearGradient(
          colors: [AppColors.bgPanel, AppColors.bgPanel2, AppColors.bgPanel],
        ),
      ),
      child: ClipRect(
        child: SizedBox(
          height: 64,
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  currentZikr,
                  style: AppTextStyles.tickerText18.copyWith(fontSize: 200),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// لوحة الذكر العمودية — تعرض كل ذكر بحجم كبير في إطار جانبي (للجانب الأيسر
/// في التخطيط العريض) وتنتقل للذكر التالي بعرض باهت.
class ZikrPanelWidget extends StatefulWidget {
  const ZikrPanelWidget({super.key});

  @override
  State<ZikrPanelWidget> createState() => _ZikrPanelWidgetState();
}

class _ZikrPanelWidgetState extends State<ZikrPanelWidget>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _fadeController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      _fadeController.forward(from: 0.0).then((_) {
        if (!mounted) return;
        setState(() {
          _currentIndex = (_currentIndex + 1) % MosqueConfig.azkarList.length;
        });
        _fadeController.reverse(from: 1.0);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  // يحسب أكبر حجم خط يملأ لوحة الذكر مع التلفاف على أسطر قدر الحاجة
  static double _maxFontForBox(
    String text,
    TextStyle style,
    BoxConstraints constraints,
  ) {
    final double width = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : 1000;
    final double height = constraints.maxHeight.isFinite
        ? constraints.maxHeight
        : double.infinity;

    TextPainter measure(double size) => TextPainter(
          text: TextSpan(
            text: text,
            style: style.copyWith(fontSize: size, height: 1.3),
          ),
          maxLines: null,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        )..layout(maxWidth: width);

    double low = 30;
    double high = math.max(width, height.isFinite ? height : width) * 3;
    double best = low;

    // بحث ثنائي على أكبر خط يلتف على أسطر ولا يتجاوز صندوق اللوحة
    for (int i = 0; i < 45; i++) {
      final mid = (low + high) / 2;
      final tp = measure(mid);
      final fitsHeight = height.isFinite ? tp.height <= height : true;
      if (fitsHeight && tp.width <= width) {
        best = mid;
        low = mid;
      } else {
        high = mid;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final double f = MediaQuery.sizeOf(context).width / 1366;

    return Container(
      padding: EdgeInsets.all(14 * f.clamp(0.8, 2.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * f.clamp(0.8, 2.0)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgPanel, AppColors.bgPanel2],
        ),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * f.clamp(0.8, 2.0)),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController),
          child: LayoutBuilder(
            builder: (context, bc) {
              final zikr = MosqueConfig.azkarList[_currentIndex];
              final double hPad = 14 * f;
              final double vPad = 8 * f;
              // يقلّص القياس بهامش أمان بسيط حتى يظهر الذكر كاملاً بلا قصّ
              final inner = BoxConstraints(
                maxWidth: (bc.maxWidth - hPad * 2).clamp(80.0, double.infinity),
                maxHeight: (bc.maxHeight - vPad * 2).clamp(80.0, double.infinity),
              );
              final fontSize = _maxFontForBox(zikr, AppTextStyles.azkarLarge, inner) * 0.93;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                child: Center(
                  child: Text(
                    zikr,
                    style: AppTextStyles.azkarLarge.copyWith(
                      fontSize: fontSize,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
