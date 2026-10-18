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
      backgroundColor: isLight ? AppColors.swissLightBg : AppColors.swissDarkBg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(4), // 瑞士极简几何微标
              ),
              child: const Center(
                child: Icon(Icons.add, size: 16, color: Colors.white), // 纯正瑞士十字
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM SETTINGS',
                  style: TextStyle(
                    color: isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'SYNC & HARDWARE CONTROL',
                  style: TextStyle(
                    color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // AI Passport 硬件随身副屏 BLE 中继卡片
          const PassportRelayCard(),
          const SizedBox(height: 16),

          // 0. 主题模式切换卡片 (瑞士曜黑 / 瑞士冷白)
          GlassContainer(
            padding: const EdgeInsets.all(16),
            enableSwissAccent: true,
            podTag: '00 // THEME PRESET',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '界面美学流派',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(isLight ? 0.08 : 0.15),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: accent.withOpacity(0.35), width: 0.8),
                      ),
                      child: Text(
                        isLight ? '瑞士冷白 (SWISS LIGHT)' : '瑞士曜黑 (SWISS DARK)',
                        style: TextStyle(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '遵循正统瑞士国际主义设计流派：硬朗发丝线骨架、等宽排版与瑞士精准红视觉点睛',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // 黑主题选项
                    Expanded(
                      child: GestureDetector(
                        onTap: () => provider.setThemeMode('dark'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.swissDarkSurface,
                            borderRadius: BorderRadius.circular(6), // 瑞士硬朗 6px
                            border: Border.all(
                              color: !isLight ? AppColors.swissRedBright : AppColors.swissDarkBorder,
                              width: !isLight ? 1.4 : 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.dark_mode_rounded, color: !isLight ? AppColors.swissRedBright : AppColors.swissDarkTextMuted, size: 18),
                                  if (!isLight)
                                    const Icon(Icons.check_circle_rounded, color: AppColors.swissRedBright, size: 16),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '瑞士曜黑 (Dark)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '纯粹深黑 + 瑞士精准红',
                                style: TextStyle(color: AppColors.swissDarkTextMuted, fontSize: 10, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 白主题选项
                    Expanded(
                      child: GestureDetector(
                        onTap: () => provider.setThemeMode('light'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.swissLightSurface,
                            borderRadius: BorderRadius.circular(6), // 瑞士硬朗 6px
                            border: Border.all(
                              color: isLight ? AppColors.swissRed : AppColors.swissLightBorder,
                              width: isLight ? 1.4 : 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.wb_sunny_rounded, color: isLight ? AppColors.swissRed : AppColors.swissLightTextMuted, size: 18),
                                  if (isLight)
                                    const Icon(Icons.check_circle_rounded, color: AppColors.swissRed, size: 16),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '瑞士冷白 (Light)',
                                style: TextStyle(
                                  color: AppColors.swissLightTextPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '理性冷白 + 纯黑等宽字阶',
                                style: TextStyle(color: AppColors.swissLightTextMuted, fontSize: 10, fontFamily: 'monospace'),
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

