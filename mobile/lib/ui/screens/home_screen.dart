import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/monitor_provider.dart';
import '../../models/limit_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/radial_gauge.dart';
import '../widgets/status_badge.dart';
import '../widgets/tool_card.dart';
import '../widgets/model_breakdown_card.dart';
import '../widgets/chrono_aperture.dart';


/// Token Monitor 顶级审美移动看板 (Bento Grid 非对称架构 + 黑曜石控制台质感)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final stats = provider.currentStats;
    final today = provider.getSelectedPeriodToday();
    final settings = provider.settings;

    // 今日费用字符串计算
    final costStr = settings.currency == 'CNY'
        ? '¥${(today.costUsd * settings.usdToCnyRate).toStringAsFixed(2)}'
        : '\$${today.costUsd.toStringAsFixed(2)}';

    final secondaryCostStr = settings.currency == 'CNY'
        ? '≈ \$${today.costUsd.toStringAsFixed(2)}'
        : '≈ ¥${(today.costUsd * settings.usdToCnyRate).toStringAsFixed(2)}';

    final formatter = NumberFormat('#,###');
    final exactTokensFormatted = formatter.format(today.totalTokens);
    final shortTokensFormatted = _formatTokensShort(today.totalTokens);

    final isLight = provider.isLightTheme;
    final accent = AppColors.getThemeAccent(isLight);

    return Scaffold(
      backgroundColor: isLight ? AppColors.lightBackground : AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isLight
                      ? [AppColors.warmYellowDark, AppColors.warmYellow]
                      : [AppColors.iceBlue, const Color(0xFF4F46E5)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: (isLight ? AppColors.warmYellowDark : AppColors.iceBlue).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.speed_rounded, size: 19, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Token Monitor',
                  style: TextStyle(
                    color: isLight ? AppColors.lightTextPrimary : AppColors.warmWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'AI COMPUTE CONSOLE',
                  style: TextStyle(
                    color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
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
        color: isLight ? AppColors.warmYellowDark : AppColors.cyan,
        backgroundColor: isLight ? AppColors.lightSurface : AppColors.surface,
        onRefresh: () async {
          await provider.refreshNow();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // 异常提示条
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

            // 硬件设备多维透视切换卡扣 (Horizon Perspective)
            if (stats != null && stats.devices.isNotEmpty) ...[
              _buildDeviceSelector(context, provider, isLight),
              const SizedBox(height: 14),
            ],

            // =========================================================
            // 1. 核心灵魂记忆点：全息算力天体视窗 (Chrono-Telemetry Aperture)
            // =========================================================
            ChronoApertureWidget(
              totalTokens: today.totalTokens,
              shortTokensText: shortTokensFormatted,
              exactTokensText: exactTokensFormatted,
              costText: costStr,
              secondaryCostText: secondaryCostStr,
              modelsCount: today.models.length,
              clientsCount: today.clients.length,
              isLight: isLight,
              onTap: () => provider.refreshNow(),
            ),
            const SizedBox(height: 12),

            // =========================================================
            // 2. Bento Grid 双列次级情报舱 (Bento Aerospace Pods)
            // =========================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左翼：本月支出与累计趋势 (航天钛晶与琥珀金)
                Expanded(
                  child: GlassContainer(
                    glowColor: AppColors.glowWarmYellow,
                    topHighlightColor: AppColors.glassTopHighlightWarm,
                    borderColor: (isLight ? AppColors.warmYellowDark : AppColors.warmYellow).withOpacity(0.28),
                    enableCornerBolts: true,
                    podTag: 'TELEMETRY // L-01',
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.warmYellow),
                            const SizedBox(width: 6),
                            Text(
                              '本月累计',
                              style: TextStyle(
                                color: isLight ? AppColors.lightTextSecondary : AppColors.warmWhiteSoft,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _formatCost(stats?.month.costUsd ?? 0.0, settings),
                            style: TextStyle(
                              color: isLight ? AppColors.lightTextPrimary : AppColors.warmWhitePure,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Token: ',
                              style: TextStyle(
                                color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              _formatTokensShort(stats?.month.totalTokens ?? 0),
                              style: TextStyle(
                                color: isLight ? AppColors.warmYellowDark : AppColors.warmYellow,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLight ? const Color(0xFFEDF2F7) : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '共 ${today.clients.length} 款工具活跃',
                            style: TextStyle(
                              color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 右翼：AI 额度健康雷达 (提取关键额度)
                Expanded(
                  child: GlassContainer(
                    glowColor: AppColors.glowEmerald,
                    borderColor: AppColors.emerald.withOpacity(0.24),
                    enableCornerBolts: true,
                    podTag: 'QUOTA // R-02',
                    padding: const EdgeInsets.all(14),
                    child: _buildQuotaRadarWidget(provider, isLight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // =========================================================
            // 3. AI 额度健康全景舱 (如果配置了多提供商，展开展示)
            // =========================================================
            if (provider.limits.isNotEmpty) ...[
              _buildLimitsOverviewPod(provider, isLight),
              const SizedBox(height: 14),
            ],

            // =========================================================
            // 4. 今日活跃模型全景分布 (对齐电脑版 v0.53.0 + 分段能量带)
            // =========================================================
            if (today.models.isNotEmpty) ...[
              ModelBreakdownCard(
                models: today.models,
                modelCosts: today.modelCosts,
                totalTokens: today.totalTokens,
                currency: settings.currency,
                rate: settings.usdToCnyRate,
              ),
              const SizedBox(height: 14),
            ],

            // =========================================================
            // 5. 活跃 AI 编程工具控制台列表 (Tool Consoles)
            // =========================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.terminal_rounded, size: 16, color: AppColors.cyan),
                    const SizedBox(width: 6),
                    Text(
                      '活跃工具控制台',
                      style: TextStyle(
                        color: isLight ? AppColors.lightTextPrimary : AppColors.warmWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFEDF2F7) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isLight ? const Color(0xFFCBD5E1) : AppColors.glassBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '已就绪 ${today.clients.length} 款',
                    style: TextStyle(
                      color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary,
                      fontSize: 11,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (today.clients.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 28),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Icon(Icons.inbox_rounded, size: 36, color: AppColors.textGhost),
                    SizedBox(height: 8),
                    Text(
                      '今日暂无活跃工具调用日志',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 硬件设备多维透视卡扣 (Horizon Perspective)
  Widget _buildDeviceSelector(BuildContext context, MonitorProvider provider, bool isLight) {
    final devices = provider.currentStats?.devices ?? [];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildConsoleChip(
            label: '全部集群 (${devices.length})',
            icon: Icons.grid_view_rounded,
            isSelected: provider.selectedDeviceId == null,
            isLight: isLight,
            onTap: () => provider.setSelectedDevice(null),
          ),
          const SizedBox(width: 8),
          ...devices.map((d) {
            final isSel = provider.selectedDeviceId == d.deviceId;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildConsoleChip(
                label: d.hostname,
                icon: Icons.developer_board_rounded,
                isSelected: isSel,
                isLight: isLight,
                onTap: () => provider.setSelectedDevice(d.deviceId),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConsoleChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isLight,
    required VoidCallback onTap,
  }) {
    final chipAccent = isLight ? AppColors.warmYellowDark : AppColors.cyan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? chipAccent.withOpacity(0.16)
              : (isLight ? const Color(0xFFEDF2F7) : AppColors.surface),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? chipAccent
                : (isLight ? const Color(0xFFCBD5E1) : AppColors.glassBorder),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipAccent.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? chipAccent
                  : (isLight ? AppColors.lightTextSecondary : AppColors.textMuted),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? chipAccent
                    : (isLight ? AppColors.lightTextPrimary : AppColors.textSecondary),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 右翼 Bento：额度雷达微组件
  Widget _buildQuotaRadarWidget(MonitorProvider provider, bool isLight) {
    if (provider.limits.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 14, color: AppColors.emerald),
              const SizedBox(width: 6),
              Text(
                '额度健康',
                style: TextStyle(
                  color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '100%',
            style: TextStyle(
              color: AppColors.emerald,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '所有服务正常',
            style: TextStyle(
              color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.emerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '已就绪',
              style: TextStyle(
                color: AppColors.emerald,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    // 寻找剩余百分比最低的额度项作为雷达聚焦
    LimitWindow? lowestWindow;
    String providerName = '';
    for (final item in provider.limits) {
      for (final win in item.windows) {
        if (lowestWindow == null || win.remainingPercent < lowestWindow.remainingPercent) {
          lowestWindow = win;
          providerName = item.name;
        }
      }
    }

    final p = lowestWindow?.remainingPercent ?? 100.0;
    final color = p > 50 ? AppColors.emerald : (p > 20 ? AppColors.amber : AppColors.rose);
    final winLabel = lowestWindow != null ? '$providerName · ${lowestWindow.label}' : '健康';
    final resetTime = lowestWindow?.formattedResetCountdown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_outlined, size: 14, color: AppColors.emerald),
                const SizedBox(width: 6),
                Text(
                  '额度雷达',
                  style: TextStyle(
                    color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${p.round()}',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                '%',
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          winLabel,
          style: TextStyle(
            color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (resetTime != null && resetTime.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$resetTime 重置',
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  /// AI 额度健康全景舱组件
  Widget _buildLimitsOverviewPod(MonitorProvider provider, bool isLight) {
    final List<Widget> gauges = [];
    for (final item in provider.limits) {
      if (item.windows.isNotEmpty) {
        for (final win in item.windows) {
          final title = item.windows.length > 1
              ? '${item.name} · ${win.label}'
              : item.name;
          gauges.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: RadialGauge(
                remainingPercent: win.remainingPercent,
                title: title,
                subtitle: (win.formattedResetCountdown != null && win.formattedResetCountdown!.isNotEmpty)
                    ? win.formattedResetCountdown!
                    : '正常',
                size: 58,
              ),
            ),
          );
        }
      } else {
        gauges.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: RadialGauge(
              remainingPercent: 100.0,
              title: item.name,
              subtitle: '已就绪',
              size: 58,
            ),
          ),
        );
      }
    }

    if (gauges.isEmpty) return const SizedBox.shrink();

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      enableCornerBolts: true,
      podTag: 'QUOTA RADAR // POD-03',
      glowColor: AppColors.glowEmerald,
      borderColor: AppColors.emerald.withOpacity(0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.speed_rounded, size: 16, color: AppColors.emerald),
                  const SizedBox(width: 6),
                  Text(
                    'AI 额度全景舱',
                    style: TextStyle(
                      color: isLight ? AppColors.lightTextPrimary : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Text(
                '多窗口监控',
                style: TextStyle(
                  color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: gauges),
          ),
        ],
      ),
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
