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

      _hubService.startStreaming(
        hubUrl: rawUrl,
        hubSecret: settings.hubSecret.trim(),
        onData: (streamData) {
          _handleStatsPayload(streamData);
          syncStatus = SyncStatus.connected;
          notifyListeners();
        },
        onError: (err) {
          _startPolling();
        },
      );

      _probeDirectLimits();
    } catch (e) {
      syncStatus = currentStats != null ? SyncStatus.offlineCache : SyncStatus.error;
      errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void _handleStatsPayload(Map<String, dynamic> payload) {
    final Map<String, dynamic> statsMap = (payload.containsKey('stats') && payload['stats'] is Map)
        ? payload['stats'] as Map<String, dynamic>
        : payload;

    currentStats = AggregateStats.fromJson(statsMap);
    _storage.saveCachedStats(currentStats!, statsMap);

    // 解析 limits 数据：支持根节点 limits 与各 devices[i].limits.providers
    final List<LimitProviderItem> parsedLimits = [];

    if (statsMap['limits'] is List) {
      for (var e in statsMap['limits'] as List) {
        if (e is Map<String, dynamic>) {
          parsedLimits.add(LimitProviderItem.fromJson(e));
        }
      }
    }

    if (currentStats != null) {
      for (var dev in currentStats!.devices) {
        if (dev.limits is Map && dev.limits!['providers'] is List) {
          for (var p in dev.limits!['providers'] as List) {
            if (p is Map<String, dynamic>) {
              final item = LimitProviderItem.fromJson(p);
              if (item.windows.isNotEmpty || item.status == 'ok') {
                parsedLimits.removeWhere((x) => x.id == item.id && x.accountEmail == item.accountEmail);
                parsedLimits.add(item);
              }
            }
          }
        }
      }
    }

    if (parsedLimits.isNotEmpty) {
      limits = parsedLimits;
      _storage.saveCachedLimits(limits);
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
      orElse: () => currentStats!.devices.isNotEmpty ? currentStats!.devices.first : DeviceRecord(
        deviceId: '',
        hostname: '',
        platform: '',
        updatedAt: '',
        today: PeriodUsage(),
        month: PeriodUsage(),
        allTime: PeriodUsage(),
      ),
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
