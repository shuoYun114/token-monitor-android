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

    final cardBg = isLight ? AppColors.swissLightSurface : AppColors.swissDarkSurface;
    final borderColor = isLight ? AppColors.swissLightBorder : AppColors.swissDarkBorder;
    final toolNameColor = isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary;
    final costColor = isLight
        ? (costUsd > 0 ? AppColors.swissRed : AppColors.swissLightTextSecondary)
        : (costUsd > 0 ? AppColors.swissRedBright : AppColors.swissDarkTextSecondary);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: 6, // 瑞士硬朗 6px 微倒角
      borderColor: borderColor,
      backgroundColor: cardBg,
      onTap: onTap,
      child: Row(
        children: [
          // 左侧精密发丝色条
          Container(
            width: 2.5,
            height: 28,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: toolColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          // 工具专属图标 (几何平坦底座 + 发丝线边框)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: toolColor.withOpacity(isLight ? 0.08 : 0.14),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: toolColor.withOpacity(0.35), width: 0.8),
            ),
            alignment: Alignment.center,
            child: Icon(
              _getToolIcon(clientName),
              color: toolColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 4.5,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: AppColors.emerald,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTokens(tokenCount),
                  style: TextStyle(
                    color: isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // 今日金额展示 (瑞士高对比排版)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                costText,
                style: TextStyle(
                  color: costColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '今日消耗',
                style: TextStyle(
                  color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                  fontSize: 9.5,
                  fontFamily: 'monospace',
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
