import 'package:flutter/material.dart';
import '../../core/constants/mosque_config.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/responsive_metrics.dart';
import '../cubit/prayer_state.dart';

class HeaderWidget extends StatelessWidget {
  final PrayerState state;
  final bool expanded;

  const HeaderWidget({super.key, required this.state, this.expanded = false});

  String _clockTime(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(h12)}:${pad(d.minute)}:${pad(d.second)}';
  }

  String _meridiem(DateTime d) => d.hour >= 12 ? 'مساءً' : 'صباحًا';

  @override
  Widget build(BuildContext context) {
    return expanded ? _buildWideHeader() : _buildCompactHeader(context);
  }

  Widget _buildWideHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // الساعة (أقصى يمين في RTL)
          Text(
            '${_clockTime(state.now)} ${_meridiem(state.now)}',
            style: AppTextStyles.clockTime.copyWith(fontSize: 40),
            textDirection: TextDirection.ltr,
          ),

          const Spacer(),

          // اسم المسجد (في النص)
          Text(
            MosqueConfig.name,
            style: AppTextStyles.mosqueTitle.copyWith(fontSize: 38),
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          // التاريخ (أقصى يسار في RTL)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.gregorianText,
                style: AppTextStyles.dateGregorian.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                state.hijriText,
                style: AppTextStyles.dateHijri.copyWith(fontSize: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    final double f = ResponsiveMetrics.fit(
      MediaQuery.sizeOf(context).width,
      MediaQuery.sizeOf(context).height,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * f.clamp(0.8, 1.4), vertical: 14),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.gregorianText,
                style: AppTextStyles.dateGregorian.copyWith(fontSize: 13 * f.clamp(0.9, 1.5)),
              ),
              const SizedBox(height: 3),
              Text(
                state.hijriText,
                style: AppTextStyles.dateHijri.copyWith(fontSize: 15 * f.clamp(0.9, 1.5)),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                MosqueConfig.name,
                style: AppTextStyles.mosqueTitle.copyWith(fontSize: 30 * f.clamp(0.9, 1.4)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                MosqueConfig.city,
                style: AppTextStyles.mosqueSubtitle.copyWith(fontSize: 14 * f.clamp(0.9, 1.4)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _clockTime(state.now),
                style: AppTextStyles.clockTime.copyWith(fontSize: 34 * f.clamp(0.9, 1.5)),
              ),
              const SizedBox(height: 3),
              Text(
                _meridiem(state.now),
                style: AppTextStyles.clockMeridiem.copyWith(fontSize: 14 * f.clamp(0.9, 1.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}