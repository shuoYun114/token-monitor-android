import 'dart:convert';

/// Token 细分组成 (输入缓存命中、输入缓存未命中、输出、未分类)
class TokenBreakdown {
  final int total;
  final int cacheRead;
  final int cacheMiss;
  final int output;
  final int unclassified;
  final int totalInput;
  final int hitPct;
  final int missPct;

  const TokenBreakdown({
    required this.total,
    required this.cacheRead,
    required this.cacheMiss,
    required this.output,
    required this.unclassified,
    required this.totalInput,
    required this.hitPct,
    required this.missPct,
  });

  factory TokenBreakdown.calculate({
    required int totalTokens,
    int cacheReadTokens = 0,
    int outputTokens = 0,
    int unclassifiedTokens = 0,
  }) {
    final total = totalTokens < 0 ? 0 : totalTokens;
    final unclass = unclassifiedTokens.clamp(0, total);
    final classified = total - unclass;
    final read = cacheReadTokens.clamp(0, classified);
    final out = outputTokens.clamp(0, classified - read);
    final miss = (classified - read - out).clamp(0, classified);
    final input = read + miss;
    final hit = input > 0 ? ((read / input) * 100).round() : 0;
    final missRate = input > 0 ? (100 - hit) : 0;

    return TokenBreakdown(
      total: total,
      cacheRead: read,
      cacheMiss: miss,
      output: out,
      unclassified: unclass,
      totalInput: input,
      hitPct: hit,
      missPct: missRate,
    );
  }
}

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
  final int cacheWriteTokens;
  final int unclassifiedTokens;
  final Map<String, int> modelCacheReads;
  final Map<String, int> modelOutputs;
  final Map<String, int> modelUnclassifiedTokens;
  final Map<String, int> clientCacheReads;
  final Map<String, int> clientOutputs;
  final Map<String, int> clientUnclassifiedTokens;

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
    this.cacheWriteTokens = 0,
    this.unclassifiedTokens = 0,
    this.modelCacheReads = const {},
    this.modelOutputs = const {},
    this.modelUnclassifiedTokens = const {},
    this.clientCacheReads = const {},
    this.clientOutputs = const {},
    this.clientUnclassifiedTokens = const {},
  });

  /// 获取该时期的全局输入输出与缓存细分
  TokenBreakdown get breakdown => TokenBreakdown.calculate(
        totalTokens: totalTokens,
        cacheReadTokens: cacheReadTokens,
        outputTokens: outputTokens,
        unclassifiedTokens: unclassifiedTokens,
      );

  /// 获取指定模型的输入输出与缓存细分
  TokenBreakdown modelBreakdown(String modelName) {
    return TokenBreakdown.calculate(
      totalTokens: models[modelName] ?? 0,
      cacheReadTokens: modelCacheReads[modelName] ?? 0,
      outputTokens: modelOutputs[modelName] ?? 0,
      unclassifiedTokens: modelUnclassifiedTokens[modelName] ?? 0,
    );
  }

  /// 获取指定客户端的输入输出与缓存细分
  TokenBreakdown clientBreakdown(String clientName) {
    return TokenBreakdown.calculate(
      totalTokens: clients[clientName] ?? 0,
      cacheReadTokens: clientCacheReads[clientName] ?? 0,
      outputTokens: clientOutputs[clientName] ?? 0,
      unclassifiedTokens: clientUnclassifiedTokens[clientName] ?? 0,
    );
  }

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

    final total = (json['totalTokens'] as num?)?.toInt() ?? 0;
    final cacheRead = (json['cacheReadTokens'] as num?)?.toInt() ?? 0;
    final outTokens = (json['outputTokens'] as num?)?.toInt() ?? 0;
    final unclass = (json['unclassifiedTokens'] as num?)?.toInt() ?? 0;
    var inpTokens = (json['inputTokens'] as num?)?.toInt() ?? 0;
    if (inpTokens == 0 && (cacheRead > 0 || outTokens > 0)) {
      final bd = TokenBreakdown.calculate(
        totalTokens: total,
        cacheReadTokens: cacheRead,
        outputTokens: outTokens,
        unclassifiedTokens: unclass,
      );
      inpTokens = bd.totalInput;
    }

    return PeriodUsage(
      totalTokens: total,
      costUsd: (json['costUsd'] as num?)?.toDouble() ?? 0.0,
      clients: parseMapInt(json['clients']),
      clientCosts: parseMapDouble(json['clientCosts']),
      models: parseMapInt(json['models']),
      modelCosts: parseMapDouble(json['modelCosts']),
      inputTokens: inpTokens,
      outputTokens: outTokens,
      cacheReadTokens: cacheRead,
      cacheWriteTokens: (json['cacheWriteTokens'] as num?)?.toInt() ?? 0,
      unclassifiedTokens: unclass,
      modelCacheReads: parseMapInt(json['modelCacheReads']),
      modelOutputs: parseMapInt(json['modelOutputs']),
      modelUnclassifiedTokens: parseMapInt(json['modelUnclassifiedTokens']),
      clientCacheReads: parseMapInt(json['clientCacheReads']),
      clientOutputs: parseMapInt(json['clientOutputs']),
      clientUnclassifiedTokens: parseMapInt(json['clientUnclassifiedTokens']),
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
    'cacheWriteTokens': cacheWriteTokens,
    'unclassifiedTokens': unclassifiedTokens,
    'modelCacheReads': modelCacheReads,
    'modelOutputs': modelOutputs,
    'modelUnclassifiedTokens': modelUnclassifiedTokens,
    'clientCacheReads': clientCacheReads,
    'clientOutputs': clientOutputs,
    'clientUnclassifiedTokens': clientUnclassifiedTokens,
  };
}

/// 接入 Hub 的单台设备记录
class DeviceRecord {
  final String deviceId;
  final String hostname;
  final String platform;
  final String? osName;
  final String? osVersion;
  final String updatedAt;
  final String? agentVersion;
  final bool stale;
  final PeriodUsage today;
  final PeriodUsage month;
  final PeriodUsage allTime;
  final Map<String, dynamic>? limits;

  DeviceRecord({
    required this.deviceId,
    required this.hostname,
    required this.platform,
    this.osName,
    this.osVersion,
    required this.updatedAt,
    this.agentVersion,
    this.stale = false,
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
      osName: json['osName']?.toString(),
      osVersion: json['osVersion']?.toString(),
      updatedAt: json['updatedAt']?.toString() ?? '',
      agentVersion: json['agentVersion']?.toString(),
      stale: json['stale'] as bool? ?? false,
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
    'osName': osName,
    'osVersion': osVersion,
    'updatedAt': updatedAt,
    'agentVersion': agentVersion,
    'stale': stale,
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

      int sumInput = 0;
      int sumOutput = 0;
      int sumCacheRead = 0;
      int sumCacheWrite = 0;
      int sumUnclassified = 0;
      final Map<String, int> sumModelCacheReads = {};
      final Map<String, int> sumModelOutputs = {};
      final Map<String, int> sumModelUnclassified = {};
      final Map<String, int> sumClientCacheReads = {};
      final Map<String, int> sumClientOutputs = {};
      final Map<String, int> sumClientUnclassified = {};

      for (var d in devicesList) {
        sumTokens += d.today.totalTokens;
        sumCost += d.today.costUsd;
        sumInput += d.today.inputTokens;
        sumOutput += d.today.outputTokens;
        sumCacheRead += d.today.cacheReadTokens;
        sumCacheWrite += d.today.cacheWriteTokens;
        sumUnclassified += d.today.unclassifiedTokens;

        d.today.clients.forEach((k, v) => sumClients[k] = (sumClients[k] ?? 0) + v);
        d.today.clientCosts.forEach((k, v) => sumClientCosts[k] = (sumClientCosts[k] ?? 0.0) + v);
        d.today.models.forEach((k, v) => sumModels[k] = (sumModels[k] ?? 0) + v);
        d.today.modelCosts.forEach((k, v) => sumModelCosts[k] = (sumModelCosts[k] ?? 0.0) + v);

        d.today.modelCacheReads.forEach((k, v) => sumModelCacheReads[k] = (sumModelCacheReads[k] ?? 0) + v);
        d.today.modelOutputs.forEach((k, v) => sumModelOutputs[k] = (sumModelOutputs[k] ?? 0) + v);
        d.today.modelUnclassifiedTokens.forEach((k, v) => sumModelUnclassified[k] = (sumModelUnclassified[k] ?? 0) + v);
        d.today.clientCacheReads.forEach((k, v) => sumClientCacheReads[k] = (sumClientCacheReads[k] ?? 0) + v);
        d.today.clientOutputs.forEach((k, v) => sumClientOutputs[k] = (sumClientOutputs[k] ?? 0) + v);
        d.today.clientUnclassifiedTokens.forEach((k, v) => sumClientUnclassified[k] = (sumClientUnclassified[k] ?? 0) + v);
      }

      todayUsage = PeriodUsage(
        totalTokens: sumTokens,
        costUsd: sumCost,
        clients: sumClients,
        clientCosts: sumClientCosts,
        models: sumModels,
        modelCosts: sumModelCosts,
        inputTokens: sumInput,
        outputTokens: sumOutput,
        cacheReadTokens: sumCacheRead,
        cacheWriteTokens: sumCacheWrite,
        unclassifiedTokens: sumUnclassified,
        modelCacheReads: sumModelCacheReads,
        modelOutputs: sumModelOutputs,
        modelUnclassifiedTokens: sumModelUnclassified,
        clientCacheReads: sumClientCacheReads,
        clientOutputs: sumClientOutputs,
        clientUnclassifiedTokens: sumClientUnclassified,
      );
    } else if (todayUsage.models.isEmpty && devicesList.isNotEmpty) {
      final Map<String, int> sumModels = {};
      final Map<String, double> sumModelCosts = {};
      final Map<String, int> sumModelCacheReads = {};
      final Map<String, int> sumModelOutputs = {};
      final Map<String, int> sumModelUnclassified = {};

      for (var d in devicesList) {
        d.today.models.forEach((k, v) => sumModels[k] = (sumModels[k] ?? 0) + v);
        d.today.modelCosts.forEach((k, v) => sumModelCosts[k] = (sumModelCosts[k] ?? 0.0) + v);
        d.today.modelCacheReads.forEach((k, v) => sumModelCacheReads[k] = (sumModelCacheReads[k] ?? 0) + v);
        d.today.modelOutputs.forEach((k, v) => sumModelOutputs[k] = (sumModelOutputs[k] ?? 0) + v);
        d.today.modelUnclassifiedTokens.forEach((k, v) => sumModelUnclassified[k] = (sumModelUnclassified[k] ?? 0) + v);
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
          cacheWriteTokens: todayUsage.cacheWriteTokens,
          unclassifiedTokens: todayUsage.unclassifiedTokens,
          modelCacheReads: sumModelCacheReads,
          modelOutputs: sumModelOutputs,
          modelUnclassifiedTokens: sumModelUnclassified,
          clientCacheReads: todayUsage.clientCacheReads,
          clientOutputs: todayUsage.clientOutputs,
          clientUnclassifiedTokens: todayUsage.clientUnclassifiedTokens,
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
