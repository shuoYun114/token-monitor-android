import 'package:flutter/material.dart';
import '../../models/device_stats.dart';
import '../../theme/app_colors.dart';
import 'glass_container.dart';

/// 活跃模型用量与占比排行卡片 (支持手风琴展开查看输入/输出/缓存细分遥测)
class ModelBreakdownCard extends StatefulWidget {
  final Map<String, int> models;
  final Map<String, double> modelCosts;
  final Map<String, int> modelCacheReads;
  final Map<String, int> modelOutputs;
  final Map<String, int> modelUnclassifiedTokens;
  final int totalTokens;
  final String currency;
  final double rate;

  const ModelBreakdownCard({
    super.key,
    required this.models,
    this.modelCosts = const {},
    this.modelCacheReads = const {},
    this.modelOutputs = const {},
    this.modelUnclassifiedTokens = const {},
    required this.totalTokens,
    this.currency = 'CNY',
    this.rate = 6.7203,
  });

  @override
  State<ModelBreakdownCard> createState() => _ModelBreakdownCardState();
}

class _ModelBreakdownCardState extends State<ModelBreakdownCard> {
  // 记录当前展开手风琴的模型集合
  final Set<String> _expandedModels = {};

  void _toggleExpand(String modelName) {
    setState(() {
      if (_expandedModels.contains(modelName)) {
        _expandedModels.remove(modelName);
      } else {
        _expandedModels.add(modelName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.models.isEmpty) return const SizedBox.shrink();

    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryTextColor = isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary;
    final mutedTextColor = isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted;
    final trackColor = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF18181D);
    final accent = AppColors.getThemeAccent(isLight);

    // 按 Token 消耗量从高到低排序
    final sortedEntries = widget.models.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
                  Icon(Icons.hub_outlined, size: 15, color: accent),
                  const SizedBox(width: 6),
                  Text(
                    '今日活跃模型',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Text(
                '点击查看细分',
                style: TextStyle(
                  color: mutedTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
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
              color: trackColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: sortedEntries.map((e) {
                final p = widget.totalTokens > 0 ? (e.value / widget.totalTokens) : 0.0;
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
            final percent = widget.totalTokens > 0 ? (tokens / widget.totalTokens) : 0.0;
            final percentStr = (percent * 100).toStringAsFixed(percent >= 0.995 ? 0 : 1);
            final color = AppColors.getModelColor(modelName);
            final isExpanded = _expandedModels.contains(modelName);

            final cost = widget.modelCosts[modelName];
            String? costStr;
            if (cost != null && cost > 0) {
              costStr = widget.currency == 'CNY'
                  ? '¥${(cost * widget.rate).toStringAsFixed(2)}'
                  : '\$${cost.toStringAsFixed(2)}';
            }

            final breakdown = TokenBreakdown.calculate(
              totalTokens: tokens,
              cacheReadTokens: widget.modelCacheReads[modelName] ?? 0,
              outputTokens: widget.modelOutputs[modelName] ?? 0,
              unclassifiedTokens: widget.modelUnclassifiedTokens[modelName] ?? 0,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _toggleExpand(modelName),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? (isLight ? const Color(0xFFF1F2F4) : const Color(0xFF18181D))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: isExpanded
                          ? Border.all(
                              color: isLight ? const Color(0xFFD4D4D8) : const Color(0xFF27272A),
                              width: 0.8,
                            )
                          : null,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isExpanded ? 8 : 2,
                      vertical: isExpanded ? 8 : 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                modelName,
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatTokens(tokens),
                              style: TextStyle(
                                color: accent,
                                fontSize: 11.5,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: color.withOpacity(isLight ? 0.08 : 0.15),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: color.withOpacity(0.35), width: 0.8),
                              ),
                              child: Text(
                                '$percentStr%',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 15,
                              color: mutedTextColor.withOpacity(0.7),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // 精致能量槽
                        Stack(
                          children: [
                            Container(
                              height: 3.5,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: trackColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percent.clamp(0.01, 1.0),
                              child: Container(
                                height: 3.5,
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
                              style: TextStyle(
                                color: isLight ? AppColors.warmYellowDark : AppColors.warmYellowSoft,
                                fontSize: 10,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],

                        // =======================================================
                        // 展开手风琴：输入(缓存命中/未命中)、输出与未分类微晶面板
                        // 完全对齐桌面版 Token Monitor 模型页显示规范
                        // =======================================================
                        if (isExpanded) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isLight ? Colors.white.withOpacity(0.8) : const Color(0xFF141A22),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF263238),
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildDetailRow(
                                  label: '输入 (缓存命中)',
                                  badge: '${breakdown.hitPct}%',
                                  badgeColor: isLight ? AppColors.warmYellowDark : AppColors.cyan,
                                  tokens: breakdown.cacheRead,
                                  primaryTextColor: primaryTextColor,
                                  mutedTextColor: mutedTextColor,
                                ),
                                const SizedBox(height: 6),
                                _buildDetailRow(
                                  label: '输入 (缓存未命中)',
                                  badge: '${breakdown.missPct}%',
                                  badgeColor: mutedTextColor,
                                  tokens: breakdown.cacheMiss,
                                  primaryTextColor: primaryTextColor,
                                  mutedTextColor: mutedTextColor,
                                ),
                                const SizedBox(height: 6),
                                _buildDetailRow(
                                  label: '输出',
                                  badge: null,
                                  badgeColor: null,
                                  tokens: breakdown.output,
                                  primaryTextColor: primaryTextColor,
                                  mutedTextColor: mutedTextColor,
                                ),
                                if (breakdown.unclassified > 0) ...[
                                  const SizedBox(height: 6),
                                  _buildDetailRow(
                                    label: '未分类',
                                    badge: null,
                                    badgeColor: null,
                                    tokens: breakdown.unclassified,
                                    primaryTextColor: primaryTextColor,
                                    mutedTextColor: mutedTextColor,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String? badge,
    required Color? badgeColor,
    required int tokens,
    required Color primaryTextColor,
    required Color mutedTextColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: mutedTextColor,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
                decoration: BoxDecoration(
                  color: (badgeColor ?? mutedTextColor).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor ?? mutedTextColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
        Text(
          _formatExactTokens(tokens),
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 11.5,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

  String _formatExactTokens(int count) {
    final str = count.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }
}
