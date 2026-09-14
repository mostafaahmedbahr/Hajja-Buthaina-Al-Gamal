import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/prayer_time_model.dart';

class AdhanIqamaDialog extends StatefulWidget {
  final PrayerTimeModel nextPrayer;
  final DateTime now;
  final VoidCallback onDismiss;

  const AdhanIqamaDialog({
    super.key,
    required this.nextPrayer,
    required this.now,
    required this.onDismiss,
  });

  @override
  State<AdhanIqamaDialog> createState() => _AdhanIqamaDialogState();
}

class _AdhanIqamaDialogState extends State<AdhanIqamaDialog> {
  late Timer _timer;
  late int _secondsToIqama;
  int _azkarIndex = 0;
  Timer? _azkarTimer;

  static const List<String> _azkarBetweenAdhanIqama = [
    'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ',
    'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ، رَضِيتُ بِاللَّهِ رَبًّا وَبِمُحَمَّدٍ رَسُولًا وَبِالْإِسْلَامِ دِينًا',
    'سُبْحَانَ اللهِ وَبِحَمْدِهِ، سُبْحَانَ اللهِ الْعَظِيمِ',
    'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ وَعَلَى آلِهِ وَصَحْبِهِ أَجْمَعِينَ',
    'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
    'لَا إِلَٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    'اللَّهُمَّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
    'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    'حَسْبُنَا اللهُ وَنِعْمَ الْوَكِيلُ',
  ];

  @override
  void initState() {
    super.initState();
    _secondsToIqama = widget.nextPrayer.iqamaTime.difference(widget.now).inSeconds.clamp(0, 1 << 30);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      final remaining = widget.nextPrayer.iqamaTime.difference(now).inSeconds;
      if (remaining <= 0) {
        _timer.cancel();
        if (mounted) {
          setState(() => _secondsToIqama = 0);
          widget.onDismiss();
        }
      } else {
        setState(() => _secondsToIqama = remaining);
      }
    });

    _azkarTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      setState(() {
        _azkarIndex = (_azkarIndex + 1) % _azkarBetweenAdhanIqama.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _azkarTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '00:00';
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

@override
  Widget build(BuildContext context) {
    final prayerName = widget.nextPrayer.arabicName;
    final isIqamaTime = _secondsToIqama <= 0;
    // مقياس الحوار: يكبُر مع الشاشات الكبيرة لكنه محفوف حتى لا يتجاوز الشاشة
    final double f = (MediaQuery.sizeOf(context).width / 1366).clamp(0.75, 1.6);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(maxWidth: 820 * f),
          padding: EdgeInsets.all(36 * f),
          decoration: BoxDecoration(
            color: AppColors.bgPanel,
            borderRadius: BorderRadius.circular(20 * f),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.bgPanel,
                AppColors.bgPanel2,
                AppColors.bgPanel,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(prayerName, isIqamaTime, f),
              SizedBox(height: 20 * f),
              _buildCountdown(isIqamaTime, f),
              SizedBox(height: 20 * f),
              _buildAzkarSection(f),
              SizedBox(height: 20 * f),
              _buildDismissButton(f),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String prayerName, bool isIqamaTime, double f) {
    return Column(
      children: [

        Text(
          isIqamaTime ? 'حَانَتْ الْإِقَامَةُ' : 'صَلَاةُ $prayerName',
          style: AppTextStyles.cardPrayerName.copyWith(color: AppColors.gold, fontSize: 34 * f),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          isIqamaTime
              ? 'قَدْ قَامَتِ الصَّلَاةُ'
              : 'بَيْنَ الْأَذَانِ وَالْإِقَامَةِ',
          style: AppTextStyles.cardPrayerName.copyWith(color: AppColors.goldSoft, fontSize: 26 * f),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCountdown(bool isIqamaTime, double f) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 48 * f, vertical: 32 * f),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * f),
        color: AppColors.bgDeep.withValues(alpha: 0.6),
        border: Border.all(
          color: isIqamaTime ? AppColors.ember : AppColors.gold,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isIqamaTime ? AppColors.ember : AppColors.gold).withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isIqamaTime ? 'الْإِقَامَةُ الْآنَ' : 'مُتَبَقٍّ لِلْإِقَامَةِ',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gold, fontSize: 22 * f),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(
              _formatDuration(_secondsToIqama),
              key: ValueKey(_secondsToIqama),
              style: AppTextStyles.cardPrayerName.copyWith(
                color: isIqamaTime ? AppColors.ember : AppColors.gold,
                fontSize: 88 * f,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAzkarSection(double f) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 20 * f),
            const SizedBox(width: 8),
            Text(
              'أَذْكَارٌ وَأَدْعِيَةٌ بَيْنَ الْأَذَانِ وَالْإِقَامَةِ',
              style: AppTextStyles.cardPrayerName.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
                fontSize: 24 * f,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 20 * f),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Container(
            key: ValueKey(_azkarIndex),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.bgDeep.withValues(alpha: 0.5),
              border: Border.all(color: AppColors.line.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  _azkarBetweenAdhanIqama[_azkarIndex],
                  style: AppTextStyles.azkarLarge.copyWith(height: 1.5, fontSize: 28 * f),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _azkarBetweenAdhanIqama.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: index == _azkarIndex ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: index == _azkarIndex
                            ? AppColors.gold
                            : AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'قَالَ رَسُولُ اللَّهِ ﷺ: «الدُّعَاءُ لَا يُرَدُّ بَيْنَ الْأَذَانِ وَالْإِقَامَةِ»',
          style: AppTextStyles.o.copyWith(color: AppColors.gold, fontSize: 18 * f),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDismissButton(double f) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onDismiss,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.bgDeep,
          padding: EdgeInsets.symmetric(vertical: 22 * f),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * f)),
          elevation: 4,
          shadowColor: AppColors.gold.withValues(alpha: 0.4),
        ),
          child: Text(
            'إِغْلَاق',
            style: AppTextStyles.buttonLarge.copyWith(color: AppColors.bgDeep, fontSize: 24 * f),
        ),
      ),
    );
  }
}

class AdhanIqamaDialogController {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void show(BuildContext context, PrayerTimeModel nextPrayer, DateTime now) {
    if (_isShowing) return;
    _isShowing = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => _AdhanIqamaDialogRoute(
        nextPrayer: nextPrayer,
        now: now,
        onDismiss: _dismiss,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void _dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }
}

class _AdhanIqamaDialogRoute extends StatelessWidget {
  final PrayerTimeModel nextPrayer;
  final DateTime now;
  final VoidCallback onDismiss;

  const _AdhanIqamaDialogRoute({
    required this.nextPrayer,
    required this.now,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: AdhanIqamaDialog(
          nextPrayer: nextPrayer,
          now: now,
          onDismiss: onDismiss,
        ),
      ),
    );
  }
}