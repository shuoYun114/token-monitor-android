import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'glass_container.dart';

/// 活跃模型用量与占比排行卡片
class ModelBreakdownCard extends StatelessWidget {
  final Map<String, int> models;
  final Map<String, double> modelCosts;
  final int totalTokens;
  final String currency;
  final double rate;

  const ModelBreakdownCard({
    super.key,
    required this.models,
    this.modelCosts = const {},
    required this.totalTokens,
    this.currency = 'CNY',
    this.rate = 6.7203,
  });

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) return const SizedBox.shrink();

    // 按 Token 消耗量从高到低排序
    final sortedEntries = models.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.hub_outlined, size: 16, color: AppColors.cyan),
                  SizedBox(width: 6),
                  Text(
                    '今日活跃模型',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '已记录 ${sortedEntries.length} 款模型',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 贯穿式多模型全景分段能量带 (西瓜同学 Energy Viz 法则)
          Container(
            height: 7,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: sortedEntries.map((e) {
                final p = totalTokens > 0 ? (e.value / totalTokens) : 0.0;
                if (p <= 0.005) return const SizedBox.shrink();
                final c = AppColors.getModelColor(e.key);
                return Expanded(
                  flex: (p * 1000).round().clamp(1, 1000),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0.6),
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          ...sortedEntries.map((entry) {
            final modelName = entry.key;
            final tokens = entry.value;
            final percent = totalTokens > 0 ? (tokens / totalTokens) : 0.0;
            final percentStr = (percent * 100).toStringAsFixed(percent >= 0.995 ? 0 : 1);
            final color = AppColors.getModelColor(modelName);

            final cost = modelCosts[modelName];
            String? costStr;
            if (cost != null && cost > 0) {
              costStr = currency == 'CNY'
                  ? '¥${(cost * rate).toStringAsFixed(2)}'
                  : '\$${cost.toStringAsFixed(2)}';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.6),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          modelName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTokens(tokens),
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: color.withOpacity(0.35), width: 0.6),
                        ),
                        child: Text(
                          '$percentStr%',
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 精致能量槽
                  Stack(
                    children: [
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percent.clamp(0.01, 1.0),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color.withOpacity(0.5), color],
                            ),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (costStr != null) ...[
                    const SizedBox(height: 3),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        costStr,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatTokens(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000.0).toStringAsFixed(2)}M';
    } else if (count >= 1000) {
      return '${(count / 1000.0).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
