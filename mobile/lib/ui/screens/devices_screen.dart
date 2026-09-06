import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/monitor_provider.dart';
import '../../models/device_stats.dart';
import '../../theme/app_colors.dart';
import '../widgets/glass_container.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final stats = provider.currentStats;
    final settings = provider.settings;
    final devices = stats?.devices ?? [];
    final isLight = provider.isLightTheme;
    final accent = AppColors.getThemeAccent(isLight);

    return Scaffold(
      appBar: AppBar(
        title: const Text('已接入设备'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: accent),
            onPressed: () => provider.refreshNow(),
          ),
        ],
      ),

      body: devices.isEmpty
          ? const Center(
              child: Text('暂无接入设备信息', style: TextStyle(color: AppColors.textMuted)),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final dev = devices[index];
                final isOnline = !dev.stale;

                // 格式化平台与版本副标题
                final platformName = (dev.osName != null && dev.osName!.isNotEmpty)
                    ? dev.osName!
                    : _formatPlatformName(dev.platform);
                final versionText = (dev.agentVersion != null && dev.agentVersion!.isNotEmpty)
                    ? 'v${dev.agentVersion}'
                    : '';
                final platformSubtitle = versionText.isNotEmpty
                    ? '平台: $platformName · $versionText'
                    : '平台: $platformName';

                // 格式化今日花费
                final costUsd = dev.today.costUsd;
                final costFormatted = settings.currency == 'CNY'
                    ? '¥${(costUsd * settings.usdToCnyRate).toStringAsFixed(2)}'
                    : '\$${costUsd.toStringAsFixed(2)}';

                // 格式化今日 Token
                final tokensFormatted = _formatTokens(dev.today.totalTokens);

                // 活跃客户端列表
                final clientNames = dev.today.clients.keys.toList();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    enableCornerBolts: true,
                    podTag: '${dev.platform.toUpperCase()} // NODE',
                    glowColor: isOnline ? AppColors.glowCyan : null,
                    borderColor: isOnline ? AppColors.cyan.withOpacity(0.25) : AppColors.glassBorder,
                    topHighlightColor: AppColors.glassTopHighlightWarm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isLight ? const Color(0xFFF1F5F9) : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cyan.withOpacity(0.3), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.cyan.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getPlatformIcon(dev.platform),
                                color: AppColors.cyan,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dev.hostname,
                                    style: TextStyle(
                                      color: isLight ? AppColors.lightTextPrimary : AppColors.warmWhite,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    platformSubtitle,
                                    style: TextStyle(
                                      color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isOnline ? AppColors.emerald : AppColors.textMuted).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: (isOnline ? AppColors.emerald : AppColors.textMuted).withOpacity(0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isOnline ? AppColors.emerald : AppColors.textMuted,
                                      shape: BoxShape.circle,
                                      boxShadow: isOnline
                                          ? [
                                              BoxShadow(
                                                color: AppColors.emerald.withOpacity(0.8),
                                                blurRadius: 5,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isOnline ? '在线同步' : '离线',
                                    style: TextStyle(
                                      color: isOnline ? AppColors.emerald : AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Divider(color: isLight ? const Color(0xFFE2E8F0) : AppColors.glassBorder, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoCol('今日花费', costFormatted, isLight ? AppColors.warmYellowDark : AppColors.warmYellow, isLight),
                            _buildInfoCol('今日 Token', tokensFormatted, AppColors.cyan, isLight),
                            _buildInfoCol('活跃工具', '${clientNames.length} 款', isLight ? AppColors.lightTextPrimary : AppColors.warmWhite, isLight),
                          ],
                        ),
                        if (clientNames.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 5,
                            children: clientNames.map((c) {
                              final color = AppColors.getToolColor(c);
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: color.withOpacity(0.35), width: 0.6),
                                ),
                                child: Text(
                                  c,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoCol(String label, String value, Color valueColor, bool isLight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  String _formatPlatformName(String platform) {
    final lower = platform.toLowerCase();
    if (lower.startsWith('win')) return 'Windows';
    if (lower.startsWith('darwin') || lower.contains('mac')) return 'macOS';
    if (lower.startsWith('linux')) return 'Linux';
    return platform;
  }

  String _formatTokens(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  IconData _getPlatformIcon(String platform) {
    final lower = platform.toLowerCase();
    if (lower.contains('mac') || lower.contains('darwin')) return Icons.laptop_mac_rounded;
    if (lower.contains('win')) return Icons.laptop_windows_rounded;
    if (lower.contains('linux')) return Icons.terminal_rounded;
    return Icons.devices_rounded;
  }
}
