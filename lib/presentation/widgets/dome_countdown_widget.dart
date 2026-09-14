import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../cubit/prayer_state.dart';

/// العنصر المميز في التصميم: قوس محراب يمتلئ تدريجيًا (كساعة رملية)
/// كلما اقترب موعد الصلاة القادمة، ويصل لامتلائه الكامل بالضبط عند دخول الوقت.
///
/// يتكيّف تلقائيًا مع المساحة المتاحة: يقيس نفسه ويختار مقاسًا يملأ مساحته
/// دون تجاوزها — سواء شاشة 1024 أو تلفزيون 4K.
class DomeCountdownWidget extends StatelessWidget {
  final PrayerState state;

  /// عرض القوس — لو تُرك فارغًا يُحدَّد تلقائيًا من المساحة المتاحة.
  final double? width;

  const DomeCountdownWidget({super.key, required this.state, this.width});

  String _fmtCountdown(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(h)}:${pad(m)}:${pad(s)}';
  }

  String _fmtHM(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    String pad(int n) => n.toString().padLeft(2, '0');
    final mer = d.hour >= 12 ? 'م' : 'ص';
    return '${pad(h12)}:${pad(d.minute)} $mer';
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayer = state.nextPrayer;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.sizeOf(context);
        final double maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screenSize.width;
        final double maxH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : screenSize.height;

        // الارتفاع الذي تحتله الجملة التوضيحية أسفل القوس (تقدير متدرج)
        final double captionFont = math.max(12.0, math.min(20.0, 13.0 * maxW / 400));
        final double captionH = captionFont * 1.5 + 8;

        // العرض المطلوب (من الوالد) أو العرض الافتراضي المتدرج
        final double rawW = width != null
            ? width!
            : maxW.clamp(200.0, 460.0);

        // أقصى عرض يسمح به الارتفاع المتاح (القوس: ارتفاع = عرض × 1.25)
        final double maxDomeW = math.max(120.0, (maxH - captionH - 8) / 1.25);
        final double domeW = math.min(rawW, maxW).clamp(140.0, maxDomeW);
        final double domeH = domeW * 1.25;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: domeW,
              height: domeH,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(domeW, domeH),
                    painter: _ArchPainter(progress: state.windowProgress),
                  ),

                  // النصوص موزعة بالنسبة المئوية من ارتفاع القوس
                  Positioned(
                    top: domeH * 0.28,
                    child: Text(
                      'الصلاة القادمة',
                      style: AppTextStyles.domeLabel.copyWith(fontSize: 16 * domeW / 320),
                    ),
                  ),
                  Positioned(
                    top: domeH * 0.34,
                    child: Text(
                      nextPrayer?.arabicName ?? '—',
                      style: AppTextStyles.domePrayerName.copyWith(
                        fontSize: (domeW * 0.15).clamp(26.0, 120.0),
                      ),
                    ),
                  ),
                  Positioned(
                    top: domeH * 0.48,
                    child: Text(
                      _fmtCountdown(state.secondsToNext),
                      style: AppTextStyles.domeCountdown.copyWith(
                        fontSize: (domeW * 0.15).clamp(26.0, 120.0),
                      ),
                    ),
                  ),
                  Positioned(
                    top: domeH * 0.60,
                    child: Text(
                      nextPrayer != null ? 'عند ${_fmtHM(nextPrayer.time)}' : '',
                      style: AppTextStyles.domeTargetTime.copyWith(
                        fontSize: (14 * domeW / 320).clamp(12.0, 36.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'تحسب الشاشة الوقت المتبقي تلقائيًا وتنبّه عند دخول الوقت',
              style: AppTextStyles.domeLabel.copyWith(fontSize: captionFont),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}

class _ArchPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  _ArchPainter({required this.progress});

  /// سمك خط القوس يتدرّج مع حجم القوس (بدل قيمة ثابتة صغيرة على الشاشات الكبيرة)
  Path _archPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final left = w * 0.175;
    final right = w * 0.825;
    final peak = h * 0.093;
    final midY = h * 0.5;

    path.moveTo(left, h);
    path.lineTo(left, midY);
    path.quadraticBezierTo(left, peak * 2.7, w / 2, peak);
    path.quadraticBezierTo(right, peak * 2.7, right, midY);
    path.lineTo(right, h);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final archPath = _archPath(size);

    final bgPaint = Paint()..color = AppColors.bgPanel2;
    canvas.drawPath(archPath, bgPaint);

    canvas.save();
    canvas.clipPath(archPath);

    final archTop = size.height * 0.093;
    final archBottom = size.height;
    final fillHeight = progress * (archBottom - archTop);
    final fillRect = Rect.fromLTWH(0, archBottom - fillHeight, size.width, fillHeight);

    final fillPaint = Paint()
      ..shader = AppColors.domeFillGradient.createShader(
        Rect.fromLTWH(0, archTop, size.width, archBottom - archTop),
      );
    canvas.drawRect(fillRect, fillPaint);
    canvas.restore();

    final strokePaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.0, size.width * 0.006);
    canvas.drawPath(archPath, strokePaint);

    final crescentRadius = math.max(8.0, size.width * 0.028);
    final crescentPaint = Paint()..color = AppColors.gold;
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.047), crescentRadius, crescentPaint);
    final maskPaint = Paint()..color = AppColors.bgDeep;
    canvas.drawCircle(
      Offset(size.width / 2 + crescentRadius * 0.45, size.height * 0.037),
      crescentRadius * 0.88,
      maskPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArchPainter oldDelegate) => oldDelegate.progress != progress;
}