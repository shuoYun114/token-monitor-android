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
    final toolColor = AppColors.getToolColor(clientName);
    final costText = currency == 'CNY'
        ? '¥${(costUsd * rate).toStringAsFixed(2)}'
        : '\$${costUsd.toStringAsFixed(2)}';

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 16,
      backgroundColor: AppColors.glassCard,
      onTap: onTap,
      child: Row(
        children: [
          // 工具专属图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: toolColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: toolColor.withOpacity(0.35), width: 1),
            ),
            alignment: Alignment.center,
            child: Icon(
              _getToolIcon(clientName),
              color: toolColor,
              size: 20,
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTokens(tokenCount),
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // 今日金额展示
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                costText,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '今日用量',
                style: TextStyle(
                  color: AppColors.textMuted,
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
    switch (client.toLowerCase()) {
      case 'claude':
        return Icons.psychology_rounded;
      case 'cursor':
        return Icons.code_rounded;
      case 'codex':
      case 'copilot':
        return Icons.terminal_rounded;
      case 'antigravity':
        return Icons.psychology_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }

  String _formatToolName(String client) {
    if (client.isEmpty) return 'Unknown';
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
