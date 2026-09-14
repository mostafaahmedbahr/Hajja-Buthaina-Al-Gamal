import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/mosque_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/responsive_metrics.dart';
import '../cubit/prayer_cubit.dart';
import '../cubit/prayer_state.dart';
import '../widgets/adhan_iqama_dialog.dart';
import '../widgets/azkar_ticker_widget.dart';
import '../widgets/dome_countdown_widget.dart';
import '../widgets/header_widget.dart';
import '../widgets/prayer_card_widget.dart';

class MosqueClockScreen extends StatelessWidget {
  const MosqueClockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          Positioned(top: -120, right: -80, child: _Glow(color: AppColors.gold)),
          Positioned(bottom: -140, left: -100, child: _Glow(color: AppColors.ember)),

          // المحتوى في عمود: الساعة فوق، وشريط الأذكار في مؤخرة التدفق
          // (بدل تداخله مع المحتوى)، حتى لا يغطي أي عنصر على أي مقاس.
          SafeArea(
            child: BlocListener<PrayerCubit, PrayerState>(
              listener: (context, state) {
                if (state.firedKey != null && state.nextPrayer != null) {
                  AdhanIqamaDialogController.show(context, state.nextPrayer!, state.now);
                }
              },
              child: BlocBuilder<PrayerCubit, PrayerState>(
                builder: (context, state) {
                  if (state.status == PrayerStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // الشاشات الواسعة (معظم شاشات الويب) → ثلاثة أعمدة كاملة
                      if (constraints.maxWidth > 820) {
                        return _buildWideLayout(state, constraints);
                      }
                      // النوافذ الضيقة/نصف المقسومة → الشريط السفلي للأذكار
                      return Column(
                        children: [
                          Expanded(
                            child: OrientationBuilder(
                              builder: (context, orientation) {
                                if (orientation == Orientation.landscape) {
                                  return _buildLandscapeLayout(state, constraints);
                                }
                                return SingleChildScrollView(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: _buildPortraitLayout(state),
                                );
                              },
                            ),
                          ),
                          const AzkarTickerWidget(),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),

          if (kDebugMode)
            Positioned(
              bottom: 110,
              left: 16,
              child: BlocBuilder<PrayerCubit, PrayerState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: 'test_athan',
                        backgroundColor: AppColors.bgPanel2,
                        foregroundColor: AppColors.goldSoft,
                        onPressed: () => context.read<PrayerCubit>().testAnnounceNext(),
                        icon: const Icon(Icons.volume_up_rounded),
                        label: const Text('تجربة الأذان'),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton.extended(
                        heroTag: 'test_dialog',
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.bgDeep,
                        onPressed: () {
                          if (state.nextPrayer != null) {
                            AdhanIqamaDialogController.show(
                              context,
                              state.nextPrayer!,
                              state.now,
                            );
                          }
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: const Text('اختبار الحوار'),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ─── التخطيط العريض — المواقيت يمين، المؤقت في النص، والذكر + الرعاية شمال ───
  Widget _buildWideLayout(PrayerState state, BoxConstraints constraints) {
    final double w = constraints.maxWidth;
    final double h = constraints.maxHeight;
    final double f = ResponsiveMetrics.fit(w, h);

    String clock(DateTime d) {
      final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
      String pad(int n) => n.toString().padLeft(2, '0');
      return '${pad(h12)}:${pad(d.minute)}:${pad(d.second)}';
    }
    String mer(DateTime d) => d.hour >= 12 ? 'مساءً' : 'صباحًا';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * f, vertical: 14 * f),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── المواقيت كلها على اليمين (أول عنصر في RTL) ──
          Expanded(
            flex: 2,
            child: _buildPrayersPanel(state, f),
          ),

          SizedBox(width: 16 * f),

          // ── المؤقت (القوس) في النص، مع اسم المسجد ──
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  MosqueConfig.name,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: AppTextStyles.mosqueTitle.copyWith(fontSize: 46 * f),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6 * f),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 1, width: 60 * f, color: AppColors.line),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10 * f),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.gold,
                          size: 14 * f,
                        ),
                      ),
                      Container(height: 1, width: 60 * f, color: AppColors.line),
                    ],
                  ),
                ),
                SizedBox(height: 6 * f),
                // القوس: يتمدد في المنتصف ليملأ المساحة المتبقية
                Expanded(
                  child: Center(
                    child: DomeCountdownWidget(state: state),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 16 * f),

          // ── الجانب الأيسر: التاريخ + الساعة ثم الذكر وحده يملأ الباقي ──
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // التاريخ
                Column(
                  children: [
                    Text(
                      state.gregorianText,
                      style: AppTextStyles.dateGregorian.copyWith(fontSize: 23 * f),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.hijriText,
                      style: AppTextStyles.dateHijri.copyWith(fontSize: 27 * f),
                    ),
                  ],
                ),
                SizedBox(height: 6 * f),

                // الساعة (تحت التاريخ مباشرة)
                Text(
                  '${clock(state.now)} ${mer(state.now)}',
                  maxLines: 1,
                  style: AppTextStyles.clockTime.copyWith(fontSize: 52 * f),
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10 * f),

                // الذكر — لوحده يملأ كل المساحة المتبقية
                Expanded(
                  child: ZikrPanelWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── لوحة مواقيت الصلاة ───
  Widget _buildPrayersPanel(PrayerState state, double f) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'مواقيت الصلاة',
          style: AppTextStyles.domeLabel.copyWith(
            fontSize: (19 * f).clamp(16.0, 48.0),
            letterSpacing: 1.5,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 6 * f, bottom: 12 * f),
          child: Container(height: 1, color: AppColors.line),
        ),
        Expanded(
          child: Column(
            children: List.generate(state.prayers.length, (i) {
              final p = state.prayers[i];
              final isActive = state.nextPrayer != null &&
                  state.nextPrayer!.key == p.key &&
                  state.nextPrayer!.time.isAtSameMomentAs(p.time);
              final isPassed = p.time.isBefore(state.now);

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: i < state.prayers.length - 1 ? 10 * f : 0,
                  ),
                  child: PrayerScheduleRow(
                    prayer: p,
                    isActive: isActive,
                    isPassed: isPassed,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(PrayerState state, BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: DomeCountdownWidget(state: state),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20 * ResponsiveMetrics.fit(constraints.maxWidth, constraints.maxHeight),
              vertical: 14,
            ),
            child: Column(
              children: [
                HeaderWidget(state: state),
                const SizedBox(height: 12),
                Expanded(
                  child: PrayerRowWidget(
                    prayers: state.prayers,
                    nextPrayer: state.nextPrayer,
                    now: state.now,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(PrayerState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HeaderWidget(state: state),
        const SizedBox(height: 16),
        DomeCountdownWidget(state: state),
        const SizedBox(height: 24),
        PrayerRowWidget(
          prayers: state.prayers,
          nextPrayer: state.nextPrayer,
          now: state.now,
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  const _Glow({required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withValues(alpha: .25), blurRadius: 140, spreadRadius: 40)],
        ),
      ),
    );
  }
}