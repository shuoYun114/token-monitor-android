import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/device_stats.dart';
import '../models/limit_provider.dart';

/// 负责 App 本地持久化与离线数据缓存
class StorageService {
  static const String _keySettings = 'token_monitor_settings';
  static const String _keyCachedStats = 'token_monitor_cached_stats';
  static const String _keyCachedLimits = 'token_monitor_cached_limits';
  static const String _keyLastSyncTime = 'token_monitor_last_sync_time';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // 设置读取与保存
  AppSettings loadSettings() {
    final raw = _prefs.getString(_keySettings);
    if (raw == null || raw.isEmpty) {
      return AppSettings();
    }
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_keySettings, jsonEncode(settings.toJson()));
  }

  // 离线统计数据缓存
  AggregateStats? loadCachedStats() {
    final raw = _prefs.getString(_keyCachedStats);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AggregateStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCachedStats(AggregateStats stats, Map<String, dynamic> rawJson) async {
    await _prefs.setString(_keyCachedStats, jsonEncode(rawJson));
    await _prefs.setString(_keyLastSyncTime, DateTime.now().toIso8601String());
  }

  // 离线额度数据缓存
  List<LimitProviderItem> loadCachedLimits() {
    final raw = _prefs.getString(_keyCachedLimits);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => LimitProviderItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCachedLimits(List<LimitProviderItem> limits) async {
    final listJson = limits.map((e) => {
      'id': e.id,
      'name': e.name,
      'account': e.account,
      'status': e.status,
      'updatedAt': e.updatedAt,
      'windows': e.windows.map((w) => {
        'label': w.label,
        'usedPercent': w.usedPercent,
        'remainingPercent': w.remainingPercent,
        'resetsAt': w.resetsAt,
        'resetInFormatted': w.resetInFormatted,
        'balance': w.balance,
        'currency': w.currency,
        'metric': w.metric,
      }).toList(),
    }).toList();
    await _prefs.setString(_keyCachedLimits, jsonEncode(listJson));
  }

  String? getLastSyncTime() {
    return _prefs.getString(_keyLastSyncTime);
  }
}
