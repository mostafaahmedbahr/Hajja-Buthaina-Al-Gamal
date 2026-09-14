import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/prayer_time_model.dart';

const Map<String, IconData> _kPrayerIcons = {
  'sunrise': Icons.wb_twilight,
  'sun': Icons.wb_sunny_rounded,
  'sun_low': Icons.brightness_6_rounded,
  'sunset': Icons.wb_twilight,
  'moon': Icons.nightlight_round,
};

/// بطاقة صلاة تتدرّج أبعادها وخطوطها تلقائيًا مع المساحة المتاحة لها،
/// فيبقى شكلها سليمًا من أصغر نافذة حتى شاشات 4K.
class PrayerCardWidget extends StatelessWidget {
  final PrayerTimeModel prayer;
  final bool isActive;
  final bool isPassed;

  const PrayerCardWidget({
    super.key,
    required this.prayer,
    required this.isActive,
    required this.isPassed,
  });

  String _fmtHM(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    pad(int n) => n.toString().padLeft(2, '0');
    final mer = d.hour >= 12 ? 'م' : 'ص';
    return '${pad(h12)}:${pad(d.minute)} $mer';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // مقياس البطاقة: نسبة لعرض/ارتفاع التصميم المرجعي (240×190)
        final double maxH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : double.infinity;
        final double s = math
            .min(constraints.maxWidth / 240, maxH / 190)
            .clamp(0.5, 3.6);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          transform: isActive ? (Matrix4.identity()..translateByDouble(0.0, -6.0, 0.0, 1.0)) : Matrix4.identity(),
          padding: EdgeInsets.symmetric(vertical: 20 * s, horizontal: 12 * s),
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.activeCardGradient : AppColors.panelGradient,
            borderRadius: BorderRadius.circular(18 * s),
            border: Border.all(
              color: isActive ? AppColors.gold : AppColors.line,
              width: isActive ? 2.5 * s : 1 * s,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(color: AppColors.gold.withValues(alpha: .35), blurRadius: 24 * s, spreadRadius: 1),
                    const BoxShadow(color: Colors.black45, blurRadius: 30, offset: Offset(0, 18)),
                  ]
                : [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12 * s, offset: const Offset(0, 6)),
                  ],
          ),
          child: Opacity(
            opacity: (isPassed && !isActive) ? 0.5 : 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isActive)
                  Container(
                    margin: EdgeInsets.only(bottom: 10 * s),
                    height: 4 * s,
                    width: 48 * s,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4 * s),
                      gradient: const LinearGradient(colors: [AppColors.ember, AppColors.gold]),
                    ),
                  ),
                Icon(_kPrayerIcons[prayer.iconName] ?? Icons.circle, color: AppColors.gold, size: 30 * s),
                SizedBox(height: 8 * s),
                Text(
                  prayer.arabicName,
                  style: AppTextStyles.cardPrayerName.copyWith(fontSize: 22 * s),
                ),
                SizedBox(height: 6 * s),
                Text(
                  _fmtHM(prayer.time),
                  style: AppTextStyles.cardPrayerTime.copyWith(fontSize: 22 * s),
                ),
                SizedBox(height: 4 * s),
                Text(
                  'إقامة ${_fmtHM(prayer.iqamaTime)}',
                  style: AppTextStyles.cardIqama.copyWith(fontSize: 14 * s),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// صف موعد أنيق في لوحة المواقيت (العمود الجانبي في التخطيط العريض).
/// يتدرّج تلقائيًا مع مساحته: أيقونة + اسم + وقت، مع تمييز الصلاة القادمة.
class PrayerScheduleRow extends StatelessWidget {
  final PrayerTimeModel prayer;
  final bool isActive;
  final bool isPassed;

  const PrayerScheduleRow({
    super.key,
    required this.prayer,
    required this.isActive,
    required this.isPassed,
  });

  String _fmtHM(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    String pad(int n) => n.toString().padLeft(2, '0');
    final mer = d.hour >= 12 ? 'م' : 'ص';
    return '${pad(h12)}:${pad(d.minute)} $mer';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : double.infinity;
        final double s = math
            .min(constraints.maxWidth / 460, maxH / 92)
            .clamp(0.5, 2.8);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          transform: isActive ? (Matrix4.identity()..translateByDouble(0.0, -4.0, 0.0, 1.0)) : Matrix4.identity(),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 8 * s),
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.activeCardGradient : AppColors.panelGradient,
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(
              color: isActive ? AppColors.gold : AppColors.line,
              width: isActive ? 2.5 * s : 1 * s,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(color: AppColors.gold.withValues(alpha: .4), blurRadius: 26 * s, spreadRadius: 2),
                    BoxShadow(
                      color: AppColors.ember.withValues(alpha: .15),
                      blurRadius: 34 * s,
                      spreadRadius: 4,
                    ),
                    const BoxShadow(color: Colors.black45, blurRadius: 24, offset: Offset(0, 12)),
                  ]
                : [
                    BoxShadow(color: Colors.black.withValues(alpha: .25), blurRadius: 10 * s, offset: const Offset(0, 4)),
                  ],
          ),
          child: Opacity(
            opacity: (isPassed && !isActive) ? 0.55 : 1,
            child: Row(
              children: [
                // شريط جانبي ذهبي يميّز الصلاة التي عليها الدور
                if (isActive)
                  Container(
                    width: 5 * s,
                    height: 56 * s,
                    margin: EdgeInsets.only(left: 4 * s),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3 * s),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.ember, AppColors.gold, AppColors.goldSoft],
                      ),
                    ),
                  ),
                Icon(_kPrayerIcons[prayer.iconName] ?? Icons.circle, color: AppColors.gold, size: 30 * s),
                SizedBox(width: 14 * s),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayer.arabicName,
                        style: AppTextStyles.cardPrayerName.copyWith(fontSize: 20 * s),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'إقامة ${_fmtHM(prayer.iqamaTime)}',
                        style: AppTextStyles.cardIqama.copyWith(fontSize: 13 * s),
                      ),
                    ],
                  ),
                ),
                // لمعة تدلّ أن هذه الصلاة هي التي عليها الدور
                if (isActive)
                  Padding(
                    padding: EdgeInsets.only(left: 10 * s),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.goldSoft,
                      size: 20 * s,
                    ),
                  ),
                Text(
                  _fmtHM(prayer.time),
                  style: AppTextStyles.cardPrayerTime.copyWith(fontSize: 24 * s),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// صف الصلوات الخمس — Wrap يتكيّف تلقائيًا مع عرض الحاوية.
class PrayerRowWidget extends StatelessWidget {
  final List<PrayerTimeModel> prayers;
  final PrayerTimeModel? nextPrayer;
  final DateTime now;

  const PrayerRowWidget({
    super.key,
    required this.prayers,
    required this.nextPrayer,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760
            ? 5
            : constraints.maxWidth > 480
                ? 3
                : 2;
        final cardWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: prayers.map((p) {
            final isActive = nextPrayer != null &&
                nextPrayer!.key == p.key &&
                nextPrayer!.time.isAtSameMomentAs(p.time);
            final isPassed = p.time.isBefore(now);
            return SizedBox(
              width: cardWidth,
              child: PrayerCardWidget(prayer: p, isActive: isActive, isPassed: isPassed),
            );
          }).toList(),
        );
      },
    );
  }
}