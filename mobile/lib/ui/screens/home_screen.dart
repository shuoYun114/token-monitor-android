import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/monitor_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/radial_gauge.dart';
import '../widgets/status_badge.dart';
import '../widgets/tool_card.dart';
import '../widgets/model_breakdown_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final stats = provider.currentStats;
    final today = provider.getSelectedPeriodToday();
    final settings = provider.settings;

    final costStr = settings.currency == 'CNY'
        ? '¥${(today.costUsd * settings.usdToCnyRate).toStringAsFixed(2)}'
        : '\$${today.costUsd.toStringAsFixed(2)}';

    final secondaryCostStr = settings.currency == 'CNY'
        ? '≈ \$${today.costUsd.toStringAsFixed(2)}'
        : '≈ ¥${(today.costUsd * settings.usdToCnyRate).toStringAsFixed(2)}';

    final formatter = NumberFormat('#,###');
    final exactTokensFormatted = formatter.format(today.totalTokens);
    final shortTokensFormatted = _formatTokensShort(today.totalTokens);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.cyan, AppColors.indigo],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.speed_rounded, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text('Token Monitor'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StatusBadge(
              status: provider.syncStatus,
              errorMessage: provider.errorMessage,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.cyan,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await provider.refreshNow();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // 错误提示条
            if (provider.syncStatus == SyncStatus.error && provider.errorMessage != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.rose.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.rose.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.rose, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: AppColors.rose, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (stats != null && stats.devices.isNotEmpty) ...[
              _buildDeviceSelector(context, provider),
              const SizedBox(height: 12),
            ],

            // 核心双数据并列栏目：今日花费 + 今日消耗 Token 专属大栏目
            Row(
              children: [
                // 1. 今日实时花费大卡片
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.amber,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '今日实时花费',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            costStr,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          secondaryCostStr,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 2. 今日消耗 Token 独立大卡片 (醒目大栏目)
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.cyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '今日消耗 Token',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                shortTokensFormatted,
                                style: const TextStyle(
                                  color: AppColors.cyan,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Tokens',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$exactTokensFormatted',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 月度支出与统计汇总卡片
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem('本月支出', _formatCost(stats?.month.costUsd ?? 0.0, settings)),
                  const SizedBox(
                    height: 24,
                    child: VerticalDivider(color: AppColors.glassBorder, width: 1),
                  ),
                  _buildMetricItem('本月 Token', _formatTokensShort(stats?.month.totalTokens ?? 0) + ' Tokens'),
                  const SizedBox(
                    height: 24,
                    child: VerticalDivider(color: AppColors.glassBorder, width: 1),
                  ),
                  _buildMetricItem('活跃工具', '${today.clients.length} 款'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AI 额度健康度 (支持同一 Provider 下的多额度窗口，如 Gemini + Claude/GPT)
            if (provider.limits.isNotEmpty) ...[
              Builder(
                builder: (context) {
                  // 收集所有有效额度展示项
                  final List<Widget> gauges = [];
                  for (final item in provider.limits) {
                    if (item.windows.isNotEmpty) {
                      for (final win in item.windows) {
                        final title = item.windows.length > 1
                            ? '${item.name} · ${win.label}'
                            : item.name;
                        gauges.add(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: RadialGauge(
                              remainingPercent: win.remainingPercent,
                              title: title,
                              subtitle: win.resetInFormatted ?? '在线',
                            ),
                          ),
                        );
                      }
                    } else {
                      gauges.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: RadialGauge(
                            remainingPercent: 100.0,
                            title: item.name,
                            subtitle: '已就绪',
                          ),
                        ),
                      );
                    }
                  }

                  if (gauges.isEmpty) return const SizedBox.shrink();

                  return GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'AI 额度健康度',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Icon(Icons.shield_outlined, size: 16, color: AppColors.emerald),
                          ],
                        ),
                        const SizedBox(height: 14),
                        gauges.length <= 3
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: gauges,
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(children: gauges),
                              ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // 今日活跃模型分布与排行 (对齐电脑桌面版 v0.53.0 核心能力)
            if (today.models.isNotEmpty) ...[
              ModelBreakdownCard(
                models: today.models,
                modelCosts: today.modelCosts,
                totalTokens: today.totalTokens,
                currency: settings.currency,
                rate: settings.usdToCnyRate,
              ),
              const SizedBox(height: 16),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '活跃 AI 编程工具',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '已记录 ${today.clients.length} 款',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (today.clients.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    '暂无今日工具用量记录',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
              )
            else
              ...today.clients.entries.map((entry) {
                final clientName = entry.key;
                final tokens = entry.value;
                final cost = today.clientCosts[clientName] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ToolCard(
                    clientName: clientName,
                    tokenCount: tokens,
                    costUsd: cost,
                    currency: settings.currency,
                    rate: settings.usdToCnyRate,
                  ),
                );
              }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSelector(BuildContext context, MonitorProvider provider) {
    final devices = provider.currentStats?.devices ?? [];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            label: '全部设备 (${devices.length})',
            isSelected: provider.selectedDeviceId == null,
            onTap: () => provider.setSelectedDevice(null),
          ),
          const SizedBox(width: 8),
          ...devices.map((d) {
            final isSel = provider.selectedDeviceId == d.deviceId;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                label: d.hostname,
                isSelected: isSel,
                onTap: () => provider.setSelectedDevice(d.deviceId),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cyan.withOpacity(0.18) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.cyan : AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.cyan : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  String _formatCost(double usd, dynamic settings) {
    if (settings.currency == 'CNY') {
      return '¥${(usd * settings.usdToCnyRate).toStringAsFixed(1)}';
    }
    return '\$${usd.toStringAsFixed(2)}';
  }

  String _formatTokensShort(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000.0).toStringAsFixed(2)}M';
    } else if (count >= 1000) {
      return '${(count / 1000.0).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
