import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../models/device_stats.dart';
import '../models/limit_provider.dart';
import '../services/passport_relay_service.dart';

/// 随身副屏 Provider，暴露响应式状态与控制接口
class PassportRelayProvider extends ChangeNotifier {
  final PassportRelayService _service = PassportRelayService();
  bool _autoSyncEnabled = true;

  PassportRelayProvider() {
    _service.addListener(_onServiceChanged);
  }

  void _onServiceChanged() {
    notifyListeners();
  }

  PassportBleStatus get status => _service.status;
  bool get isConnected => _service.isConnected;
  bool get isScanning => _service.status == PassportBleStatus.scanning;
  bool get isConnecting => _service.status == PassportBleStatus.connecting;
  String get errorMessage => _service.errorMessage;
  String? get connectedDeviceName => _service.connectedDeviceName;
  String? get connectedDeviceAddress => _service.connectedDeviceAddress;
  DateTime? get lastSyncTime => _service.lastSyncTime;
  bool get autoSyncEnabled => _autoSyncEnabled;

  /// 开启或关闭自动同步
  void toggleAutoSync(bool enabled) {
    _autoSyncEnabled = enabled;
    notifyListeners();
  }

  /// 一键自动扫描并直连开发板
  Future<void> autoConnect() async {
    await _service.startAutoScanAndConnect();
  }

  /// 断开连接
  Future<void> disconnect() async {
    await _service.disconnect();
  }

  /// 校准开发板时间
  Future<void> syncTime() async {
    await _service.syncCurrentTime();
  }

  /// 立即手动推送当前最新 Token 数据至副屏
  Future<bool> pushNow({
    required AggregateStats stats,
    required AppSettings settings,
    List<LimitProviderItem>? limits,
    String? statusMessage,
  }) async {
    return await _service.pushStatsSnapshot(
      stats: stats,
      settings: settings,
      limits: limits,
      statusMessage: statusMessage,
    );
  }

  /// 在 MonitorProvider 收到新数据时静默触发自动同步
  void tryAutoSync({
    required AggregateStats? stats,
    required AppSettings settings,
    List<LimitProviderItem>? limits,
  }) {
    if (_autoSyncEnabled && isConnected && stats != null) {
      _service.pushStatsSnapshot(
        stats: stats,
        settings: settings,
        limits: limits,
      );
    }
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }
}
