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
      backgroundColor: isLight ? AppColors.swissLightBg : AppColors.swissDarkBg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(4), // 瑞士极简几何微标
              ),
              child: const Center(
                child: Icon(Icons.add, size: 16, color: Colors.white), // 纯正瑞士十字
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI LIMITS & QUOTA',
                  style: TextStyle(
                    color: isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  '30+ PROVIDERS LIVE BALANCES',
                  style: TextStyle(
                    color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: accent, size: 21),
            onPressed: () => provider.refreshNow(),
          ),
        ],
      ),

      body: limits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.speed_rounded, size: 48, color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted),
                  const SizedBox(height: 12),
                  Text(
                    '暂无 AI 额度提供商数据',
                    style: TextStyle(
                      color: isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '在电脑端配置 AI Tool Limits 或连接支持额度的 Hub',
                    style: TextStyle(
                      color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: limits.length,
              itemBuilder: (context, index) {
                final item = limits[index];
                final provColor = AppColors.getToolColor(item.id);
                final provLabel = AppColors.getToolLabel(item.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
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
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: provColor.withOpacity(isLight ? 0.08 : 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: provColor.withOpacity(0.35), width: 0.8),
                                  ),
                                  child: Icon(
                                    AppColors.getToolIcon(item.id),
                                    size: 20,
                                    color: provColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provLabel,
                                      style: TextStyle(
                                        color: isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    if (item.account != null)
                                      Text(
                                        item.account!,
                                        style: TextStyle(
                                          color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                                          fontSize: 10,
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
    final accent = AppColors.getThemeAccent(isLight);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF1F2F4) : const Color(0xFF18181D),
        borderRadius: BorderRadius.circular(4), // 瑞士硬朗 4px
        border: Border.all(
          color: isLight ? AppColors.swissLightBorder : AppColors.swissDarkBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            win.label,
            style: TextStyle(
              color: isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            balStr,
            style: TextStyle(
              color: accent,
              fontSize: 15,
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
                  color: isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
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
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '剩余',
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
          const SizedBox(height: 6),
          // 能量槽 (瑞士平坦发丝轨)
          Stack(
            children: [
              Container(
                height: 5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentVal,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(2.5),
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
                  color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '$resetText 后重置',
                  style: TextStyle(
                    color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                    fontSize: 9.5,
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
    final color = isOk ? AppColors.emerald : AppColors.swissRedBright;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(3), // 瑞士硬朗 3px 微倒角
        border: Border.all(color: color.withOpacity(0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4.5,
            height: 4.5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isOk ? '服务正常' : '额度耗尽',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
