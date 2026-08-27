import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/limit_provider.dart';

/// 负责在手机端直接通过 HTTPS 探测各大 AI Provider 的额度与余额
class LimitProbeService {
  /// 探测 OpenRouter 额度与余额
  Future<LimitProviderItem?> probeOpenRouter(String apiKey) async {
    if (apiKey.isEmpty) return null;
    try {
      final uri = Uri.parse('https://openrouter.ai/api/v1/auth/key');
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer ',
      }).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body)['data'] as Map<String, dynamic>?;
        if (data != null) {
          final limit = (data['limit'] as num?)?.toDouble();
          final usage = (data['usage'] as num?)?.toDouble() ?? 0.0;
          final remaining = (limit != null && limit > 0) ? (limit - usage) : null;
          final usedPercent = (limit != null && limit > 0) ? (usage / limit * 100.0) : 0.0;

          return LimitProviderItem(
            id: 'openrouter',
            name: 'OpenRouter',
            account: data['label']?.toString() ?? 'Management Key',
            status: 'ok',
            updatedAt: DateTime.now().toIso8601String(),
            windows: [
              LimitWindow(
                label: '信用额度',
                usedPercent: usedPercent,
                remainingPercent: (100.0 - usedPercent).clamp(0.0, 100.0),
                balance: remaining,
                currency: 'USD',
                metric: 'credits',
              ),
            ],
          );
        }
      }
    } catch (_) {}
    return null;
  }

  /// 探测 DeepSeek 预付余额
  Future<LimitProviderItem?> probeDeepSeek(String apiKey) async {
    if (apiKey.isEmpty) return null;
    try {
      final uri = Uri.parse('https://api.deepseek.com/user/balance');
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer ',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final isAvailable = data['is_available'] as bool? ?? true;
        final balanceInfos = (data['balance_infos'] as List<dynamic>?) ?? [];
        
        double totalCny = 0.0;
        for (var info in balanceInfos) {
          if (info is Map) {
            totalCny += (info['total_balance'] as num?)?.toDouble() ?? 0.0;
          }
        }

        return LimitProviderItem(
          id: 'deepseek',
          name: 'DeepSeek',
          account: 'API 预付账号',
          status: isAvailable ? 'ok' : 'depleted',
          updatedAt: DateTime.now().toIso8601String(),
          windows: [
            LimitWindow(
              label: '可用余额',
              usedPercent: 0,
              remainingPercent: 100,
              balance: totalCny,
              currency: 'CNY',
              metric: 'credits',
            ),
          ],
        );
      }
    } catch (_) {}
    return null;
  }
}
