import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/mosque_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
                      if (constraints.maxWidth > 700) {
                        return _buildWideLayout(state, constraints);
                      }

                      return OrientationBuilder(
                        builder: (context, orientation) {
                          if (orientation == Orientation.landscape) {
                            return _buildLandscapeLayout(state);
                          }
                          return SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 100),
                            child: _buildPortraitLayout(state),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const Positioned(bottom: 0, left: 0, right: 0, child: AzkarTickerWidget()),

          if (kDebugMode)
            Positioned(
              bottom: 90,
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

  // ─── شاشة عريضة (22بوصة) ───
  Widget _buildWideLayout(PrayerState state, BoxConstraints constraints) {
    String _clock(DateTime d) {
      final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
      pad(int n) => n.toString().padLeft(2, '0');
      return '${pad(h12)}:${pad(d.minute)}:${pad(d.second)}';
    }

    String _mer(DateTime d) => d.hour >= 12 ? 'مساءً' : 'صباحًا';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          // ── الساعة يمين + التاريخ يسار ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_clock(state.now)} ${_mer(state.now)}',
                  style: AppTextStyles.clockTime.copyWith(fontSize: 40),
                  textDirection: TextDirection.ltr,
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.gregorianText, style: AppTextStyles.dateGregorian.copyWith(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(state.hijriText, style: AppTextStyles.dateHijri.copyWith(fontSize: 22)),
                  ],
                ),
              ],
            ),
          ),

          // ── اسم المسجد في النص فوق القوس ──
          Text(
            MosqueConfig.name,
            style: AppTextStyles.mosqueTitle.copyWith(fontSize: 40),
            textAlign: TextAlign.center,
          ),

          // ── القوس في النص ──
          Expanded(
            child: Center(
              child: DomeCountdownWidget(state: state, width: 360),
            ),
          ),

          // ── الصلوات الخمس في صف واحد ──
          SizedBox(
            height: 180,
            child: Row(
              children: List.generate(state.prayers.length, (i) {
                final p = state.prayers[i];
                final isActive = state.nextPrayer != null &&
                    state.nextPrayer!.key == p.key &&
                    state.nextPrayer!.time.isAtSameMomentAs(p.time);
                final isPassed = p.time.isBefore(state.now);

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: i < state.prayers.length - 1 ? 16 : 0,
                    ),
                    child: PrayerCardWidget(
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
      ),
    );
  }

  Widget _buildLandscapeLayout(PrayerState state) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Center(
            child: DomeCountdownWidget(state: state),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                HeaderWidget(state: state),
                const SizedBox(height: 16),
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
          boxShadow: [BoxShadow(color: color.withOpacity(.25), blurRadius: 140, spreadRadius: 40)],
        ),
      ),
    );
  }
}
