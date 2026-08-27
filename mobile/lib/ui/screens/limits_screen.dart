import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/monitor_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/glass_container.dart';

class LimitsScreen extends StatelessWidget {
  const LimitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final limits = provider.limits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 额度与余额'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.cyan),
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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderColor: _getProviderColor(item.id).withOpacity(0.4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _getProviderColor(item.id).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.bolt_rounded,
                                    size: 18,
                                    color: _getProviderColor(item.id),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (item.account != null)
                                      Text(
                                        item.account!,
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
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
                            return _buildBalanceRow(win);
                          }
                          return _buildProgressRow(win, _getProviderColor(item.id));
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBalanceRow(dynamic win) {
    final curSymbol = win.currency == 'CNY' ? '¥' : '\$';
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            win.label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          Text(
            '',
            style: const TextStyle(
              color: AppColors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(dynamic win, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                win.label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                '% 剩余',
                style: TextStyle(
                  color: activeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: win.remainingPercent / 100.0,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
              minHeight: 6,
            ),
          ),
          if (win.resetInFormatted != null) ...[
            const SizedBox(height: 4),
            Text(
              ' 后重置',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    final isOk = status == 'ok';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOk ? AppColors.emerald.withOpacity(0.15) : AppColors.rose.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOk ? '正常' : '耗尽',
        style: TextStyle(
          color: isOk ? AppColors.emerald : AppColors.rose,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getProviderColor(String id) {
    final lower = id.toLowerCase();
    if (lower.contains('claude')) return AppColors.amber;
    if (lower.contains('codex') || lower.contains('openai')) return AppColors.emerald;
    if (lower.contains('deepseek')) return AppColors.cyan;
    if (lower.contains('openrouter')) return AppColors.purple;
    return AppColors.indigo;
  }
}
