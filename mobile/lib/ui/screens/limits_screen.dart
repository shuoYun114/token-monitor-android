import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/monitor_provider.dart';
import '../../models/limit_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/glass_container.dart';

class LimitsScreen extends StatelessWidget {
  const LimitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final limits = provider.limits;
    final isLight = provider.isLightTheme;
    final accent = AppColors.getThemeAccent(isLight);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 额度与余额'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: accent),
            onPressed: () => provider.refreshNow(),
          ),
        ],
      ),

      body: limits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.speed_rounded, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  const Text('暂无 AI 额度提供商数据', style: TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  const Text('在设置中添加 API Key 或连接已配置 Limits 的 Hub',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: limits.length,
              itemBuilder: (context, index) {
                final item = limits[index];
                final provColor = _getProviderColor(item.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderColor: provColor.withOpacity(0.28),
                    glowColor: provColor.withOpacity(0.12),
                    topHighlightColor: AppColors.glassTopHighlightWarm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: provColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: provColor.withOpacity(0.35), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: provColor.withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _getProviderIcon(item.id),
                                    size: 20,
                                    color: provColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        color: isLight ? AppColors.lightTextPrimary : AppColors.warmWhite,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (item.account != null)
                                      Text(
                                        item.account!,
                                        style: TextStyle(
                                          color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            _buildStatusTag(item.status),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ...item.windows.map((win) {
                          if (win.metric == 'credits' && win.balance != null) {
                            return _buildBalanceRow(win, provColor, isLight);
                          }
                          return _buildProgressRow(win, provColor, isLight);
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBalanceRow(LimitWindow win, Color provColor, bool isLight) {
    final curSymbol = win.currency == 'CNY' ? '¥' : '\$';
    final balStr = win.balance != null ? '$curSymbol${win.balance!.toStringAsFixed(2)}' : '--';
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFFEF3C7).withOpacity(0.6) : AppColors.warmYellowCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLight ? AppColors.warmYellowDark.withOpacity(0.3) : AppColors.warmYellowBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            win.label,
            style: TextStyle(
              color: isLight ? AppColors.lightTextPrimary : AppColors.warmWhiteSoft,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            balStr,
            style: TextStyle(
              color: isLight ? AppColors.warmYellowDark : AppColors.warmYellow,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(LimitWindow win, Color activeColor, bool isLight) {
    final resetText = win.formattedResetCountdown;
    final percentVal = (win.remainingPercent / 100.0).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                win.label,
                style: TextStyle(
                  color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    win.formattedPercent,
                    style: TextStyle(
                      color: activeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '剩余',
                    style: TextStyle(
                      color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 7),
          // 能量槽
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isLight ? const Color(0xFFE2E8F0) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentVal,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [activeColor.withOpacity(0.6), activeColor],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (resetText != null && resetText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 11,
                  color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '$resetText 后重置',
                  style: TextStyle(
                    color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    final isOk = status == 'ok';
    final color = isOk ? AppColors.emerald : AppColors.rose;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.8),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isOk ? '服务正常' : '额度耗尽',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProviderColor(String id) {
    return AppColors.getToolColor(id);
  }

  IconData _getProviderIcon(String id) {
    final lower = id.toLowerCase();
    if (lower.contains('claude')) return Icons.psychology_rounded;
    if (lower.contains('cursor')) return Icons.code_rounded;
    if (lower.contains('antigravity')) return Icons.auto_awesome_mosaic_rounded;
    if (lower.contains('codex')) return Icons.terminal_rounded;
    if (lower.contains('copilot') || lower.contains('github')) return Icons.hub_rounded;
    if (lower.contains('alibaba') || lower.contains('qwen') || lower.contains('bailian')) return Icons.cloud_done_rounded;
    if (lower.contains('zed')) return Icons.code_off_rounded;
    if (lower.contains('unsloth')) return Icons.auto_awesome_rounded;
    if (lower.contains('trae')) return Icons.integration_instructions_rounded;
    if (lower.contains('volcengine') || lower.contains('doubao')) return Icons.bubble_chart_rounded;
    if (lower.contains('deepseek')) return Icons.explore_rounded;
    if (lower.contains('kimi')) return Icons.chat_bubble_outline_rounded;
    if (lower.contains('openrouter')) return Icons.alt_route_rounded;
    return Icons.bolt_rounded;
  }
}
