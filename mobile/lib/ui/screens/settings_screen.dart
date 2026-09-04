import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/monitor_provider.dart';
import '../../services/currency_service.dart';
import '../../theme/app_colors.dart';
import '../widgets/glass_container.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('系统设置与配对'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hub 连接配置卡片
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hub 聚合中心配置',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan.withOpacity(0.2),
                        foregroundColor: AppColors.cyan,
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
                _buildTextField('Hub URL (如 http://[2409:...]:17321)', _hubUrlController),
                const SizedBox(height: 10),
                _buildTextField('Hub Secret 密钥 (在电脑端多设备同步查看)', _hubSecretController, obscureText: true),
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
                      backgroundColor: AppColors.cyan,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isTesting ? null : () => _saveAndConnect(provider, settings),
                    child: _isTesting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text('保存并连接 Hub', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 货币与汇率设置
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '货币与实时汇率换算',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('显示币种', style: TextStyle(color: AppColors.textSecondary)),
                    DropdownButton<String>(
                      value: settings.currency,
                      dropdownColor: AppColors.surface,
                      items: const [
                        DropdownMenuItem(value: 'CNY', child: Text('人民币 (¥ CNY)')),
                        DropdownMenuItem(value: 'USD', child: Text('美元 (\$ USD)')),
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
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          labelText: 'USD/CNY 汇率 (与桌面端同步)',
                          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
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
                        backgroundColor: AppColors.surfaceLight,
                        foregroundColor: AppColors.cyan,
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

          // 独立 API 额度密钥
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '手机独立 API 额度探测 (可选)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField('OpenRouter Management API Key', _openRouterKeyController, obscureText: true),
                const SizedBox(height: 10),
                _buildTextField('DeepSeek API Key (查询余额)', _deepSeekKeyController, obscureText: true),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cyan,
                      side: const BorderSide(color: AppColors.cyan),
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

          // 版本与更新卡片
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '关于与更新',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(Icons.verified_rounded, size: 16, color: AppColors.cyan),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('移动端版本', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    Text(
                      'v1.0.6 (永久固化签名版)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('电脑端协议对齐', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    Text(
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
                      foregroundColor: AppColors.cyan,
                      side: const BorderSide(color: AppColors.cyan),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('Token Monitor 更新详情', style: TextStyle(color: AppColors.textPrimary)),
                          content: const Text(
                            '已成功同步电脑端 GitHub 最新版 (v0.53.0) 核心规范：\n\n'
                            '• 新增今日活跃模型分布与排行 (Models Breakdown)\n'
                            '• 完美支持 Antigravity 等 Provider 的多额度窗口 (Gemini + Claude/GPT 并列仪表盘)\n'
                            '• 扩充对 Alibaba(通义千问)、Zed Editor、Unsloth Studio、Trae 等最新工具的识别\n'
                            '• 永久固化正式签名，随时直接覆盖安装更新',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('我知道了', style: TextStyle(color: AppColors.cyan)),
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

          const Center(
            child: Text(
              'Token Monitor for Android v1.0.6\n跨设备 AI 编程工具用量监控看板',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
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

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
