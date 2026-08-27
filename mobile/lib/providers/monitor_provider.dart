import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../models/device_stats.dart';
import '../models/limit_provider.dart';
import '../services/hub_client_service.dart';
import '../services/limit_probe_service.dart';
import '../services/storage_service.dart';
import '../services/widget_sync_service.dart';

enum SyncStatus { disconnected, connecting, connected, offlineCache, error }

/// 全局监控数据与业务逻辑提供者
class MonitorProvider extends ChangeNotifier {
  final StorageService _storage;
  final HubClientService _hubService = HubClientService();
  final LimitProbeService _limitService = LimitProbeService();

  late AppSettings settings;
  AggregateStats? currentStats;
  List<LimitProviderItem> limits = [];
  SyncStatus syncStatus = SyncStatus.disconnected;
  String? errorMessage;
  String? selectedDeviceId; // null 表示 '全部设备'

  Timer? _pollingTimer;

  MonitorProvider(this._storage) {
    settings = _storage.loadSettings();
    _loadInitialCache();
    if (settings.hubUrl.isNotEmpty) {
      connectHub();
    }
  }

  void _loadInitialCache() {
    final cached = _storage.loadCachedStats();
    if (cached != null) {
      currentStats = cached;
      syncStatus = SyncStatus.offlineCache;
      notifyListeners();
    }
    limits = _storage.loadCachedLimits();
  }

  /// 连接 Hub
  Future<void> connectHub() async {
    if (settings.hubUrl.isEmpty) {
      syncStatus = SyncStatus.disconnected;
      notifyListeners();
      return;
    }

    syncStatus = SyncStatus.connecting;
    errorMessage = null;
    notifyListeners();

    try {
      // 1. 先进行一次单次拉取
      final data = await _hubService.fetchStats(
        hubUrl: settings.hubUrl,
        hubSecret: settings.hubSecret,
      );

      _handleStatsPayload(data);
      syncStatus = SyncStatus.connected;
      settings.isConnected = true;
      _storage.saveSettings(settings);
      notifyListeners();

      // 2. 开启 SSE 实时监听
      _hubService.startStreaming(
        hubUrl: settings.hubUrl,
        hubSecret: settings.hubSecret,
        onData: (streamData) {
          _handleStatsPayload(streamData);
          syncStatus = SyncStatus.connected;
          notifyListeners();
        },
        onError: (err) {
          // SSE 出错降级为定时轮询
          syncStatus = SyncStatus.connected;
          _startPolling();
        },
      );

      // 3. 触发直连 API 额度探测
      _probeDirectLimits();
    } catch (e) {
      syncStatus = currentStats != null ? SyncStatus.offlineCache : SyncStatus.error;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _handleStatsPayload(Map<String, dynamic> payload) {
    currentStats = AggregateStats.fromJson(payload);
    _storage.saveCachedStats(currentStats!, payload);

    // 解析返回的 limits 数据 (如果 Hub 包含了 limits)
    if (payload['limits'] is List) {
      final list = (payload['limits'] as List<dynamic>)
          .map((e) => LimitProviderItem.fromJson(e as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) {
        limits = list;
        _storage.saveCachedLimits(limits);
      }
    }

    // 触发 Android 桌面小组件刷新
    WidgetSyncService.updateWidgetData(
      today: getSelectedPeriodToday(),
      currency: settings.currency,
      rate: settings.usdToCnyRate,
      limits: limits,
    );
  }

  Future<void> _probeDirectLimits() async {
    final List<LimitProviderItem> directItems = [];

    if (settings.openRouterApiKey.isNotEmpty) {
      final item = await _limitService.probeOpenRouter(settings.openRouterApiKey);
      if (item != null) directItems.add(item);
    }

    if (settings.deepSeekApiKey.isNotEmpty) {
      final item = await _limitService.probeDeepSeek(settings.deepSeekApiKey);
      if (item != null) directItems.add(item);
    }

    if (directItems.isNotEmpty) {
      // 合并到现有限额列表
      for (var d in directItems) {
        limits.removeWhere((x) => x.id == d.id);
        limits.add(d);
      }
      _storage.saveCachedLimits(limits);
      notifyListeners();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      Duration(seconds: settings.refreshIntervalSeconds),
      (_) => refreshNow(),
    );
  }

  Future<void> refreshNow() async {
    if (settings.hubUrl.isEmpty) return;
    try {
      final data = await _hubService.fetchStats(
        hubUrl: settings.hubUrl,
        hubSecret: settings.hubSecret,
      );
      _handleStatsPayload(data);
      _probeDirectLimits();
    } catch (_) {}
  }

  void updateSettings(AppSettings newSettings) {
    settings = newSettings;
    _storage.saveSettings(settings);
    connectHub();
    notifyListeners();
  }

  void setSelectedDevice(String? deviceId) {
    selectedDeviceId = deviceId;
    notifyListeners();
  }

  // 辅助获取当前选定设备/全量的今日用量
  PeriodUsage getSelectedPeriodToday() {
    if (currentStats == null) return PeriodUsage();
    if (selectedDeviceId == null) {
      return currentStats!.today;
    }
    final dev = currentStats!.devices.firstWhere(
      (d) => d.deviceId == selectedDeviceId,
      orElse: () => currentStats!.devices.first,
    );
    return dev.today;
  }

  @override
  void dispose() {
    _hubService.stopStreaming();
    _pollingTimer?.cancel();
    super.dispose();
  }
}
