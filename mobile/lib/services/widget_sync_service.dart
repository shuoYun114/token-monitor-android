import 'package:home_widget/home_widget.dart';
import '../models/device_stats.dart';
import '../models/limit_provider.dart';

/// 负责将 Token Monitor 最新的用量与额度数据同步到 Android 桌面小组件 (AppWidget)
class WidgetSyncService {
  static const String appGroupId = 'com.javis.tokenmonitor.widget';
  static const String widgetProvider4x2 = 'TokenMonitorWidget4x2';
  static const String widgetProvider2x2 = 'TokenMonitorWidget2x2';

  static Future<void> updateWidgetData({
    required PeriodUsage today,
    required String currency,
    required double rate,
    List<LimitProviderItem> limits = const [],
  }) async {
    try {
      final costFormatted = currency == 'CNY'
          ? '¥${(today.costUsd * rate).toStringAsFixed(2)}'
          : '\$${today.costUsd.toStringAsFixed(2)}';

      final tokenFormatted = _formatTokens(today.totalTokens);

      // 提取关键提供商进度
      String claudeQuota = '--';
      String codexQuota = '--';

      for (var p in limits) {
        if (p.id.contains('claude') && p.windows.isNotEmpty) {
          claudeQuota = '${p.windows.first.remainingPercent.toStringAsFixed(0)}%';
        }
        if (p.id.contains('codex') && p.windows.isNotEmpty) {
          codexQuota = '${p.windows.first.remainingPercent.toStringAsFixed(0)}%';
        }
        if (p.id.contains('antigravity') && p.windows.isNotEmpty && claudeQuota == '--') {
          claudeQuota = '${p.windows.first.remainingPercent.toStringAsFixed(0)}%';
        }
      }

      // 保存小组件键值对
      await HomeWidget.saveWidgetData<String>('today_cost', costFormatted);
      await HomeWidget.saveWidgetData<String>('today_tokens', tokenFormatted);
      await HomeWidget.saveWidgetData<String>('claude_quota', claudeQuota);
      await HomeWidget.saveWidgetData<String>('codex_quota', codexQuota);
      await HomeWidget.saveWidgetData<String>('last_updated', DateTime.now().toLocal().toString().substring(11, 16));

      // 触发原生 Android AppWidget 刷新
      await HomeWidget.updateWidget(
        name: widgetProvider4x2,
        androidName: 'TokenMonitorWidget4x2',
      );
      await HomeWidget.updateWidget(
        name: widgetProvider2x2,
        androidName: 'TokenMonitorWidget2x2',
      );
    } catch (_) {
      // 忽略在非原生小部件环境下的错误
    }
  }

  static String _formatTokens(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
