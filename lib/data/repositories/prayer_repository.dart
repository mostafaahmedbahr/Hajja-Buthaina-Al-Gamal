import 'package:intl/intl.dart';
import '../../core/constants/mosque_config.dart';
import '../models/daily_timings_model.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_api_service.dart';

const List<String> _gregMonthsAr = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

/// طبقة الـ Repository: تخفي تفاصيل مصدر البيانات (API أو احتياطي)
/// عن الـ Cubit، وترجّع دائمًا موديل جاهز للاستخدام في الواجهة.
class PrayerRepository {
  final PrayerApiService _api;
  PrayerRepository({PrayerApiService? apiService}) : _api = apiService ?? PrayerApiService();

  Future<DailyTimingsModel> getTodayTimings() async {
    try {
      final data = await _api.fetchTimings(
        latitude: MosqueConfig.latitude,
        longitude: MosqueConfig.longitude,
        method: MosqueConfig.calculationMethod,
        timezone: MosqueConfig.timezone,
      );

      final timings = Map<String, dynamic>.from(data['timings'] as Map);
      final hijri = data['date']['hijri'] as Map<String, dynamic>;
      final greg = data['date']['gregorian'] as Map<String, dynamic>;

      final hijriText = '${hijri['day']} ${hijri['month']['ar']} ${hijri['year']}هـ';
      final monthNum = int.tryParse(greg['month']['number'].toString()) ?? 1;
      final gregorianText =
          '${greg['day']} ${_gregMonthsAr[monthNum - 1]} ${greg['year']}م';

      return _buildDailyModel(
        rawTimings: timings.map((k, v) => MapEntry(k, v.toString())),
        hijriText: hijriText,
        gregorianText: gregorianText,
      );
    } catch (_) {
      // احتياطي بدون إنترنت — الشاشة تستمر بالعمل بمواقيت تقريبية
      return _buildDailyModel(
        rawTimings: MosqueConfig.fallbackTimings,
        hijriText: _hijriFallback(),
        gregorianText: _gregorianFallback(),
      );
    }
  }

  DailyTimingsModel _buildDailyModel({
    required Map<String, String> rawTimings,
    required String hijriText,
    required String gregorianText,
  }) {
    final now = DateTime.now();

    DateTime parseTime(String key) {
      final clean = rawTimings[key]!.split(' ').first; // إزالة رمز المنطقة الزمنية إن وُجد
      final parts = clean.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return DateTime(now.year, now.month, now.day, h, m);
    }

    final prayers = kPrayerOrder.map((key) {
      final time = parseTime(key);
      final offset = MosqueConfig.iqamaOffsetsMinutes[key] ?? 15;
      return PrayerTimeModel(
        key: key,
        arabicName: kPrayerLabels[key]!['ar']!,
        iconName: kPrayerLabels[key]!['icon']!,
        time: time,
        iqamaTime: time.add(Duration(minutes: offset)),
      );
    }).toList();

    final fajr = prayers.first;
    final tomorrowFajrTime = fajr.time.add(const Duration(days: 1));
    final tomorrowFajr = PrayerTimeModel(
      key: 'Fajr',
      arabicName: kPrayerLabels['Fajr']!['ar']!,
      iconName: kPrayerLabels['Fajr']!['icon']!,
      time: tomorrowFajrTime,
      iqamaTime: tomorrowFajrTime.add(
        Duration(minutes: MosqueConfig.iqamaOffsetsMinutes['Fajr'] ?? 15),
      ),
    );

    return DailyTimingsModel(
      hijriText: hijriText,
      gregorianText: gregorianText,
      prayers: prayers,
      tomorrowFajr: tomorrowFajr,
    );
  }

  String _gregorianFallback() {
    final f = DateFormat('EEEE، d MMMM yyyy', 'ar');
    return '${f.format(DateTime.now())}م';
  }

  String _hijriFallback() => '—'; // بدون إنترنت لا يمكن حساب هجري دقيق بدون مكتبة إضافية
}
