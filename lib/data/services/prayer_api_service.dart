import 'dart:convert';
import 'package:http/http.dart' as http;

/// خدمة بسيطة مسؤوليتها الوحيدة: الاتصال بخدمة Aladhan وإرجاع الـ JSON خام.
/// أي منطق تحويل البيانات لموديلات التطبيق يتم في PrayerRepository وليس هنا.
class PrayerApiService {
  static const String _baseUrl = 'https://api.aladhan.com/v1/timings';

  Future<Map<String, dynamic>> fetchTimings({
    required double latitude,
    required double longitude,
    required int method,
    required String timezone,
  }) async {
    final ts = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final uri = Uri.parse(
      '$_baseUrl/$ts?latitude=$latitude&longitude=$longitude&method=$method&timezonestring=${Uri.encodeComponent(timezone)}',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw Exception('فشل الاتصال بخدمة المواقيت (رمز ${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['data'] as Map<String, dynamic>;
  }
}
