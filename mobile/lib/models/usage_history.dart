import 'dart:math';

/// 单日 Token 消耗与账单记录
class DailyUsageRecord {
  final String date; // YYYY-MM-DD
  final int tokens;
  final double cost;
  final int messages;
  final int tokenIntensity; // 0-4 色阶
  final int costIntensity;  // 0-4 色阶
  final Map<String, dynamic> perClient;
  final Map<String, dynamic> perModel;
  final Map<String, dynamic> clientCosts;
  final Map<String, dynamic> modelCosts;

  // 便捷别名 getter，与 PeriodStats 统一对齐
  int get totalTokens => tokens;
  double get costUsd => cost;
  Map<String, dynamic> get clients => perClient;
  Map<String, dynamic> get models => perModel;

  DailyUsageRecord({
    required this.date,
    this.tokens = 0,
    this.cost = 0.0,
    this.messages = 0,
    this.tokenIntensity = 0,
    this.costIntensity = 0,
    this.perClient = const {},
    this.perModel = const {},
    this.clientCosts = const {},
    this.modelCosts = const {},
    int? totalTokens,
    double? costUsd,
    Map<String, dynamic>? clients,
    Map<String, dynamic>? models,
  })  : tokens = totalTokens ?? tokens,
        cost = costUsd ?? cost,
        perClient = clients ?? perClient,
        perModel = models ?? perModel;


  factory DailyUsageRecord.fromJson(Map<String, dynamic> json) {
    int parseNumToInt(dynamic v) {
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    double parseNumToDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return DailyUsageRecord(
      date: json['date']?.toString().substring(0, min(10, json['date'].toString().length)) ?? '',
      tokens: parseNumToInt(json['tokens'] ?? json['totalTokens']),
      cost: parseNumToDouble(json['cost'] ?? json['costUsd']),
      messages: parseNumToInt(json['messages']),
      tokenIntensity: parseNumToInt(json['tokenIntensity'] ?? json['intensity']),
      costIntensity: parseNumToInt(json['costIntensity'] ?? json['intensity']),
      perClient: json['perClient'] is Map ? Map<String, dynamic>.from(json['perClient']) : const {},
      perModel: json['perModel'] is Map ? Map<String, dynamic>.from(json['perModel']) : const {},
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'tokens': tokens,
    'cost': cost,
    'messages': messages,
    'tokenIntensity': tokenIntensity,
    'costIntensity': costIntensity,
    'perClient': perClient,
    'perModel': perModel,
  };
}

/// 单月用量汇总记录
class MonthlyUsageRecord {
  final String month; // YYYY-MM
  final int tokens;
  final double cost;
  final Map<String, dynamic> perClient;
  final Map<String, dynamic> perModel;

  int get totalTokens => tokens;
  double get costUsd => cost;
  Map<String, dynamic> get clients => perClient;
  Map<String, dynamic> get models => perModel;

  MonthlyUsageRecord({
    required this.month,
    this.tokens = 0,
    this.cost = 0.0,
    this.perClient = const {},
    this.perModel = const {},
    int? totalTokens,
    double? costUsd,
  })  : tokens = totalTokens ?? tokens,
        cost = costUsd ?? cost;

  factory MonthlyUsageRecord.fromJson(Map<String, dynamic> json) {
    return MonthlyUsageRecord(
      month: json['month']?.toString() ?? '',
      tokens: (json['tokens'] as num?)?.toInt() ?? (json['totalTokens'] as num?)?.toInt() ?? 0,
      cost: (json['cost'] as num?)?.toDouble() ?? (json['costUsd'] as num?)?.toDouble() ?? 0.0,
      perClient: json['perClient'] is Map ? Map<String, dynamic>.from(json['perClient']) : const {},
      perModel: json['perModel'] is Map ? Map<String, dynamic>.from(json['perModel']) : const {},
    );
  }

  Map<String, dynamic> toJson() => {
    'month': month,
    'tokens': tokens,
    'cost': cost,
    'perClient': perClient,
    'perModel': perModel,
  };
}

/// 全历史用量与打卡统计摘要
class HistorySummaryRecord {
  final int totalTokens;
  final double totalCost;
  final int activeDays;
  final int currentStreak;
  final int longestStreak;
  final int peakDayTokens;
  final String favoriteModel;

  double get totalCostUsd => totalCost;
  int get daysActive => activeDays;

  HistorySummaryRecord({
    this.totalTokens = 0,
    this.totalCost = 0.0,
    this.activeDays = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.peakDayTokens = 0,
    this.favoriteModel = '',
  });

  factory HistorySummaryRecord.fromJson(Map<String, dynamic>? json) {
    if (json == null) return HistorySummaryRecord();
    return HistorySummaryRecord(
      totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? (json['totalCostUsd'] as num?)?.toDouble() ?? 0.0,
      activeDays: (json['activeDays'] as num?)?.toInt() ?? (json['daysActive'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      peakDayTokens: (json['peakDayTokens'] as num?)?.toInt() ?? 0,
      favoriteModel: json['favoriteModel']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'totalTokens': totalTokens,
    'totalCost': totalCost,
    'activeDays': activeDays,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'peakDayTokens': peakDayTokens,
    'favoriteModel': favoriteModel,
  };
}


/// 聚合历史用量数据模型
class UsageHistory {
  final List<DailyUsageRecord> daily;
  final List<MonthlyUsageRecord> monthly;
  final HistorySummaryRecord summary;

  UsageHistory({
    this.daily = const [],
    this.monthly = const [],
    required this.summary,
  });

  factory UsageHistory.fromJson(Map<String, dynamic> json) {
    final dailyList = (json['daily'] as List<dynamic>?)
            ?.map((e) => DailyUsageRecord.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final monthlyList = (json['monthly'] as List<dynamic>?)
            ?.map((e) => MonthlyUsageRecord.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final summary = HistorySummaryRecord.fromJson(json['summary'] as Map<String, dynamic>?);

    return UsageHistory(
      daily: dailyList,
      monthly: monthlyList,
      summary: summary,
    );
  }

  Map<String, dynamic> toJson() => {
    'daily': daily.map((e) => e.toJson()).toList(),
    'monthly': monthly.map((e) => e.toJson()).toList(),
    'summary': summary.toJson(),
  };
}
