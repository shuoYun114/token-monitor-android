import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/monitor_provider.dart';
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
                  'CONNECTED CLUSTER',
                  style: TextStyle(
                    color: isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'NODE TELEMETRY & HARDWARE',
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

      body: devices.isEmpty
          ? Center(
              child: Text(
                '暂无接入设备信息',
                style: TextStyle(
                  color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                ),
              ),
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
                    enableSwissAccent: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isLight ? const Color(0xFFF1F2F4) : const Color(0xFF18181D),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isLight ? const Color(0xFFD4D4D8) : const Color(0xFF27272A),
                                  width: 0.8,
                                ),
                              ),
                              child: Icon(
                                _getPlatformIcon(dev.platform),
                                color: accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dev.hostname,
                                    style: TextStyle(
                                      color: isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    platformSubtitle,
                                    style: TextStyle(
                                      color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: (isOnline ? AppColors.emerald : AppColors.swissDarkTextMuted).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(3), // 瑞士硬朗 3px
                                border: Border.all(
                                  color: (isOnline ? AppColors.emerald : AppColors.swissDarkTextMuted).withOpacity(0.35),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 4.5,
                                    height: 4.5,
                                    decoration: BoxDecoration(
                                      color: isOnline ? AppColors.emerald : AppColors.swissDarkTextMuted,
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isOnline ? '在线同步' : '离线',
                                    style: TextStyle(
                                      color: isOnline ? AppColors.emerald : AppColors.swissDarkTextMuted,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          color: isLight ? AppColors.swissLightBorder : AppColors.swissDarkBorder,
                          height: 1,
                          thickness: 0.8,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoCol('今日花费', costFormatted, accent, isLight),
                            _buildInfoCol('今日 Token', tokensFormatted, isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary, isLight),
                            _buildInfoCol('活跃工具', '${clientNames.length} 款', isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary, isLight),
                          ],
                        ),
                        if (clientNames.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: clientNames.map((c) {
                              final color = AppColors.getToolColor(c);
                              final label = AppColors.getToolLabel(c);
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(isLight ? 0.08 : 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: color.withOpacity(0.35), width: 0.8),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
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
            color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
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
