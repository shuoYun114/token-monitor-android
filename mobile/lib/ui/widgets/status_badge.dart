import 'package:flutter/material.dart';
import '../../providers/monitor_provider.dart';
import '../../theme/app_colors.dart';

/// 顶部 Hub 连接状态小胶囊
class StatusBadge extends StatelessWidget {
  final SyncStatus status;
  final String? errorMessage;

  const StatusBadge({
    super.key,
    required this.status,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    String text;

    switch (status) {
      case SyncStatus.connected:
        dotColor = AppColors.emerald;
        text = 'Hub 已连接';
        break;
      case SyncStatus.connecting:
        dotColor = AppColors.amber;
        text = '连接中...';
        break;
      case SyncStatus.offlineCache:
        dotColor = AppColors.cyan;
        text = '离线缓存';
        break;
      case SyncStatus.error:
        dotColor = AppColors.rose;
        text = errorMessage != null && errorMessage!.contains('401')
            ? '401 密钥错误'
            : '连接失败';
        break;
      case SyncStatus.disconnected:
        dotColor = AppColors.textMuted;
        text = '未配对';
        break;
    }

    return Tooltip(
      message: errorMessage ?? text,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: dotColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(3), // 瑞士硬朗 3px 微倒角
          border: Border.all(color: dotColor.withOpacity(0.4), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: dotColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: dotColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
