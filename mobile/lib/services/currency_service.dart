import 'dart:convert';
import 'package:http/http.dart' as http;

/// 汇率服务：与桌面端保持一致，从公共 Currency API 获取实时动态汇率
class CurrencyService {
  static const String primaryApi =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json';
  static const String fallbackApi =
      'https://latest.currency-api.pages.dev/v1/currencies/usd.json';

  /// 获取最新 USD -> CNY 汇率
  static Future<double?> fetchUsdToCnyRate() async {
    for (final url in [primaryApi, fallbackApi]) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 5),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (data['usd'] is Map && data['usd']['cny'] != null) {
            final rate = (data['usd']['cny'] as num).toDouble();
            return rate;
          }
        }
      } catch (_) {}
    }
    return null;
  }
}
