import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/monitor_provider.dart';
import '../../services/currency_service.dart';
import '../../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/passport_relay_card.dart';
import 'qr_scan_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _hubUrlController;
  late TextEditingController _hubSecretController;
  late TextEditingController _openRouterKeyController;
  late TextEditingController _deepSeekKeyController;
  late TextEditingController _rateController;
  bool _isTesting = false;
  bool _isUpdatingRate = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<MonitorProvider>().settings;
    _hubUrlController = TextEditingController(text: settings.hubUrl);
    _hubSecretController = TextEditingController(text: settings.hubSecret);
    _openRouterKeyController = TextEditingController(text: settings.openRouterApiKey);
    _deepSeekKeyController = TextEditingController(text: settings.deepSeekApiKey);
    _rateController = TextEditingController(text: settings.usdToCnyRate.toStringAsFixed(4));
  }

  @override
  void dispose() {
    _hubUrlController.dispose();
    _hubSecretController.dispose();
    _openRouterKeyController.dispose();
    _deepSeekKeyController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final settings = provider.settings;
    final isLight = provider.isLightTheme;
    final accent = AppColors.getThemeAccent(isLight);
    final primaryText = isLight ? AppColors.lightTextPrimary : AppColors.textPrimary;
    final secondaryText = isLight ? AppColors.lightTextSecondary : AppColors.textSecondary;
    final mutedText = isLight ? AppColors.lightTextMuted : AppColors.textMuted;
    final inputBg = isLight ? AppColors.lightSurfaceSecondary : AppColors.surfaceLight;

    return Scaffold(
      backgroundColor: isLight ? AppColors.lightBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          '系统设置与配对',
          style: TextStyle(color: primaryText, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // AI Passport 硬件随身副屏 BLE 中继卡片
          const PassportRelayCard(),
          const SizedBox(height: 16),

          // 0. 主题模式切换卡片 (黑主题: 纯白+淡蓝 / 白主题: 纯白+暖黄)
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
            glowColor: accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '界面主题风格',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isLight ? '白主题 (暖黄)' : '黑主题 (冰蓝)',
                        style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '随时在黑曜石深邃模式与晨曦极简白模式之间无缝切换',
                  style: TextStyle(color: mutedText, fontSize: 11),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // 黑主题选项
                    Expanded(
                      child: GestureDetector(
                        onTap: () => provider.setThemeMode('dark'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF080A10),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !isLight ? AppColors.iceBlue : const Color(0x33FFFFFF),
                              width: !isLight ? 2 : 1,
                            ),
                            boxShadow: !isLight
                                ? [
                                    BoxShadow(
                                      color: AppColors.iceBlue.withOpacity(0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.dark_mode_rounded, color: AppColors.iceBlue, size: 20),
                                  if (!isLight)
                                    const Icon(Icons.check_circle_rounded, color: AppColors.iceBlue, size: 16),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '黑主题 (Dark)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '黑曜石底 + 冰蓝高光',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 白主题选项
                    Expanded(
                      child: GestureDetector(
                        onTap: () => provider.setThemeMode('light'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isLight ? AppColors.warmYellowDark : const Color(0x33CBD5E1),
                              width: isLight ? 2 : 1,
                            ),
                            boxShadow: isLight
                                ? [
                                    BoxShadow(
                                      color: AppColors.warmYellow.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.wb_sunny_rounded, color: AppColors.warmYellowDark, size: 20),
                                  if (isLight)
                                    const Icon(Icons.check_circle_rounded, color: AppColors.warmYellowDark, size: 16),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '白主题 (Light)',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '纯白底 + 暖黄高光',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Hub 连接配置卡片
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hub 聚合中心配置',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent.withOpacity(0.15),
                        foregroundColor: accent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QrScanScreen()),
                        );
                        if (result is Map) {
                          setState(() {
                            _hubUrlController.text = result['url']?.toString().trim() ?? '';
                            _hubSecretController.text = result['secret']?.toString().trim() ?? '';
                          });
                          _saveAndConnect(provider, settings);
                        }
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                      label: const Text('扫码配对', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField('Hub URL (如 http://[2409:...]:17321)', _hubUrlController, isLight: isLight, inputBg: inputBg),
                const SizedBox(height: 10),
                _buildTextField('Hub Secret 密钥 (在电脑端多设备同步查看)', _hubSecretController, obscureText: true, isLight: isLight, inputBg: inputBg),
                const SizedBox(height: 14),

                if (provider.errorMessage != null && provider.syncStatus == SyncStatus.error) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.rose.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.rose.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.rose, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: AppColors.rose, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: isLight ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isTesting ? null : () => _saveAndConnect(provider, settings),
                    child: _isTesting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isLight ? Colors.white : Colors.black,
                            ),
                          )
                        : const Text('保存并连接 Hub', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. 货币与汇率设置
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '货币与实时汇率换算',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('显示币种', style: TextStyle(color: secondaryText)),
                    DropdownButton<String>(
                      value: settings.currency,
                      dropdownColor: isLight ? AppColors.lightSurface : AppColors.surface,
                      items: [
                        DropdownMenuItem(
                          value: 'CNY',
                          child: Text('人民币 (¥ CNY)', style: TextStyle(color: primaryText)),
                        ),
                        DropdownMenuItem(
                          value: 'USD',
                          child: Text('美元 (\$ USD)', style: TextStyle(color: primaryText)),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          settings.currency = val;
                          provider.updateSettings(settings);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _rateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: primaryText, fontSize: 13, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          labelText: 'USD/CNY 汇率 (与桌面端同步)',
                          labelStyle: TextStyle(color: mutedText, fontSize: 12),
                          filled: true,
                          fillColor: inputBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                        onChanged: (val) {
                          final n = double.tryParse(val);
                          if (n != null && n > 0) {
                            settings.usdToCnyRate = n;
                            provider.updateSettings(settings);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: inputBg,
                        foregroundColor: accent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      onPressed: _isUpdatingRate
                          ? null
                          : () async {
                              setState(() => _isUpdatingRate = true);
                              final rate = await CurrencyService.fetchUsdToCnyRate();
                              setState(() => _isUpdatingRate = false);
                              if (rate != null) {
                                _rateController.text = rate.toStringAsFixed(4);
                                settings.usdToCnyRate = rate;
                                provider.updateSettings(settings);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('已同步最新汇率: 1 USD = ${rate.toStringAsFixed(4)} CNY')),
                                );
                              }
                            },
                      child: _isUpdatingRate
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('刷新汇率', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. 独立 API 额度密钥
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '手机独立 API 额度探测 (可选)',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField('OpenRouter Management API Key', _openRouterKeyController, obscureText: true, isLight: isLight, inputBg: inputBg),
                const SizedBox(height: 10),
                _buildTextField('DeepSeek API Key (查询余额)', _deepSeekKeyController, obscureText: true, isLight: isLight, inputBg: inputBg),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: BorderSide(color: accent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      settings.openRouterApiKey = _openRouterKeyController.text.trim();
                      settings.deepSeekApiKey = _deepSeekKeyController.text.trim();
                      provider.updateSettings(settings);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已更新 API 密钥并刷新额度')),
                      );
                    },
                    child: const Text('更新 API 额度探测'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. 版本与更新卡片
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '关于与更新',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(Icons.verified_rounded, size: 16, color: accent),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('移动端版本', style: TextStyle(color: mutedText, fontSize: 12)),
                    Text(
                      'v1.1.0 (永久固化签名版)',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('电脑端协议对齐', style: TextStyle(color: mutedText, fontSize: 12)),
                    const Text(
                      'v0.53.0 最新规范',
                      style: TextStyle(
                        color: AppColors.emerald,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: BorderSide(color: accent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: isLight ? AppColors.lightSurface : AppColors.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text('Token Monitor 更新详情', style: TextStyle(color: primaryText)),
                          content: Text(
                            'Token Monitor Android v1.1.0 重大更新：\n\n'
                            '• 新增「Token 账单」：支持切换日账单、月度账单、年度与全时期用量流水\n'
                            '• 新增「GitHub 贡献热力图」：7 行周级活跃网格，直观呈现每天 Token 消耗强度与下钻\n'
                            '• 新增「黑白双主题切换」：\n'
                            '  - 黑主题：黑曜石深黑底 + 冰蓝高光 (#38BDF8)\n'
                            '  - 白主题：纯净暖白底 + 暖黄高光 (#F59E0B / #FBBF24)\n'
                            '• 修复多项跨设备状态与配额展示细节，支持持久化离线缓存\n'
                            '• 永久固化官方签名，随时覆盖无缝升级',
                            style: TextStyle(color: secondaryText, fontSize: 13, height: 1.5),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('我知道了', style: TextStyle(color: accent)),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    label: const Text('查看本次更新特性与说明'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: Text(
              'Token Monitor for Android v1.1.0\n跨设备 AI 编程工具用量监控看板',
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedText, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  void _saveAndConnect(MonitorProvider provider, dynamic settings) async {
    setState(() {
      _isTesting = true;
    });

    String url = _hubUrlController.text.trim();
    if (url.isNotEmpty && !url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
      _hubUrlController.text = url;
    }

    settings.hubUrl = url;
    settings.hubSecret = _hubSecretController.text.trim();
    provider.updateSettings(settings);

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isTesting = false;
      });
      if (provider.syncStatus == SyncStatus.connected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.emerald,
            content: Text('🎉 Hub 连接成功！数据已实时同步'),
          ),
        );
      }
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    bool isLight = false,
    Color? inputBg,
  }) {
    final textPrimary = isLight ? AppColors.lightTextPrimary : AppColors.textPrimary;
    final textMuted = isLight ? AppColors.lightTextMuted : AppColors.textMuted;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textMuted, fontSize: 12),
        filled: true,
        fillColor: inputBg ?? (isLight ? AppColors.lightSurfaceSecondary : AppColors.surfaceLight),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

