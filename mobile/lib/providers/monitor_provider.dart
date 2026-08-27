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
  String? selectedDeviceId;

  Timer? _pollingTimer;

  MonitorProvider(this._storage) {
    settings = _storage.loadSettings();
    _loadInitialCache();
    if (settings.hubUrl.trim().isNotEmpty) {
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
    final rawUrl = settings.hubUrl.trim();
    if (rawUrl.isEmpty) {
      syncStatus = SyncStatus.disconnected;
      errorMessage = '未配置 Hub URL';
      notifyListeners();
      return;
    }

    syncStatus = SyncStatus.connecting;
    errorMessage = null;
    notifyListeners();

    try {
      // 1. 先进行一次单次拉取
      final data = await _hubService.fetchStats(
        hubUrl: rawUrl,
        hubSecret: settings.hubSecret.trim(),
      );

      _handleStatsPayload(data);
      syncStatus = SyncStatus.connected;
      errorMessage = null;
      settings.isConnected = true;
      _storage.saveSettings(settings);
      notifyListeners();

      // 2. 开启 SSE 实时监听
      _hubService.startStreaming(
        hubUrl: rawUrl,
        hubSecret: settings.hubSecret.trim(),
        onData: (streamData) {
          _handleStatsPayload(streamData);
          syncStatus = SyncStatus.connected;
          notifyListeners();
        },
        onError: (err) {
          // SSE 出错降级为定时轮询
          _startPolling();
        },
      );

      // 3. 触发直连 API 额度探测
      _probeDirectLimits();
    } catch (e) {
      syncStatus = currentStats != null ? SyncStatus.offlineCache : SyncStatus.error;
      errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void _handleStatsPayload(Map<String, dynamic> payload) {
    // 兼容 SSE 格式: {"type":"stats", "stats":{...}} 与普通 GET 格式: {...}
    final Map<String, dynamic> statsMap = (payload.containsKey('stats') && payload['stats'] is Map)
        ? payload['stats'] as Map<String, dynamic>
        : payload;

    currentStats = AggregateStats.fromJson(statsMap);
    _storage.saveCachedStats(currentStats!, statsMap);

    // 解析 limits 数据
    if (statsMap['limits'] is List) {
      final list = (statsMap['limits'] as List<dynamic>)
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
      Duration(seconds: settings.refreshIntervalSeconds.clamp(5, 60)),
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
      syncStatus = SyncStatus.connected;
      errorMessage = null;
      _probeDirectLimits();
      notifyListeners();
    } catch (e) {
      if (currentStats == null) {
        syncStatus = SyncStatus.error;
      } else {
        syncStatus = SyncStatus.offlineCache;
      }
      errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
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
