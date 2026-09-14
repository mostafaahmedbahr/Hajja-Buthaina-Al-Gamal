import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_colors.dart';
import 'data/repositories/prayer_repository.dart';
import 'data/services/athan_announcer_service.dart';
import 'presentation/cubit/prayer_cubit.dart';
import 'presentation/screens/mosque_clock_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  if (!kIsWeb) {
    // السماح بجميع الاتجاهات (landscape + portrait)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // إخفاء شريط الحالة والتنقل للوضع الغامر (immersive)
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  runApp(const MosqueApp());
}

class MosqueApp extends StatelessWidget {
  const MosqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مسجد الحاجة بثينة الجمال',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.bgDeep,
        colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: AppColors.gold,
              secondary: AppColors.ember,
            ),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      // --- Composition Root: هنا فقط تُبنى الطبقات وتُربط ببعضها ---
      home: BlocProvider(
        create: (_) => PrayerCubit(
          repository: PrayerRepository(),
          announcer: AthanAnnouncerService(),
        )..init(),
        child: const MosqueClockScreen(),
      ),
    );
  }
}
