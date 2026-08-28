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
