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
    // 兼容 periods 嵌套与扁平结构
    final periods = json['periods'] as Map<String, dynamic>?;
    final todayMap = (periods?['today'] ?? json['today']) as Map<String, dynamic>?;
    final monthMap = (periods?['month'] ?? json['month']) as Map<String, dynamic>?;
    final allTimeMap = (periods?['allTime'] ?? json['allTime']) as Map<String, dynamic>?;

    return DeviceRecord(
      deviceId: json['deviceId']?.toString() ?? '',
      hostname: json['hostname']?.toString() ?? 'Unknown Device',
      platform: json['platform']?.toString() ?? 'unknown',
      updatedAt: json['updatedAt']?.toString() ?? '',
      agentVersion: json['agentVersion']?.toString(),
      today: PeriodUsage.fromJson(todayMap),
      month: PeriodUsage.fromJson(monthMap),
      allTime: PeriodUsage.fromJson(allTimeMap),
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
    final periods = json['periods'] as Map<String, dynamic>?;

    final devicesList = (json['devices'] as List<dynamic>?)
            ?.map((e) => DeviceRecord.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // 优先从根节点或 totals/periods 中提取今日/本月数据
    var todayUsage = PeriodUsage.fromJson(
      (periods?['today'] ?? totals['today'] ?? json['today']) as Map<String, dynamic>?,
    );
    var monthUsage = PeriodUsage.fromJson(
      (periods?['month'] ?? totals['month'] ?? json['month']) as Map<String, dynamic>?,
    );
    var allTimeUsage = PeriodUsage.fromJson(
      (periods?['allTime'] ?? totals['allTime'] ?? json['allTime']) as Map<String, dynamic>?,
    );

    // 如果聚合根节点为 0 但设备列表中有数据，自动聚合并汇总各设备
    if (todayUsage.totalTokens == 0 && devicesList.isNotEmpty) {
      int sumTokens = 0;
      double sumCost = 0.0;
      final Map<String, int> sumClients = {};
      final Map<String, double> sumClientCosts = {};

      final Map<String, int> sumModels = {};
      final Map<String, double> sumModelCosts = {};

      for (var d in devicesList) {
        sumTokens += d.today.totalTokens;
        sumCost += d.today.costUsd;
        d.today.clients.forEach((k, v) => sumClients[k] = (sumClients[k] ?? 0) + v);
        d.today.clientCosts.forEach((k, v) => sumClientCosts[k] = (sumClientCosts[k] ?? 0.0) + v);
        d.today.models.forEach((k, v) => sumModels[k] = (sumModels[k] ?? 0) + v);
        d.today.modelCosts.forEach((k, v) => sumModelCosts[k] = (sumModelCosts[k] ?? 0.0) + v);
      }

      todayUsage = PeriodUsage(
        totalTokens: sumTokens,
        costUsd: sumCost,
        clients: sumClients,
        clientCosts: sumClientCosts,
        models: sumModels,
        modelCosts: sumModelCosts,
      );
    } else if (todayUsage.models.isEmpty && devicesList.isNotEmpty) {
      final Map<String, int> sumModels = {};
      final Map<String, double> sumModelCosts = {};
      for (var d in devicesList) {
        d.today.models.forEach((k, v) => sumModels[k] = (sumModels[k] ?? 0) + v);
        d.today.modelCosts.forEach((k, v) => sumModelCosts[k] = (sumModelCosts[k] ?? 0.0) + v);
      }
      if (sumModels.isNotEmpty) {
        todayUsage = PeriodUsage(
          totalTokens: todayUsage.totalTokens,
          costUsd: todayUsage.costUsd,
          clients: todayUsage.clients,
          clientCosts: todayUsage.clientCosts,
          models: sumModels,
          modelCosts: sumModelCosts,
          inputTokens: todayUsage.inputTokens,
          outputTokens: todayUsage.outputTokens,
          cacheReadTokens: todayUsage.cacheReadTokens,
        );
      }
    }

    if (monthUsage.totalTokens == 0 && devicesList.isNotEmpty) {
      int sumTokens = 0;
      double sumCost = 0.0;
      for (var d in devicesList) {
        sumTokens += d.month.totalTokens;
        sumCost += d.month.costUsd;
      }
      monthUsage = PeriodUsage(totalTokens: sumTokens, costUsd: sumCost);
    }

    return AggregateStats(
      today: todayUsage,
      month: monthUsage,
      allTime: allTimeUsage,
      devices: devicesList,
      updatedAt: json['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
