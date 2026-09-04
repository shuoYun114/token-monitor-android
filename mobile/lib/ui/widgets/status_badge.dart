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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: dotColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dotColor.withOpacity(0.35), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: dotColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
