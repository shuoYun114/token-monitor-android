import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/app_settings.dart';
import '../models/device_stats.dart';
import '../models/limit_provider.dart';

/// 随身副屏 BLE 连接状态
enum PassportBleStatus {
  disconnected, // 未连接
  scanning,     // 正在扫描
  connecting,   // 正在连接
  connected,    // 已连接通信中
  error,        // 出现异常
}

/// AI Passport 硬件 BLE 随身副屏中继服务
class PassportRelayService {
  static final PassportRelayService _instance = PassportRelayService._internal();
  factory PassportRelayService() => _instance;
  PassportRelayService._internal();

  // 固件标准 Nordic UART Service (NUS) UUID
  static final Guid serviceUuid = Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
  static final Guid rxUuid = Guid("6e400002-b5a3-f393-e0a9-e50e24dcca9e"); // 手机 -> 开发板
  static final Guid txUuid = Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e"); // 开发板 -> 手机

  PassportBleStatus _status = PassportBleStatus.disconnected;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _rxCharacteristic;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connSubscription;
  String _errorMessage = '';
  DateTime? _lastSyncTime;

  // 状态变化回调
  final List<VoidCallback> _listeners = [];

  PassportBleStatus get status => _status;
  bool get isConnected => _status == PassportBleStatus.connected;
  String get errorMessage => _errorMessage;
  String? get connectedDeviceName => _connectedDevice?.platformName;
  String? get connectedDeviceAddress => _connectedDevice?.remoteId.str;
  DateTime? get lastSyncTime => _lastSyncTime;

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notify() {
    for (final l in List.from(_listeners)) {
      l();
    }
  }

  /// 开始自动扫描并连接 AI Passport 设备
  Future<void> startAutoScanAndConnect({Duration timeout = const Duration(seconds: 12)}) async {
    if (_status == PassportBleStatus.connected || _status == PassportBleStatus.connecting) return;

    // 检查蓝牙适配器
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      _errorMessage = '请先开启手机蓝牙';
      _status = PassportBleStatus.error;
      _notify();
      return;
    }

    _status = PassportBleStatus.scanning;
    _errorMessage = '';
    _notify();

    await FlutterBluePlus.stopScan();

    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
      for (final r in results) {
        final name = r.device.platformName.toLowerCase();
        // 匹配 AI Passport / Codex 蓝牙广播特征
        if (name.startsWith('codex-') ||
            name.startsWith('passport-') ||
            name.contains('passport') ||
            name.contains('folotoy') ||
            name.contains('buddy')) {
          await FlutterBluePlus.stopScan();
          _scanSubscription?.cancel();
          await connectToDevice(r.device);
          break;
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: timeout);
    } catch (e) {
      _errorMessage = '扫描蓝牙设备失败: $e';
      _status = PassportBleStatus.error;
      _notify();
    }
  }

  /// 扫描附近所有符合特征的设备列表
  Stream<List<ScanResult>> scanNearbyDevices({Duration timeout = const Duration(seconds: 8)}) {
    FlutterBluePlus.stopScan();
    FlutterBluePlus.startScan(timeout: timeout);
    return FlutterBluePlus.scanResults.map((results) {
      return results.where((r) {
        final name = r.device.platformName.toLowerCase();
        return name.isNotEmpty &&
            (name.startsWith('codex-') ||
             name.startsWith('passport-') ||
             name.contains('passport') ||
             name.contains('folotoy') ||
             name.contains('buddy'));
      }).toList();
    });
  }

  /// 连接指定 BLE 设备
  Future<void> connectToDevice(BluetoothDevice device) async {
    _status = PassportBleStatus.connecting;
    _connectedDevice = device;
    _errorMessage = '';
    _notify();

    try {
      await device.connect(autoConnect: false, timeout: const Duration(seconds: 15));

      // Android 下协商扩大 MTU 至 256
      if (Platform.isAndroid) {
        try {
          await device.requestMtu(256);
        } catch (_) {}
      }

      // 监听连接断开状态
      _connSubscription?.cancel();
      _connSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _status = PassportBleStatus.disconnected;
          _rxCharacteristic = null;
          _notify();
        }
      });

      // 发现 GATT 服务
      final services = await device.discoverServices();
      for (final s in services) {
        if (s.uuid == serviceUuid) {
          for (final c in s.characteristics) {
            if (c.uuid == rxUuid) {
              _rxCharacteristic = c;
            } else if (c.uuid == txUuid) {
              try {
                await c.setNotifyValue(true);
              } catch (_) {}
            }
          }
        }
      }

      if (_rxCharacteristic != null) {
        _status = PassportBleStatus.connected;
        _errorMessage = '';
        _notify();

        // 连上后第一条握手：为硬件对齐当前时区与网络时间戳
        await syncCurrentTime();
      } else {
        throw Exception('设备缺少 Nordic UART (NUS) RX 特征值');
      }
    } catch (e) {
      _errorMessage = '连接失败: $e';
      _status = PassportBleStatus.error;
      _rxCharacteristic = null;
      _notify();
    }
  }

  /// 向开发板下发时钟校准指令
  Future<void> syncCurrentTime() async {
    if (!isConnected || _rxCharacteristic == null) return;
    final now = DateTime.now();
    final unixTime = (now.millisecondsSinceEpoch / 1000).round();
    final tzOffset = now.timeZoneOffset.inSeconds;

    final payload = jsonEncode({
      "time": [unixTime, tzOffset]
    }) + "\n";

    await _sendRawPayload(payload);
  }

  /// 向开发板下发更新工牌个人档案信息 (姓名与账号/邮箱，ESP32 接收后将持久化写入 NVS Flash)
  Future<bool> updateProfile({
    required String name,
    required String owner,
  }) async {
    if (!isConnected || _rxCharacteristic == null) return false;

    try {
      final cleanName = name.trim().isEmpty
          ? "syhx114514"
          : (name.trim().length > 30 ? name.trim().substring(0, 30) : name.trim());
      final cleanOwner = owner.trim().isEmpty
          ? "syhx114514@gmail.com"
          : (owner.trim().length > 30 ? owner.trim().substring(0, 30) : owner.trim());

      // 严格匹配固件协议: {"cmd": "name", "name": "...", "value": "..."} 与 {"cmd": "owner", ...}
      final pName = jsonEncode({
        "cmd": "name",
        "name": cleanName,
        "value": cleanName,
      }) + "\n";

      final pOwner = jsonEncode({
        "cmd": "owner",
        "name": cleanOwner,
        "owner": cleanOwner,
        "value": cleanOwner,
      }) + "\n";

      await _sendRawPayload(pName);
      await Future.delayed(const Duration(milliseconds: 60));
      await _sendRawPayload(pOwner);
      return true;
    } catch (e) {
      debugPrint("[PassportRelay] 个人信息同步失败: $e");
      return false;
    }
  }

  /// 将手机端的聚合统计数据构建成与固件 100% 匹配的 JSON 并推送
  Future<bool> pushStatsSnapshot({
    required AggregateStats stats,
    required AppSettings settings,
    List<LimitProviderItem>? limits,
    String? statusMessage,
  }) async {
    if (!isConnected || _rxCharacteristic == null) return false;

    try {
      final today = stats.today;
      final tokensToday = today.totalTokens;
      final rate = settings.usdToCnyRate > 0 ? settings.usdToCnyRate : 7.2;
      final costTodayCents = (today.costUsd * rate * 100).round();
      final costTotalCents = (stats.allTime.costUsd * rate * 100).round();

      // 提取消耗最高的主力模型
      String primaryModel = "Gemini 3.8 Flash";
      int primaryTokens = 0;
      today.models.forEach((k, v) {
        if (v > primaryTokens) {
          primaryTokens = v;
          primaryModel = k;
        }
      });

      // 计算主力模型额度消耗百分比
      int primaryUsed = 15;
      int primaryResetTs = (DateTime.now().millisecondsSinceEpoch / 1000).round() + 18000;
      if (limits != null && limits.isNotEmpty) {
        for (final item in limits) {
          if (item.windows.isNotEmpty) {
            primaryUsed = item.windows.first.usedPercent.round().clamp(0, 100);
            if (item.windows.first.resetsAt != null) {
              try {
                primaryResetTs = (DateTime.parse(item.windows.first.resetsAt!).millisecondsSinceEpoch / 1000).round();
              } catch (_) {}
            }
            break;
          }
        }
      }

      // 构建工具/模型细分用量列表 (取前 8 个)
      final List<Map<String, dynamic>> toolsList = [];
      final sortedModels = today.models.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedModels.take(8)) {
        final mCostUsd = today.modelCosts[entry.key] ?? 0.0;
        final mCostCents = (mCostUsd * rate * 100).round();
        final usedPct = tokensToday > 0 ? ((entry.value / tokensToday) * 100).round() : 0;
        toolsList.add({
          "name": entry.key.length > 23 ? entry.key.substring(0, 23) : entry.key,
          "tokens_today": entry.value,
          "cost_cents": mCostCents,
          "used_percent": usedPct,
        });
      }

      final payloadMap = {
        "total": 1,
        "running": 0,
        "waiting": 0,
        "tokens": tokensToday,
        "tokens_today": tokensToday,
        "msg": statusMessage ?? "随身中继在线",
        "entries": ["$primaryModel: 剩余 ${100 - primaryUsed}%"],
        "codex": {
          "plan": "Google AI Pro",
          "primary_used": primaryUsed,
          "primary_window": 300,
          "primary_reset": primaryResetTs,
          "secondary_used": 0,
          "secondary_window": 10080,
          "secondary_reset": 0,
          "completion_seq": 0,
          "available": true,
        },
        "token_monitor": {
          "tokens_today": tokensToday,
          "tokens_total": stats.allTime.totalTokens > 0 ? stats.allTime.totalTokens : tokensToday,
          "cost_today_cents": costTodayCents,
          "cost_total_cents": costTotalCents > 0 ? costTotalCents : costTodayCents,
          "currency": "CNY",
          "active_tools_count": toolsList.length,
          "tools": toolsList,
        }
      };

      final payloadJson = jsonEncode(payloadMap) + "\n";
      await _sendRawPayload(payloadJson);
      _lastSyncTime = DateTime.now();
      _notify();
      return true;
    } catch (e) {
      debugPrint("[PassportRelay] 数据推送失败: $e");
      return false;
    }
  }

  /// 分片安全写入 BLE 特征值
  Future<void> _sendRawPayload(String rawString) async {
    if (_rxCharacteristic == null) return;
    final bytes = utf8.encode(rawString);
    const chunkSize = 64; // 保守分包尺寸，彻底规避 MTU 溢出
    for (int offset = 0; offset < bytes.length; offset += chunkSize) {
      final end = (offset + chunkSize < bytes.length) ? offset + chunkSize : bytes.length;
      final chunk = bytes.sublist(offset, end);
      await _rxCharacteristic!.write(chunk, withoutResponse: true);
      // 微小间隔保证 ESP32-C3 接收 FIFO 不堵塞
      await Future.delayed(const Duration(milliseconds: 12));
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    await _scanSubscription?.cancel();
    await _connSubscription?.cancel();
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _rxCharacteristic = null;
    _status = PassportBleStatus.disconnected;
    _notify();
  }

  void dispose() {
    _scanSubscription?.cancel();
    _connSubscription?.cancel();
    _connectedDevice?.disconnect();
    _listeners.clear();
  }
}
