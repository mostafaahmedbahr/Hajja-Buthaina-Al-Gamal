import 'dart:async';
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
    // الخط يتدرّج مع حجم الشاشة ليظل واضحًا على شاشات 4K
    final double fontSize = (18 * MediaQuery.sizeOf(context).width / 1366).clamp(15.0, 34.0);

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
          height: 50,
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController),
            child: Center(
              child: Text(
                currentZikr,
                style: AppTextStyles.tickerText18.copyWith(fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
