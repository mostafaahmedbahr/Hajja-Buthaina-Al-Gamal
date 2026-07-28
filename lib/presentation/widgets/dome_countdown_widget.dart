import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../cubit/prayer_state.dart';

/// العنصر المميز في التصميم: قوس محراب يمتلئ تدريجيًا (كساعة رملية)
/// كلما اقترب موعد الصلاة القادمة، ويصل لامتلائه الكامل بالضبط عند دخول الوقت.
class DomeCountdownWidget extends StatelessWidget {
  final PrayerState state;

  /// عرض القوس — لو اتحدد يُستخدم مباشرة (مفيد لتخطيط الويب)
  final double? width;

  const DomeCountdownWidget({super.key, required this.state, this.width});

  String _fmtCountdown(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final pad = (int n) => n.toString().padLeft(2, '0');
    return '${pad(h)}:${pad(m)}:${pad(s)}';
  }

  String _fmtHM(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final pad = (int n) => n.toString().padLeft(2, '0');
    final mer = d.hour >= 12 ? 'م' : 'ص';
    return '${pad(h12)}:${pad(d.minute)} $mer';
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayer = state.nextPrayer;

    final double domeW = width ??
        MediaQuery.of(context).size.width.clamp(280.0, 450.0);
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
                child: Text('الصلاة القادمة', style: AppTextStyles.domeLabel.copyWith(fontSize: 16)),
              ),
              Positioned(
                top: domeH * 0.34,
                child: Text(
                  nextPrayer?.arabicName ?? '—',
                  style: AppTextStyles.domePrayerName.copyWith(
                    fontSize: (domeW * 0.15).clamp(28.0, 50.0),
                  ),
                ),
              ),
              Positioned(
                top: domeH * 0.48,
                child: Text(
                  _fmtCountdown(state.secondsToNext),
                  style: AppTextStyles.domeCountdown.copyWith(
                    fontSize: (domeW * 0.15).clamp(28.0, 50.0),
                  ),
                ),
              ),
              Positioned(
                top: domeH * 0.60,
                child: Text(
                  nextPrayer != null ? 'عند ${_fmtHM(nextPrayer.time)}' : '',
                  style: AppTextStyles.domeTargetTime.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'تحسب الشاشة الوقت المتبقي تلقائيًا وتنبّه عند دخول الوقت',
          style: AppTextStyles.domeLabel.copyWith(fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ArchPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  _ArchPainter({required this.progress});

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
      ..strokeWidth = 2;
    canvas.drawPath(archPath, strokePaint);

    final crescentPaint = Paint()..color = AppColors.gold;
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.047), 9, crescentPaint);
    final maskPaint = Paint()..color = AppColors.bgDeep;
    canvas.drawCircle(Offset(size.width / 2 + 4, size.height * 0.037), 8, maskPaint);
  }

  @override
  bool shouldRepaint(covariant _ArchPainter oldDelegate) => oldDelegate.progress != progress;
}
