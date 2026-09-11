import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/monitor_provider.dart';
import '../../providers/passport_relay_provider.dart';
import '../../services/passport_relay_service.dart';
import '../../theme/app_colors.dart';
import 'glass_container.dart';

/// AI Passport 随身极客副屏 BLE 中继控制与个人档案修改卡片
class PassportRelayCard extends StatefulWidget {
  const PassportRelayCard({super.key});

  @override
  State<PassportRelayCard> createState() => _PassportRelayCardState();
}

class _PassportRelayCardState extends State<PassportRelayCard> {
  late TextEditingController _nameController;
  late TextEditingController _ownerController;
  bool _isSavingProfile = false;
  bool _isProfileExpanded = true;

  @override
  void initState() {
    super.initState();
    final settings = context.read<MonitorProvider>().settings;
    _nameController = TextEditingController(text: settings.passportName);
    _ownerController = TextEditingController(text: settings.passportOwner);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final relay = context.watch<PassportRelayProvider>();
    final monitor = context.watch<MonitorProvider>();
    final isLight = Theme.of(context).brightness == Brightness.light;

    Color statusColor;
    String statusText;
    switch (relay.status) {
      case PassportBleStatus.connected:
        statusColor = const Color(0xFF64C987); // 极客荧光绿
        statusText = '已连接 · 实时中继中';
        break;
      case PassportBleStatus.scanning:
        statusColor = const Color(0xFFF1C75B); // 琥珀金
        statusText = '正在扫描周围副屏...';
        break;
      case PassportBleStatus.connecting:
        statusColor = const Color(0xFF5BA4F1); // 科技蓝
        statusText = '正在建立 GATT 连接...';
        break;
      case PassportBleStatus.error:
        statusColor = const Color(0xFFEF4B38); // 警示红
        statusText = relay.errorMessage.isNotEmpty ? relay.errorMessage : '连接异常';
        break;
      case PassportBleStatus.disconnected:
      default:
        statusColor = isLight ? AppColors.lightTextMuted : AppColors.textMuted;
        statusText = '未连接 (点击扫描绑定)';
        break;
    }

    final inputBg = isLight ? const Color(0xFFF1F5F9) : const Color(0xFF0D1017);
    final borderColor = isLight ? const Color(0xFFCBD5E1) : const Color(0xFF282D37);

    return GlassContainer(
      podTag: "HARDWARE-RELAY",
      enableCornerBolts: true,
      glowColor: relay.isConnected ? statusColor : null,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部栏：标题与状态呼吸灯
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (relay.isConnected ? statusColor : (isLight ? Colors.black12 : Colors.white10)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.devices_other_rounded,
                  size: 18,
                  color: relay.isConnected ? Colors.white : (isLight ? AppColors.lightTextPrimary : Colors.white70),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Passport 随身副屏',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isLight ? AppColors.lightTextPrimary : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 自动中继开关
              Switch(
                value: relay.autoSyncEnabled,
                activeColor: const Color(0xFF64C987),
                onChanged: (val) {
                  relay.toggleAutoSync(val);
                },
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
          ),
          const SizedBox(height: 14),

          // 设备详情卡片
          if (relay.isConnected) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isLight ? const Color(0x0A000000) : const Color(0x20000000),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isLight ? Colors.black.withOpacity(0.06) : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '设备识别码',
                        style: TextStyle(
                          fontSize: 10,
                          color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        relay.connectedDeviceName ?? 'AI-Passport-C3',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: isLight ? AppColors.lightTextPrimary : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '最近同步时间',
                        style: TextStyle(
                          fontSize: 10,
                          color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        relay.lastSyncTime != null
                            ? DateFormat('HH:mm:ss').format(relay.lastSyncTime!)
                            : '刚刚',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64C987),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ==================== 个人信息修改板块 ====================
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF14171F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF232936),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isProfileExpanded = !_isProfileExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1C75B),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '副屏工牌个人信息',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isLight ? AppColors.lightTextPrimary : const Color(0xFFF1C75B),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              _isProfileExpanded ? '收起' : '展开修改',
                              style: TextStyle(
                                fontSize: 11,
                                color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                              ),
                            ),
                            Icon(
                              _isProfileExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (_isProfileExpanded) ...[
                    const SizedBox(height: 12),
                    // 极客昵称输入
                    Text(
                      '极客昵称 / 姓名 (展示在工牌中央顶部)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isLight ? AppColors.lightTextSecondary : const Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _nameController,
                      maxLength: 30,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isLight ? AppColors.lightTextPrimary : Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBg,
                        isDense: true,
                        counterText: "",
                        hintText: '例如: syhx114514',
                        hintStyle: TextStyle(
                          color: isLight ? AppColors.lightTextMuted : Colors.white24,
                          fontSize: 12,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFFE17B52), width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    // 账号邮箱输入
                    Text(
                      '通行证账号 / 邮箱 (展示在副屏资产一栏)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isLight ? AppColors.lightTextSecondary : const Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _ownerController,
                      maxLength: 30,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isLight ? AppColors.lightTextPrimary : Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBg,
                        isDense: true,
                        counterText: "",
                        hintText: '例如: user@gmail.com',
                        hintStyle: TextStyle(
                          color: isLight ? AppColors.lightTextMuted : Colors.white24,
                          fontSize: 12,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFFE17B52), width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    // 保存并下发按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isSavingProfile
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.badge_rounded, size: 15),
                        label: Text(
                          _isSavingProfile ? '正在同步至副屏...' : '保存并下发至副屏工牌',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE17B52),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                        onPressed: _isSavingProfile
                            ? null
                            : () async {
                                final name = _nameController.text.trim();
                                final owner = _ownerController.text.trim();
                                if (name.isEmpty && owner.isEmpty) return;

                                setState(() {
                                  _isSavingProfile = true;
                                });

                                // 1. 本地持久化记忆
                                monitor.updatePassportProfile(name, owner);

                                // 2. BLE 下发到单片机
                                final ok = await relay.updateProfile(name: name, owner: owner);

                                if (mounted) {
                                  setState(() {
                                    _isSavingProfile = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ok
                                            ? '✓ 个人档案已同步至 AI Passport 硬件并持久保存！'
                                            : '✗ 下发失败，请确认设备处于连接状态',
                                      ),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: ok ? const Color(0xFF1E3A24) : Colors.red.shade900,
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 底部操作按钮组
          Row(
            children: [
              if (!relay.isConnected) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    icon: relay.isScanning || relay.isConnecting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.bluetooth_searching_rounded, size: 16),
                    label: Text(
                      relay.isScanning ? '正在扫描设备...' : (relay.isConnecting ? '正在连接...' : '扫描并直连副屏'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE17B52), // 极客暖橙
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: (relay.isScanning || relay.isConnecting)
                        ? null
                        : () => relay.autoConnect(),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.sync_rounded, size: 16),
                    label: const Text('立即同步用量', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B2A1E),
                      foregroundColor: const Color(0xFF64C987),
                      side: const BorderSide(color: Color(0xFF64C987), width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (monitor.currentStats != null) {
                        final ok = await relay.pushNow(
                          stats: monitor.currentStats!,
                          settings: monitor.settings,
                          limits: monitor.limits,
                          statusMessage: "手动同步就绪",
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok ? '✓ 数据已成功推送到 AI Passport 副屏' : '✗ 同步失败，请检查连接'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: ok ? const Color(0xFF1E3A24) : Colors.red.shade900,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.link_off_rounded, size: 16),
                  label: const Text('断开', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isLight ? AppColors.lightTextMuted : AppColors.textMuted,
                    side: BorderSide(
                      color: isLight ? Colors.black12 : Colors.white12,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => relay.disconnect(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
