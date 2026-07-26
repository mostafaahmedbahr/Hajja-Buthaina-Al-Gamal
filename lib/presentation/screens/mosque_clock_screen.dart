import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
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
          // توهج زخرفي هادئ أعلى/أسفل الشاشة (أجواء قناديل المسجد)
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

                  return OrientationBuilder(
                    builder: (context, orientation) {
                      final isLandscape = orientation == Orientation.landscape;

                      if (isLandscape) {
                        return _buildLandscapeLayout(state);
                      }
                      // Portrait: wrap in SingleChildScrollView to enable scrolling
                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100), // space for azkar ticker
                        child: _buildPortraitLayout(state),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // شريط الأذكار ملتصق بأسفل الشاشة (خارج SafeArea)
          const Positioned(bottom: 0, left: 0, right: 0, child: AzkarTickerWidget()),

          // زر اختبار الأذان + حوار الأذان/الإقامة (Debug فقط)
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

  Widget _buildLandscapeLayout(PrayerState state) {
    return Row(
      children: [
        // الجانب الأيمن: القبة والعد التنازلي
        Expanded(
          flex: 2,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: DomeCountdownWidget(state: state),
            ),
          ),
        ),
        // الجانب الأيسر: بطاقات الصلوات
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
