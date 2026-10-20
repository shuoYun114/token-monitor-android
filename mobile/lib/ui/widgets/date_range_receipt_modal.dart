import 'package:flutter/material.dart';
import '../../models/app_settings.dart';
import '../../models/device_stats.dart';
import '../../models/usage_history.dart';
import '../../theme/app_colors.dart';
import 'receipt_dialog.dart';

/// 日期范围小票数据聚合器
class RangeReceiptAggregator {
  /// 深度聚合指定时间段内的用量数据，生成统一的 ReceiptData
  static ReceiptData aggregate({
    required DateTime startDate,
    required DateTime endDate,
    required List<DailyUsageRecord> dailyRecords,
    required AggregateStats? currentStats,
    required AppSettings settings,
    String? hostname,
  }) {
    // 规范化起始和结束日期为 00:00:00 至 23:59:59
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    final Map<String, int> mergedModels = {};
    final Map<String, double> mergedModelCosts = {};
    final Map<String, int> mergedClients = {};
    final Map<String, double> mergedClientCosts = {};
    int totalTokens = 0;
    double costUsd = 0.0;
    int cacheReadTokens = 0;
    int outputTokens = 0;
    int unclassifiedTokens = 0;
    final Map<String, dynamic> modelCacheReads = {};
    final Map<String, dynamic> modelOutputs = {};
    final Map<String, dynamic> modelUnclassifiedTokens = {};

    int safeInt(dynamic v) {
      if (v is num) return v.toInt();
      if (v is Map) {
        final t = v['tokens'] ?? v['totalTokens'];
        if (t is num) return t.toInt();
        if (t is String) return int.tryParse(t) ?? 0;
      }
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    double safeDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      if (v is Map) {
        final c = v['cost'] ?? v['costUsd'];
        if (c is num) return c.toDouble();
        if (c is String) return double.tryParse(c) ?? 0.0;
      }
      return 0.0;
    }

    // 收集全部日记录并确保今日数据最新
    final now = DateTime.now();
    final todayStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final Map<String, DailyUsageRecord> recordMap = {};
    for (final r in dailyRecords) {
      if (r.date.isNotEmpty) {
        recordMap[r.date] = r;
      }
    }

    if (currentStats != null) {
      final todayUsage = currentStats.today;
      if (todayUsage.totalTokens > 0 || !recordMap.containsKey(todayStr)) {
        recordMap[todayStr] = DailyUsageRecord(
          date: todayStr,
          totalTokens: todayUsage.totalTokens,
          costUsd: todayUsage.costUsd,
          clients: todayUsage.clients,
          clientCosts: todayUsage.clientCosts,
          models: todayUsage.models,
          modelCosts: todayUsage.modelCosts,
        );
      }
    }

    // 筛选位于 start 与 end 之间的记录进行累加
    recordMap.forEach((dateStr, record) {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null && !dt.isBefore(start) && !dt.isAfter(end)) {
        totalTokens += record.totalTokens;
        costUsd += record.costUsd;

        record.models.forEach((m, v) {
          mergedModels[m] = (mergedModels[m] ?? 0) + safeInt(v);
        });
        record.modelCosts.forEach((m, v) {
          mergedModelCosts[m] = (mergedModelCosts[m] ?? 0.0) + safeDouble(v);
        });

        record.clients.forEach((c, v) {
          mergedClients[c] = (mergedClients[c] ?? 0) + safeInt(v);
        });
        record.clientCosts.forEach((c, v) {
          mergedClientCosts[c] = (mergedClientCosts[c] ?? 0.0) + safeDouble(v);
        });

        // 若包含今天，合并当日精准缓存与输出数据
        if (dateStr == todayStr && currentStats != null) {
          cacheReadTokens += currentStats.today.cacheReadTokens;
          outputTokens += currentStats.today.outputTokens;
          unclassifiedTokens += currentStats.today.unclassifiedTokens;
          currentStats.today.modelCacheReads.forEach((k, v) => modelCacheReads[k] = safeInt(v));
          currentStats.today.modelOutputs.forEach((k, v) => modelOutputs[k] = safeInt(v));
          currentStats.today.modelUnclassifiedTokens.forEach((k, v) => modelUnclassifiedTokens[k] = safeInt(v));
        }
      }
    });

    // 寻找区间内使用最多的主力客户端
    String? primaryClient;
    int maxTokens = -1;
    mergedClients.forEach((k, v) {
      if (v > maxTokens) {
        maxTokens = v;
        primaryClient = k;
      }
    });

    final startFmt = '${startDate.year}.${startDate.month.toString().padLeft(2, '0')}.${startDate.day.toString().padLeft(2, '0')}';
    final endFmt = '${endDate.year}.${endDate.month.toString().padLeft(2, '0')}.${endDate.day.toString().padLeft(2, '0')}';
    final daysCount = endDate.difference(startDate).inDays + 1;
    final rangeStr = startFmt == endFmt ? '$startFmt (单日)' : '$startFmt - $endFmt ($daysCount 天)';

    final host = hostname ?? (currentStats?.devices.isNotEmpty == true ? currentStats!.devices.first.hostname : 'Token Monitor');

    return ReceiptData(
      title: 'CUSTOM RANGE RECEIPT',
      date: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      dateRange: rangeStr,
      hostname: host,
      totalTokens: totalTokens,
      costUsd: costUsd,
      currency: settings.currency,
      usdToCnyRate: settings.usdToCnyRate,
      models: mergedModels,
      modelCosts: mergedModelCosts,
      clients: mergedClients,
      clientCosts: mergedClientCosts,
      primaryClient: primaryClient,
      cacheReadTokens: cacheReadTokens,
      outputTokens: outputTokens,
      unclassifiedTokens: unclassifiedTokens,
      modelCacheReads: modelCacheReads,
      modelOutputs: modelOutputs,
      modelUnclassifiedTokens: modelUnclassifiedTokens,
    );
  }
}

/// 自选日期范围打印小票交互弹窗 (瑞士工整微晶排版)
class DateRangeReceiptModal extends StatefulWidget {
  final List<DailyUsageRecord> dailyRecords;
  final AggregateStats? currentStats;
  final AppSettings settings;
  final bool isLight;

  const DateRangeReceiptModal({
    super.key,
    required this.dailyRecords,
    required this.currentStats,
    required this.settings,
    required this.isLight,
  });

  /// 便捷调起底部抽屉对话框
  static Future<void> show({
    required BuildContext context,
    required List<DailyUsageRecord> dailyRecords,
    required AggregateStats? currentStats,
    required AppSettings settings,
    required bool isLight,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DateRangeReceiptModal(
        dailyRecords: dailyRecords,
        currentStats: currentStats,
        settings: settings,
        isLight: isLight,
      ),
    );
  }

  @override
  State<DateRangeReceiptModal> createState() => _DateRangeReceiptModalState();
}

class _DateRangeReceiptModalState extends State<DateRangeReceiptModal> {
  late DateTime _startDate;
  late DateTime _endDate;
  int _activePresetIndex = 2; // 默认选中 '近 7 天'

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _endDate = today;
    _startDate = today.subtract(const Duration(days: 6)); // 近 7 天
  }

  void _applyPreset(int index) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      _activePresetIndex = index;
      switch (index) {
        case 0: // 今天
          _startDate = today;
          _endDate = today;
          break;
        case 1: // 昨天
          _startDate = today.subtract(const Duration(days: 1));
          _endDate = today.subtract(const Duration(days: 1));
          break;
        case 2: // 近 7 天
          _startDate = today.subtract(const Duration(days: 6));
          _endDate = today;
          break;
        case 3: // 近 14 天
          _startDate = today.subtract(const Duration(days: 13));
          _endDate = today;
          break;
        case 4: // 近 30 天
          _startDate = today.subtract(const Duration(days: 29));
          _endDate = today;
          break;
        case 5: // 本月
          _startDate = DateTime(today.year, today.month, 1);
          _endDate = today;
          break;
        case 6: // 上月
          final firstOfThisMonth = DateTime(today.year, today.month, 1);
          final lastOfPrevMonth = firstOfThisMonth.subtract(const Duration(days: 1));
          _startDate = DateTime(lastOfPrevMonth.year, lastOfPrevMonth.month, 1);
          _endDate = lastOfPrevMonth;
          break;
        case 7: // 全部记录
          DateTime minDate = today;
          for (final r in widget.dailyRecords) {
            final dt = DateTime.tryParse(r.date);
            if (dt != null && dt.isBefore(minDate)) {
              minDate = dt;
            }
          }
          _startDate = DateTime(minDate.year, minDate.month, minDate.day);
          _endDate = today;
          break;
      }
    });
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isAfter(_endDate) ? _endDate : _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
      helpText: '选择小票统计【起始日期】',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _activePresetIndex = -1; // 切换为自定义状态
      });
    }
  }

  Future<void> _selectEndDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isAfter(today) ? today : _endDate,
      firstDate: _startDate,
      lastDate: today,
      helpText: '选择小票统计【截止日期】',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _activePresetIndex = -1; // 切换为自定义状态
      });
    }
  }

  Future<void> _openFullCalendarPicker() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: today,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      helpText: '选择小票日期范围 (几月几号到几月几号)',
      cancelText: '取消',
      confirmText: '确定所选',
      saveText: '确定',
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _activePresetIndex = -1;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final isLight = widget.isLight;
    final accent = AppColors.getThemeAccent(isLight);
    final bg = isLight ? const Color(0xFFFBFBFD) : const Color(0xFF0F131D);
    final surface = isLight ? Colors.white : const Color(0xFF161C2C);
    final border = isLight ? AppColors.swissLightBorder : const Color(0xFF242C42);
    final primaryText = isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary;
    final secondaryText = isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary;
    final mutedText = isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted;

    // 实时计算当前区间内的预览数据
    final previewData = RangeReceiptAggregator.aggregate(
      startDate: _startDate,
      endDate: _endDate,
      dailyRecords: widget.dailyRecords,
      currentStats: widget.currentStats,
      settings: widget.settings,
    );

    final daysCount = _endDate.difference(_startDate).inDays + 1;
    final costCny = previewData.costUsd * widget.settings.usdToCnyRate;

    // 统计区间内有多少天存在实际消耗
    final startNorm = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final endNorm = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
    int activeDays = 0;
    for (final r in widget.dailyRecords) {
      final dt = DateTime.tryParse(r.date);
      if (dt != null && !dt.isBefore(startNorm) && !dt.isAfter(endNorm) && r.totalTokens > 0) {
        activeDays++;
      }
    }

    final presets = ['今天', '昨天', '近 7 天', '近 14 天', '近 30 天', '本月', '上月', '全部'];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部小把手
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: mutedText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 标题与说明
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: accent.withOpacity(0.4), width: 0.8),
                ),
                child: Icon(Icons.date_range_rounded, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '自选日期账单小票',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '选择起始与截止日期，打印该周期的专属算力消耗小票',
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: mutedText,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 快捷周期预设芯片横向列表
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final isSelected = _activePresetIndex == idx;
                return GestureDetector(
                  onTap: () => _applyPreset(idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? accent : surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected ? accent : border,
                        width: 0.8,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        presets[idx],
                        style: TextStyle(
                          color: isSelected ? Colors.white : secondaryText,
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 起始日期与结束日期选择双卡片
          Row(
            children: [
              // 起始日期卡片
              Expanded(
                child: GestureDetector(
                  onTap: _selectStartDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _activePresetIndex == -1 ? accent.withOpacity(0.5) : border,
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 12, color: accent),
                            const SizedBox(width: 4),
                            Text(
                              '起始日期 FROM',
                              style: TextStyle(
                                color: mutedText,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 中间连接箭头与整段日历速选
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: IconButton(
                  tooltip: '在完整日历中划选日期范围',
                  icon: Icon(Icons.swap_horiz_rounded, size: 22, color: accent),
                  onPressed: _openFullCalendarPicker,
                ),
              ),

              // 结束日期卡片
              Expanded(
                child: GestureDetector(
                  onTap: _selectEndDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _activePresetIndex == -1 ? accent.withOpacity(0.5) : border,
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.event_available_rounded, size: 12, color: accent),
                            const SizedBox(width: 4),
                            Text(
                              '截止日期 TO',
                              style: TextStyle(
                                color: mutedText,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 实时数据遥测预览卡片 (瑞士精密数据仪表)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isLight ? const Color(0xFFF3F4F8) : const Color(0xFF131722),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '区间用量即时遥测',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '跨度 $daysCount 天 (有效活跃 $activeDays 天)',
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '总计 TOKEN 消耗',
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _formatTokens(previewData.totalTokens),
                            style: TextStyle(
                              color: primaryText,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 0.8,
                      height: 32,
                      color: border,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '折合费用估算',
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '¥${costCny.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: accent,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 底部动作按钮栏 (取消 & 打印小票)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(color: border, width: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(
                    '取消',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.receipt_long_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    '生成并打印区间小票',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  onPressed: () {
                    // 关闭配置弹窗
                    Navigator.of(context).pop();
                    // 呼出仿真热敏小票
                    ReceiptDialog.show(context, previewData);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
