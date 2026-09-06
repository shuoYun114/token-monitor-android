import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'glass_container.dart';

/// 单个活跃 AI 工具卡片
class ToolCard extends StatelessWidget {
  final String clientName;
  final int tokenCount;
  final double costUsd;
  final String currency;
  final double rate;
  final VoidCallback? onTap;

  const ToolCard({
    super.key,
    required this.clientName,
    required this.tokenCount,
    required this.costUsd,
    this.currency = 'CNY',
    this.rate = 7.25,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final toolColor = AppColors.getToolColor(clientName);
    final costText = currency == 'CNY'
        ? '¥${(costUsd * rate).toStringAsFixed(2)}'
        : '\$${costUsd.toStringAsFixed(2)}';

    final cardBg = isLight ? AppColors.lightGlassCard : AppColors.glassCard;
    final toolNameColor = isLight ? AppColors.lightTextPrimary : AppColors.warmWhite;
    final costColor = isLight
        ? AppColors.warmYellowDark
        : ((costUsd > 0) ? AppColors.warmYellow : AppColors.warmWhite);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 14,
      borderColor: isLight ? AppColors.lightGlassBorder : toolColor.withOpacity(0.24),
      backgroundColor: cardBg,
      topHighlightColor: AppColors.glassTopHighlightWarm,
      onTap: onTap,
      child: Row(
        children: [
          // 左侧航天插槽微流光色条
          Container(
            width: 3,
            height: 32,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: toolColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: toolColor.withOpacity(0.6),
                  blurRadius: 6,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          // 工具专属图标 (带有内衬流光底板)
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: toolColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: toolColor.withOpacity(0.38), width: 1),
              boxShadow: [
                BoxShadow(
                  color: toolColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              _getToolIcon(clientName),
              color: toolColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // 工具名称与 Token 统计
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatToolName(clientName),
                      style: TextStyle(
                        color: toolNameColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emerald.withOpacity(0.8),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _formatTokens(tokenCount),
                  style: TextStyle(
                    color: isLight ? AppColors.lightTextSecondary : AppColors.cyan,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // 今日金额展示 (大于0展示温润暖黄)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                costText,
                style: TextStyle(
                  color: costColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '今日消耗',
                style: TextStyle(
                  color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  IconData _getToolIcon(String client) {
    final lower = client.toLowerCase();
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
    if (lower.contains('opencode')) return Icons.terminal_rounded;
    return Icons.bolt_rounded;
  }

  String _formatToolName(String client) {
    if (client.isEmpty) return 'Unknown';
    final lower = client.toLowerCase();
    if (lower == 'alibaba' || lower == 'bailian') return 'Alibaba Qwen';
    if (lower == 'zed') return 'Zed Editor';
    if (lower == 'unsloth') return 'Unsloth Studio';
    if (lower == 'volcengine') return 'Volcengine';
    if (lower == 'copilot') return 'GitHub Copilot';
    if (lower == 'opencode') return 'OpenCode';
    if (lower == 'antigravity') return 'Antigravity';
    return client[0].toUpperCase() + client.substring(1);
  }

  String _formatTokens(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000.0).toStringAsFixed(2)}M Tokens';
    } else if (count >= 1000) {
      return '${(count / 1000.0).toStringAsFixed(1)}K Tokens';
    }
    return '$count Tokens';
  }
}
