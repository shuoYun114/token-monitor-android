import 'dart:convert';

/// 单个时期的用量统计 (今日/本月/历史总计)
class PeriodUsage {
  final int totalTokens;
  final double costUsd;
  final Map<String, int> clients;
  final Map<String, double> clientCosts;
  final Map<String, int> models;
  final Map<String, double> modelCosts;
  final int inputTokens;
  final int outputTokens;
  final int cacheReadTokens;

  PeriodUsage({
    this.totalTokens = 0,
    this.costUsd = 0.0,
    this.clients = const {},
    this.clientCosts = const {},
    this.models = const {},
    this.modelCosts = const {},
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.cacheReadTokens = 0,
  });

  factory PeriodUsage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PeriodUsage();

    Map<String, int> parseMapInt(dynamic map) {
      if (map is! Map) return {};
      return map.map((k, v) => MapEntry(k.toString(), (v is num) ? v.toInt() : 0));
    }

    Map<String, double> parseMapDouble(dynamic map) {
      if (map is! Map) return {};
      return map.map((k, v) => MapEntry(k.toString(), (v is num) ? v.toDouble() : 0.0));
    }

    return PeriodUsage(
      totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 0,
      costUsd: (json['costUsd'] as num?)?.toDouble() ?? 0.0,
      clients: parseMapInt(json['clients']),
      clientCosts: parseMapDouble(json['clientCosts']),
      models: parseMapInt(json['models']),
      modelCosts: parseMapDouble(json['modelCosts']),
      inputTokens: (json['inputTokens'] as num?)?.toInt() ?? 0,
      outputTokens: (json['outputTokens'] as num?)?.toInt() ?? 0,
      cacheReadTokens: (json['cacheReadTokens'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalTokens': totalTokens,
    'costUsd': costUsd,
    'clients': clients,
    'clientCosts': clientCosts,
    'models': models,
    'modelCosts': modelCosts,
    'inputTokens': inputTokens,
    'outputTokens': outputTokens,
    'cacheReadTokens': cacheReadTokens,
  };
}

/// 接入 Hub 的单台设备记录
class DeviceRecord {
  final String deviceId;
  final String hostname;
  final String platform;
  final String updatedAt;
  final String? agentVersion;
  final PeriodUsage today;
  final PeriodUsage month;
  final PeriodUsage allTime;
  final Map<String, dynamic>? limits;

  DeviceRecord({
    required this.deviceId,
    required this.hostname,
    required this.platform,
    required this.updatedAt,
    this.agentVersion,
    required this.today,
    required this.month,
    required this.allTime,
    this.limits,
  });

  factory DeviceRecord.fromJson(Map<String, dynamic> json) {
    return DeviceRecord(
      deviceId: json['deviceId']?.toString() ?? '',
      hostname: json['hostname']?.toString() ?? 'Unknown Device',
      platform: json['platform']?.toString() ?? 'unknown',
      updatedAt: json['updatedAt']?.toString() ?? '',
      agentVersion: json['agentVersion']?.toString(),
      today: PeriodUsage.fromJson(json['today'] as Map<String, dynamic>?),
      month: PeriodUsage.fromJson(json['month'] as Map<String, dynamic>?),
      allTime: PeriodUsage.fromJson(json['allTime'] as Map<String, dynamic>?),
      limits: json['limits'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'hostname': hostname,
    'platform': platform,
    'updatedAt': updatedAt,
    'agentVersion': agentVersion,
    'today': today.toJson(),
    'month': month.toJson(),
    'allTime': allTime.toJson(),
    'limits': limits,
  };
}

/// Hub 全量聚合统计数据
class AggregateStats {
  final PeriodUsage today;
  final PeriodUsage month;
  final PeriodUsage allTime;
  final List<DeviceRecord> devices;
  final String updatedAt;

  AggregateStats({
    required this.today,
    required this.month,
    required this.allTime,
    this.devices = const [],
    required this.updatedAt,
  });

  factory AggregateStats.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'] as Map<String, dynamic>? ?? json;
    final devicesList = (json['devices'] as List<dynamic>?)
            ?.map((e) => DeviceRecord.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return AggregateStats(
      today: PeriodUsage.fromJson(totals['today'] as Map<String, dynamic>?),
      month: PeriodUsage.fromJson(totals['month'] as Map<String, dynamic>?),
      allTime: PeriodUsage.fromJson(totals['allTime'] as Map<String, dynamic>?),
      devices: devicesList,
      updatedAt: json['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
