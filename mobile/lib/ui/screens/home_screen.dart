import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/monitor_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/radial_gauge.dart';
import '../widgets/status_badge.dart';
import '../widgets/tool_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final stats = provider.currentStats;
    final today = provider.getSelectedPeriodToday();
    final settings = provider.settings;

    final costStr = settings.currency == 'CNY'
        ? '¥'
        : '\{today.costUsd.toStringAsFixed(2)}';

    final secondaryCostStr = settings.currency == 'CNY'
        ? '≈ \{today.costUsd.toStringAsFixed(2)}'
        : '≈ ¥';

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
            child: StatusBadge(status: provider.syncStatus),
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
            if (stats != null && stats.devices.isNotEmpty) ...[
              _buildDeviceSelector(context, provider),
              const SizedBox(height: 12),
            ],
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text(
                        '今日实时花费 (Today)',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
                        ),
                        child: Text(
                          '+',
                          style: const TextStyle(
                            color: AppColors.emerald,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        costStr,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        secondaryCostStr,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem('本月支出', _formatCost(stats?.month.costUsd ?? 0.0, settings)),
                      _buildMetricItem('本月 Token', _formatTokens(stats?.month.totalTokens ?? 0)),
                      _buildMetricItem('活跃工具', ' 个'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (provider.limits.isNotEmpty) ...[
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.between,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: provider.limits.take(3).map((item) {
                        final win = item.windows.isNotEmpty ? item.windows.first : null;
                        final percent = win?.remainingPercent ?? 100.0;
                        return RadialGauge(
                          remainingPercent: percent,
                          title: item.name,
                          subtitle: win?.resetInFormatted ?? '在线',
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
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
                  '已记录  款',
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
            label: '全部设备 ()',
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
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  String _formatCost(double usd, dynamic settings) {
    if (settings.currency == 'CNY') {
      return '¥';
    }
    return '\{usd.toStringAsFixed(2)}';
  }

  String _formatTokens(int count) {
    if (count >= 1000000) {
      return 'M';
    } else if (count >= 1000) {
      return 'K';
    }
    return count.toString();
  }
}
