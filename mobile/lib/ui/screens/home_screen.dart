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
import '../widgets/receipt_dialog.dart';
import '../widgets/passport_relay_card.dart';
import '../../providers/passport_relay_provider.dart';


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
      backgroundColor: isLight ? AppColors.swissLightBg : AppColors.swissDarkBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(4), // 瑞士极简几何微标
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add, size: 16, color: Colors.white), // 纯正瑞士十字
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Token Monitor',
              style: TextStyle(
                color: isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary,
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '出小票 (Token Receipt)',
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            icon: Icon(
              Icons.receipt_long_rounded,
              color: accent,
              size: 20,
            ),
            onPressed: () {
              final primaryClient = today.clients.isNotEmpty ? today.clients.keys.first : null;
              final hostname = stats?.devices.isNotEmpty == true ? stats!.devices.first.hostname : 'Local Device';
              ReceiptDialog.show(
                context,
                ReceiptData(
                  title: 'TODAY TOKEN RECEIPT',
                  date: DateTime.now(),
                  hostname: hostname,
                  totalTokens: today.totalTokens,
                  costUsd: today.costUsd,
                  currency: settings.currency,
                  usdToCnyRate: settings.usdToCnyRate,
                  models: today.models,
                  modelCosts: today.modelCosts,
                  clients: today.clients,
                  clientCosts: today.clientCosts,
                  primaryClient: primaryClient,
                  cacheReadTokens: today.cacheReadTokens,
                  outputTokens: today.outputTokens,
                  unclassifiedTokens: today.unclassifiedTokens,
                  modelCacheReads: today.modelCacheReads,
                  modelOutputs: today.modelOutputs,
                  modelUnclassifiedTokens: today.modelUnclassifiedTokens,
                ),
              );
            },
          ),
          Consumer<PassportRelayProvider>(
            builder: (context, relay, _) {
              final isConn = relay.isConnected;
              return IconButton(
                tooltip: isConn ? 'AI Passport 已连接 (点击管理)' : '连接 AI Passport 随身副屏',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                icon: Icon(
                  Icons.devices_other_rounded,
                  color: isConn
                      ? const Color(0xFF10B981)
                      : (isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted),
                  size: 20,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (ctx) => Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                        top: 16,
                      ),
                      child: const PassportRelayCard(),
                    ),
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 16),
            child: StatusBadge(
              status: provider.syncStatus,
              errorMessage: provider.errorMessage,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: accent,
        backgroundColor: isLight ? AppColors.swissLightSurface : AppColors.swissDarkSurface,
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
            const SizedBox(height: 16),

            // =========================================================
            // 2. Bento Grid 双列次级情报舱 (Bento Aerospace Pods)
            // =========================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左翼：本月支出与累计趋势 (瑞士网格排版)
                Expanded(
                  child: GlassContainer(
                    enableSwissAccent: true,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 14, color: accent),
                            const SizedBox(width: 6),
                            Text(
                              '本月消耗',
                              style: TextStyle(
                                color: isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary,
                                fontSize: 12,
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
                              color: isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Token: ',
                              style: TextStyle(
                                color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                                fontSize: 10.5,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              _formatTokensShort(stats?.month.totalTokens ?? 0),
                              style: TextStyle(
                                color: accent,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: isLight ? const Color(0xFFF1F2F4) : const Color(0xFF18181D),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: isLight ? const Color(0xFFD4D4D8) : const Color(0xFF27272A),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '${today.clients.length} 款工具活跃',
                            style: TextStyle(
                              color: isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 右翼：AI 额度健康雷达 (瑞士网格排版)
                Expanded(
                  child: GlassContainer(
                    enableSwissAccent: true,
                    padding: const EdgeInsets.all(16),
                    child: _buildQuotaRadarWidget(provider, isLight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

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
                modelCacheReads: today.modelCacheReads,
                modelOutputs: today.modelOutputs,
                modelUnclassifiedTokens: today.modelUnclassifiedTokens,
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
                    Icon(Icons.terminal_rounded, size: 15, color: accent),
                    const SizedBox(width: 6),
                    Text(
                      '活跃工具控制台',
                      style: TextStyle(
                        color: isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFF1F2F4) : const Color(0xFF18181D),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isLight ? const Color(0xFFD4D4D8) : const Color(0xFF27272A),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '已就绪 ${today.clients.length} 款',
                    style: TextStyle(
                      color: isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary,
                      fontSize: 10,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
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
                child: Column(
                  children: [
                    Icon(Icons.inbox_rounded, size: 36, color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted),
                    const SizedBox(height: 8),
                    Text(
                      '今日暂无活跃工具调用日志',
                      style: TextStyle(
                        color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
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
    final chipAccent = AppColors.getThemeAccent(isLight);
    final borderCol = isLight ? AppColors.swissLightBorder : AppColors.swissDarkBorder;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? chipAccent.withOpacity(isLight ? 0.08 : 0.16)
              : (isLight ? AppColors.swissLightSurface : AppColors.swissDarkSurface),
          borderRadius: BorderRadius.circular(4), // 瑞士硬朗 4px
          border: Border.all(
            color: isSelected ? chipAccent : borderCol,
            width: isSelected ? 1.0 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: chipAccent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 5),
            ],
            Icon(
              icon,
              size: 12,
              color: isSelected
                  ? chipAccent
                  : (isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (isLight ? AppColors.swissLightTextPrimary : Colors.white)
                    : (isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary),
                fontSize: 10.5,
                fontFamily: 'monospace',
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 右翼 Bento：额度雷达微组件 (瑞士精密网格排版)
  Widget _buildQuotaRadarWidget(MonitorProvider provider, bool isLight) {
    if (provider.limits.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 13, color: AppColors.emerald),
              const SizedBox(width: 5),
              Text(
                '额度健康',
                style: TextStyle(
                  color: isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '100%',
            style: TextStyle(
              color: AppColors.emerald,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '所有服务正常',
            style: TextStyle(
              color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.emerald.withOpacity(isLight ? 0.08 : 0.15),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: AppColors.emerald.withOpacity(0.35),
                width: 0.8,
              ),
            ),
            child: const Text(
              '已就绪',
              style: TextStyle(
                color: AppColors.emerald,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
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
    final color = p > 50 ? AppColors.emerald : (p > 20 ? AppColors.amber : AppColors.swissRedBright);
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
                const Icon(Icons.shield_outlined, size: 13, color: AppColors.emerald),
                const SizedBox(width: 5),
                Text(
                  '额度雷达',
                  style: TextStyle(
                    color: isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(1),
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
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '%',
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          winLabel,
          style: TextStyle(
            color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
            fontSize: 9.5,
            fontFamily: 'monospace',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        if (resetTime != null && resetTime.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(isLight ? 0.08 : 0.15),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: color.withOpacity(0.35),
                width: 0.8,
              ),
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

  /// AI 额度健康全景舱组件 (瑞士发丝线网格排版)
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
              padding: const EdgeInsets.symmetric(horizontal: 5),
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
            padding: const EdgeInsets.symmetric(horizontal: 5),
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

    final accent = AppColors.getThemeAccent(isLight);

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      enableSwissAccent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.speed_rounded, size: 15, color: accent),
                  const SizedBox(width: 6),
                  Text(
                    'AI 额度全景',
                    style: TextStyle(
                      color: isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Text(
                '共 ${provider.limits.length} 款服务',
                style: TextStyle(
                  color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
