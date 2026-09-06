import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/device_stats.dart';
import '../../models/usage_history.dart';
import '../../providers/monitor_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/github_heatmap.dart';
import '../widgets/glass_container.dart';
import '../widgets/receipt_dialog.dart';

/// Token 周期账单与每日流水屏幕 (支持 日/月/年 切换与 GitHub 热力图)
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  // 0: 日账单, 1: 月度账单, 2: 年度/总览
  int _selectedPeriodIndex = 0;
  // 当前选中的特定日期 (默认今天)
  String? _selectedDateKey;

  @override
  void initState() {
    super.initState();
    _selectedDateKey = _todayDateString();
  }

  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _currentMonthString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
  }

  String _formatTokens(int tokens) {
    if (tokens >= 1000000000) {
      return '${(tokens / 1000000000).toStringAsFixed(2)}B';
    } else if (tokens >= 1000000) {
      return '${(tokens / 1000000).toStringAsFixed(2)}M';
    } else if (tokens >= 1000) {
      return '${(tokens / 1000).toStringAsFixed(1)}K';
    }
    return tokens.toString();
  }

  int _extractTokens(dynamic v) {
    if (v is num) return v.toInt();
    if (v is Map) {
      final t = v['tokens'] ?? v['totalTokens'];
      if (t is num) return t.toInt();
      if (t is String) return int.tryParse(t) ?? 0;
    }
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  double _extractCost(dynamic v, [Map<String, dynamic>? costMap, String? key]) {
    if (costMap != null && key != null && costMap.containsKey(key)) {
      final c = costMap[key];
      if (c is num) return c.toDouble();
      if (c is String) return double.tryParse(c) ?? 0.0;
    }
    if (v is Map) {
      final c = v['cost'] ?? v['costUsd'];
      if (c is num) return c.toDouble();
      if (c is String) return double.tryParse(c) ?? 0.0;
    }
    if (v is num) return v.toDouble();
    return 0.0;
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final isLight = provider.isLightTheme;
    final accent = AppColors.getThemeAccent(isLight);

    final history = provider.history;
    final currentStats = provider.currentStats;

    // 获取所有每日记录，若 history 为空则从 currentStats.today 构造单日记录保底
    final List<DailyUsageRecord> dailyRecords = history?.daily.isNotEmpty == true
        ? history!.daily
        : [
            if (currentStats != null)
              DailyUsageRecord(
                date: _todayDateString(),
                totalTokens: currentStats.today.totalTokens,
                costUsd: currentStats.today.costUsd,
                clients: currentStats.today.clients,
                clientCosts: currentStats.today.clientCosts,
                models: currentStats.today.models,
                modelCosts: currentStats.today.modelCosts,
              )
          ];

    // 获取当前选中的日记录
    DailyUsageRecord? activeDailyRecord;
    for (var r in dailyRecords) {
      if (r.date == _selectedDateKey) {
        activeDailyRecord = r;
        break;
      }
    }
    activeDailyRecord ??= dailyRecords.isNotEmpty ? dailyRecords.last : null;

    final primaryText = isLight ? AppColors.lightTextPrimary : AppColors.textPrimary;
    final secondaryText = isLight ? AppColors.lightTextSecondary : AppColors.textSecondary;
    final mutedText = isLight ? AppColors.lightTextMuted : AppColors.textMuted;
    final cardBg = isLight ? AppColors.lightGlassCard : AppColors.glassCard;

    return Scaffold(
      backgroundColor: isLight ? AppColors.lightBackground : AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'TOKEN 账单',
              style: TextStyle(
                color: primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '出消费小票 (Token Receipt)',
            icon: Icon(Icons.receipt_long_rounded, color: accent, size: 21),
            onPressed: () {
              final hostname = currentStats?.devices.isNotEmpty == true
                  ? currentStats!.devices.first.hostname
                  : 'Local Device';
              final settings = provider.settings;

              if (_selectedPeriodIndex == 0) {
                final rec = activeDailyRecord;
                final models = rec != null ? rec.models.map((k, v) => MapEntry(k, _extractTokens(v))) : (currentStats?.today.models ?? {});
                final modelCosts = rec != null ? rec.modelCosts : (currentStats?.today.modelCosts ?? {});
                final clients = rec != null ? rec.clients.map((k, v) => MapEntry(k, _extractTokens(v))) : (currentStats?.today.clients ?? {});
                final clientCosts = rec != null ? rec.clientCosts : (currentStats?.today.clientCosts ?? {});
                final primaryClient = clients.isNotEmpty ? clients.keys.first : null;

                ReceiptDialog.show(
                  context,
                  ReceiptData(
                    title: 'DAILY TOKEN RECEIPT',
                    date: _selectedDateKey != null ? DateTime.tryParse(_selectedDateKey!) ?? DateTime.now() : DateTime.now(),
                    hostname: hostname,
                    totalTokens: rec?.totalTokens ?? currentStats?.today.totalTokens ?? 0,
                    costUsd: rec?.costUsd ?? currentStats?.today.costUsd ?? 0.0,
                    currency: settings.currency,
                    usdToCnyRate: settings.usdToCnyRate,
                    models: models,
                    modelCosts: modelCosts,
                    clients: clients,
                    clientCosts: clientCosts,
                    primaryClient: primaryClient,
                  ),
                );
              } else {
                final month = currentStats?.month;
                final primaryClient = month?.clients.isNotEmpty == true ? month!.clients.keys.first : null;
                ReceiptDialog.show(
                  context,
                  ReceiptData(
                    title: _selectedPeriodIndex == 1 ? 'MONTHLY TOKEN RECEIPT' : 'ALL-TIME TOKEN RECEIPT',
                    date: DateTime.now(),
                    hostname: hostname,
                    totalTokens: _selectedPeriodIndex == 1 ? (month?.totalTokens ?? 0) : (currentStats?.allTime.totalTokens ?? 0),
                    costUsd: _selectedPeriodIndex == 1 ? (month?.costUsd ?? 0.0) : (currentStats?.allTime.costUsd ?? 0.0),
                    currency: settings.currency,
                    usdToCnyRate: settings.usdToCnyRate,
                    models: _selectedPeriodIndex == 1 ? (month?.models ?? {}) : (currentStats?.allTime.models ?? {}),
                    modelCosts: _selectedPeriodIndex == 1 ? (month?.modelCosts ?? {}) : (currentStats?.allTime.modelCosts ?? {}),
                    clients: _selectedPeriodIndex == 1 ? (month?.clients ?? {}) : (currentStats?.allTime.clients ?? {}),
                    clientCosts: _selectedPeriodIndex == 1 ? (month?.clientCosts ?? {}) : (currentStats?.allTime.clientCosts ?? {}),
                    primaryClient: primaryClient,
                  ),
                );
              }
            },
          ),
          IconButton(
            tooltip: '刷新账单流水',
            icon: Icon(Icons.refresh_rounded, color: secondaryText, size: 22),
            onPressed: () {
              provider.fetchHistory();
              provider.refreshNow();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.fetchHistory();
          await provider.refreshNow();
        },
        color: accent,
        backgroundColor: cardBg,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          children: [
            // 1. 周期选择分段控制胶囊 (日 / 月 / 年)
            _buildPeriodSelector(isLight, accent),

            const SizedBox(height: 16),

            // 2. GitHub 贡献热力图卡片
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderColor: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
              glowColor: accent,
              enableCornerBolts: true,
              podTag: 'TELEMETRY // HEATMAP',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.grid_view_rounded, size: 16, color: accent),
                          const SizedBox(width: 6),
                          Text(
                            '活跃贡献热力图',
                            style: TextStyle(
                              color: primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedDateKey != null && _selectedDateKey != _todayDateString())
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDateKey = _todayDateString();
                              _selectedPeriodIndex = 0;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '返回今天',
                              style: TextStyle(
                                color: accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GithubHeatmap(
                    records: dailyRecords,
                    selectedDate: _selectedDateKey,
                    onSelectRecord: (record) {
                      if (record != null) {
                        setState(() {
                          _selectedDateKey = record.date;
                          _selectedPeriodIndex = 0; // 自动聚焦到日账单
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. 核心大数字看板
            _buildHighlightBoard(
              isLight: isLight,
              accent: accent,
              provider: provider,
              history: history,
              currentStats: currentStats,
              activeDailyRecord: activeDailyRecord,
            ),

            const SizedBox(height: 16),

            // 4. 明细列表 (根据所选周期呈现 日流水、月账单 或 年度/模型分布)
            if (_selectedPeriodIndex == 0)
              _buildDailyDetailSection(
                isLight: isLight,
                accent: accent,
                provider: provider,
                dailyRecords: dailyRecords,
                activeRecord: activeDailyRecord,
              )
            else if (_selectedPeriodIndex == 1)
              _buildMonthlyDetailSection(
                isLight: isLight,
                accent: accent,
                provider: provider,
                history: history,
                currentStats: currentStats,
              )
            else
              _buildYearlyDetailSection(
                isLight: isLight,
                accent: accent,
                provider: provider,
                history: history,
                currentStats: currentStats,
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 周期分段切换器
  Widget _buildPeriodSelector(bool isLight, Color accent) {
    final items = ['日账单', '月度账单', '年度 / 总览'];
    final bg = isLight ? const Color(0xFFEDF2F7) : const Color(0xFF101420);
    final activeText = isLight ? Colors.white : AppColors.textPrimary;
    final inactiveText = isLight ? AppColors.lightTextSecondary : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final isSelected = _selectedPeriodIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriodIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    items[index],
                    style: TextStyle(
                      color: isSelected ? activeText : inactiveText,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 核心大看板 (当前选中周期的金额与 Token)
  Widget _buildHighlightBoard({
    required bool isLight,
    required Color accent,
    required MonitorProvider provider,
    required UsageHistory? history,
    required AggregateStats? currentStats,
    required DailyUsageRecord? activeDailyRecord,
  }) {
    String periodTitle = '';
    int tokens = 0;
    double costUsd = 0.0;

    if (_selectedPeriodIndex == 0) {
      final isToday = _selectedDateKey == _todayDateString();
      periodTitle = isToday ? '今日用量流水 (${_selectedDateKey})' : '日期流水 (${_selectedDateKey})';
      tokens = activeDailyRecord?.totalTokens ?? currentStats?.today.totalTokens ?? 0;
      costUsd = activeDailyRecord?.costUsd ?? currentStats?.today.costUsd ?? 0.0;
    } else if (_selectedPeriodIndex == 1) {
      periodTitle = '本月总账单 (${_currentMonthString()})';
      // 优先取 history.monthly 中当月数据，其次取 currentStats.month
      final currentMonthKey = _currentMonthString();
      final monthRecord = history?.monthly.firstWhere(
        (m) => m.month == currentMonthKey,
        orElse: () => MonthlyUsageRecord(month: currentMonthKey),
      );
      tokens = (monthRecord?.totalTokens != null && monthRecord!.totalTokens > 0)
          ? monthRecord.totalTokens
          : (currentStats?.month.totalTokens ?? 0);
      costUsd = (monthRecord?.costUsd != null && monthRecord!.costUsd > 0)
          ? monthRecord.costUsd
          : (currentStats?.month.costUsd ?? 0.0);
    } else {
      periodTitle = '全时期 / 年度总投入';
      tokens = history?.summary?.totalTokens ?? currentStats?.allTime.totalTokens ?? 0;
      costUsd = history?.summary?.totalCostUsd ?? currentStats?.allTime.costUsd ?? 0.0;
    }

    final costCny = costUsd * provider.settings.usdToCnyRate;
    final primaryText = isLight ? AppColors.lightTextPrimary : AppColors.textPrimary;
    final mutedText = isLight ? AppColors.lightTextMuted : AppColors.textMuted;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderColor: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
      glowColor: accent,
      enableCornerBolts: true,
      podTag: 'AUDIT // BOARD',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                periodTitle,
                style: TextStyle(
                  color: mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedPeriodIndex == 0 ? 'DAY' : (_selectedPeriodIndex == 1 ? 'MONTH' : 'ALL-TIME'),
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatTokens(tokens),
                style: TextStyle(
                  color: primaryText,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Tokens',
                style: TextStyle(
                  color: mutedText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '\$${costUsd.toStringAsFixed(4)}',
                style: TextStyle(
                  color: accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '≈ ￥${costCny.toStringAsFixed(2)}',
                style: TextStyle(
                  color: mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 日账单详情与最近 14 天每日流水
  Widget _buildDailyDetailSection({
    required bool isLight,
    required Color accent,
    required MonitorProvider provider,
    required List<DailyUsageRecord> dailyRecords,
    required DailyUsageRecord? activeRecord,
  }) {
    final primaryText = isLight ? AppColors.lightTextPrimary : AppColors.textPrimary;
    final secondaryText = isLight ? AppColors.lightTextSecondary : AppColors.textSecondary;
    final mutedText = isLight ? AppColors.lightTextMuted : AppColors.textMuted;

    // 模型明细
    final models = activeRecord?.models ?? {};
    final modelCosts = activeRecord?.modelCosts ?? {};
    final clients = activeRecord?.clients ?? {};

    // 逆序排列每日记录用于展示近期流水 (取最多最近 14 天)
    final recentDays = List<DailyUsageRecord>.from(dailyRecords.reversed.take(14));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 当天各模型与工具分布
        if (models.isNotEmpty || clients.isNotEmpty) ...[
          Text(
            '${activeRecord?.date ?? "当日"} 消耗分布',
            style: TextStyle(
              color: primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          GlassContainer(
            padding: const EdgeInsets.all(14),
            borderColor: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (models.isNotEmpty) ...[
                  Text(
                    '模型消耗明细',
                    style: TextStyle(color: mutedText, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...models.entries.map((entry) {
                    final modelTokens = _extractTokens(entry.value);
                    final cost = _extractCost(entry.value, modelCosts, entry.key);
                    final modelColor = AppColors.getModelColor(entry.key);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: modelColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: TextStyle(color: primaryText, fontSize: 12, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTokens(modelTokens),
                            style: TextStyle(color: primaryText, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${cost.toStringAsFixed(4)}',
                            style: TextStyle(color: mutedText, fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                if (models.isNotEmpty && clients.isNotEmpty) const Divider(height: 20),
                if (clients.isNotEmpty) ...[
                  Text(
                    '活跃工具',
                    style: TextStyle(color: mutedText, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: clients.entries.map((entry) {
                      final clientTokens = _extractTokens(entry.value);
                      final toolColor = AppColors.getToolColor(entry.key);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: toolColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: toolColor.withOpacity(0.3), width: 0.5),
                        ),
                        child: Text(
                          '${entry.key}: ${_formatTokens(clientTokens)}',
                          style: TextStyle(color: toolColor, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                ],

              ],
            ),
          ),
          const SizedBox(height: 18),
        ],

        // 最近 14 天流水清单
        Text(
          '每日消耗流水 (近 14 天)',
          style: TextStyle(
            color: primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        if (recentDays.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('暂无流水数据，启动桌面或等待 Hub 收集', style: TextStyle(color: mutedText, fontSize: 13)),
            ),
          )
        else
          ...recentDays.map((day) {
            final isSelected = day.date == _selectedDateKey;
            final costCny = day.costUsd * provider.settings.usdToCnyRate;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GlassContainer(
                onTap: () {
                  setState(() {
                    _selectedDateKey = day.date;
                  });
                },
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                borderColor: isSelected
                    ? accent
                    : (isLight ? AppColors.lightGlassBorder : AppColors.glassBorder),
                child: Row(
                  children: [
                    // 日期与选中标记
                    Container(
                      width: 4,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected ? accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.date,
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          day.date == _todayDateString() ? '今天' : '${day.clients.length} 个工具活跃',
                          style: TextStyle(color: mutedText, fontSize: 11),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_formatTokens(day.totalTokens)} Tokens',
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${day.costUsd.toStringAsFixed(4)} (￥${costCny.toStringAsFixed(2)})',
                          style: TextStyle(
                            color: accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.receipt_outlined, size: 18, color: accent.withOpacity(0.85)),
                      tooltip: '打出 ${day.date} 小票',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(left: 6),
                      onPressed: () {
                        final hostname = currentStats?.devices.isNotEmpty == true
                            ? currentStats!.devices.first.hostname
                            : 'Local Device';
                        final models = day.models.map((k, v) => MapEntry(k, _extractTokens(v)));
                        final clients = day.clients.map((k, v) => MapEntry(k, _extractTokens(v)));
                        final primaryClient = clients.isNotEmpty ? clients.keys.first : null;
                        ReceiptDialog.show(
                          context,
                          ReceiptData(
                            title: 'DAILY RECEIPT // ${day.date}',
                            date: DateTime.tryParse(day.date) ?? DateTime.now(),
                            hostname: hostname,
                            totalTokens: day.totalTokens,
                            costUsd: day.costUsd,
                            currency: provider.settings.currency,
                            usdToCnyRate: provider.settings.usdToCnyRate,
                            models: models,
                            modelCosts: day.modelCosts,
                            clients: clients,
                            clientCosts: day.clientCosts,
                            primaryClient: primaryClient,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  /// 月度账单列表与分布
  Widget _buildMonthlyDetailSection({
    required bool isLight,
    required Color accent,
    required MonitorProvider provider,
    required UsageHistory? history,
    required AggregateStats? currentStats,
  }) {
    final primaryText = isLight ? AppColors.lightTextPrimary : AppColors.textPrimary;
    final mutedText = isLight ? AppColors.lightTextMuted : AppColors.textMuted;

    final List<MonthlyUsageRecord> months = history?.monthly.isNotEmpty == true
        ? history!.monthly.reversed.toList()
        : [
            if (currentStats != null)
              MonthlyUsageRecord(
                month: _currentMonthString(),
                totalTokens: currentStats.month.totalTokens,
                costUsd: currentStats.month.costUsd,
                clients: currentStats.month.clients,
                models: currentStats.month.models,
              )
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '历史月份账单',
          style: TextStyle(
            color: primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        if (months.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('暂无历史月度数据', style: TextStyle(color: mutedText, fontSize: 13)),
            ),
          )
        else
          ...months.map((m) {
            final costCny = m.costUsd * provider.settings.usdToCnyRate;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderColor: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.month,
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${m.clients.length} 个客户端',
                          style: TextStyle(color: mutedText, fontSize: 11),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_formatTokens(m.totalTokens)} Tokens',
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '\$${m.costUsd.toStringAsFixed(2)} ≈ ￥${costCny.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  /// 年度与历史总览统计
  Widget _buildYearlyDetailSection({
    required bool isLight,
    required Color accent,
    required MonitorProvider provider,
    required UsageHistory? history,
    required AggregateStats? currentStats,
  }) {
    final primaryText = isLight ? AppColors.lightTextPrimary : AppColors.textPrimary;
    final mutedText = isLight ? AppColors.lightTextMuted : AppColors.textMuted;

    final summary = history?.summary;
    final totalTokens = summary?.totalTokens ?? currentStats?.allTime.totalTokens ?? 0;
    final totalCostUsd = summary?.totalCostUsd ?? currentStats?.allTime.costUsd ?? 0.0;
    final daysActive = summary?.daysActive ?? 1;

    final avgDailyTokens = daysActive > 0 ? (totalTokens / daysActive).round() : 0;
    final avgDailyCost = daysActive > 0 ? (totalCostUsd / daysActive) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '年度 / 长期指标归纳',
          style: TextStyle(
            color: primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                borderColor: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('日均消耗 Token', style: TextStyle(color: mutedText, fontSize: 11)),
                    const SizedBox(height: 6),
                    Text(
                      _formatTokens(avgDailyTokens),
                      style: TextStyle(color: primaryText, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                borderColor: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('记录活跃天数', style: TextStyle(color: mutedText, fontSize: 11)),
                    const SizedBox(height: 6),
                    Text(
                      '$daysActive 天',
                      style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 全时期客户端占比
        if (currentStats?.allTime.clients.isNotEmpty == true) ...[
          Text(
            '全时期工具投入分布',
            style: TextStyle(color: primaryText, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          GlassContainer(
            padding: const EdgeInsets.all(14),
            borderColor: isLight ? AppColors.lightGlassBorder : AppColors.glassBorder,
            child: Column(
              children: currentStats!.allTime.clients.entries.map((e) {
                final toolColor = AppColors.getToolColor(e.key);
                final cost = currentStats.allTime.clientCosts[e.key] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: toolColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.key,
                          style: TextStyle(color: primaryText, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        _formatTokens(e.value),
                        style: TextStyle(color: primaryText, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${cost.toStringAsFixed(2)}',
                        style: TextStyle(color: mutedText, fontSize: 11),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
