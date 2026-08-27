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
    final costStr = currency == 'CNY'
        ? '¥'
        : '\{costUsd.toStringAsFixed(2)}';

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 16,
      backgroundColor: AppColors.glassCard,
      onTap: onTap,
      child: Row(
        children: [
          // 图标容器
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: toolColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: toolColor.withOpacity(0.3), width: 1),
            ),
            alignment: Alignment.center,
            child: Icon(
              _getToolIcon(clientName),
              color: toolColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          // 工具名称与标签
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
                        fontSize: 13,
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
                const SizedBox(height: 2),
                Text(
                  _formatTokens(tokenCount),
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // 费用展示
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                costStr,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
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

  IconData _getToolIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('claude')) return Icons.bolt_rounded;
    if (lower.contains('cursor') || lower.contains('code')) return Icons.terminal_rounded;
    if (lower.contains('antigravity') || lower.contains('gemini')) return Icons.psychology_rounded;
    if (lower.contains('deepseek')) return Icons.hub_rounded;
    return Icons.code_rounded;
  }

  String _formatToolName(String name) {
    if (name.isEmpty) return 'Tool';
    return name[0].toUpperCase() + name.substring(1);
  }

  String _formatTokens(int count) {
    if (count >= 1000000) {
      return 'M Tokens';
    } else if (count >= 1000) {
      return 'K Tokens';
    }
    return ' Tokens';
  }
}
