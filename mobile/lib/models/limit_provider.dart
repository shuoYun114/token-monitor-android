/// AI 服务提供商额度窗口模型
class LimitWindow {
  final String label; // 5小时窗口 / 每周限额 / 月度限额
  final double usedPercent; // 已用百分比 0.0 - 100.0
  final double remainingPercent; // 剩余百分比 0.0 - 100.0
  final String? resetsAt; // 重置时间
  final String? resetInFormatted; // 重置倒计时 (如 '4h 12m')
  final double? balance; // 预付余额 (例如 $12.5 或 ¥85.0)
  final String? currency; // 币种 (USD, CNY)
  final String metric; // tokens, requests, credits, percent

  LimitWindow({
    required this.label,
    required this.usedPercent,
    required this.remainingPercent,
    this.resetsAt,
    this.resetInFormatted,
    this.balance,
    this.currency,
    this.metric = 'percent',
  });

  factory LimitWindow.fromJson(Map<String, dynamic> json) {
    final used = (json['usedPercent'] as num?)?.toDouble() ?? 0.0;
    final rem = (json['remainingPercent'] as num?)?.toDouble() ?? (100.0 - used);
    return LimitWindow(
      label: json['label']?.toString() ?? 'Session',
      usedPercent: used,
      remainingPercent: rem.clamp(0.0, 100.0),
      resetsAt: json['resetsAt']?.toString(),
      resetInFormatted: json['resetInFormatted']?.toString() ?? json['resetDescription']?.toString(),
      balance: (json['balance'] as num?)?.toDouble() ?? (json['balanceUsd'] as num?)?.toDouble(),
      currency: json['currency']?.toString() ?? 'USD',
      metric: json['metric']?.toString() ?? 'percent',
    );
  }

  /// 智能计算剩余重置倒计时文本 (如 "4小时 59分", "6天 6小时", "即将重置")
  String? get formattedResetCountdown {
    if (resetsAt != null && resetsAt!.trim().isNotEmpty) {
      try {
        final resetTime = DateTime.parse(resetsAt!).toLocal();
        final now = DateTime.now();
        final diff = resetTime.difference(now);

        if (diff.isNegative || diff.inSeconds <= 0) {
          return '即将重置';
        }
        if (diff.inDays > 0) {
          final hours = diff.inHours % 24;
          return hours > 0 ? '${diff.inDays}天 ${hours}小时' : '${diff.inDays}天';
        }
        if (diff.inHours > 0) {
          final mins = diff.inMinutes % 60;
          return mins > 0 ? '${diff.inHours}小时 ${mins}分' : '${diff.inHours}小时';
        }
        if (diff.inMinutes > 0) {
          return '${diff.inMinutes}分钟';
        }
        return '${diff.inSeconds}秒';
      } catch (_) {}
    }

    if (resetInFormatted != null && resetInFormatted!.trim().isNotEmpty) {
      final desc = resetInFormatted!.trim();
      final match = RegExp(r'in\s+([0-9]+\s+[a-zA-Z]+(?:,\s*[0-9]+\s+[a-zA-Z]+)?)', caseSensitive: false).firstMatch(desc);
      if (match != null) {
        return match.group(1);
      }
      return desc;
    }
    return null;
  }

  /// 格式化剩余百分比字符串 (如 "98.9%" 或 "100%")
  String get formattedPercent {
    if (remainingPercent % 1 == 0) {
      return '${remainingPercent.toInt()}%';
    }
    return '${remainingPercent.toStringAsFixed(1)}%';
  }
}

/// 单个 AI 提供商额度状态 (Claude, OpenAI, DeepSeek, Antigravity 等)
class LimitProviderItem {
  final String id;
  final String name;
  final String? account;
  final String status; // ok, warning, depleted, error
  final List<LimitWindow> windows;
  final String updatedAt;

  String? get accountEmail => account;

  LimitProviderItem({
    required this.id,
    required this.name,
    this.account,
    this.status = 'ok',
    this.windows = const [],
    required this.updatedAt,
  });

  factory LimitProviderItem.fromJson(Map<String, dynamic> json) {
    final winList = (json['windows'] as List<dynamic>?)
            ?.map((e) => LimitWindow.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final providerId = json['id']?.toString() ?? json['provider']?.toString() ?? '';
    final accountName = json['account']?.toString() ?? json['accountEmail']?.toString() ?? json['accountName']?.toString();
    final displayName = json['name']?.toString() ?? (providerId.isNotEmpty ? providerId[0].toUpperCase() + providerId.substring(1) : 'Provider');

    return LimitProviderItem(
      id: providerId,
      name: displayName,
      account: accountName,
      status: json['status']?.toString() ?? 'ok',
      windows: winList,
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}
