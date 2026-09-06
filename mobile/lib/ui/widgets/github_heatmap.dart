import 'package:flutter/material.dart';
import '../../models/usage_history.dart';
import '../../theme/app_colors.dart';

/// GitHub 风格 7 行贡献热力图组件
class GithubHeatmap extends StatefulWidget {
  final List<DailyUsageRecord> records;
  final String? selectedDate;
  final ValueChanged<DailyUsageRecord?>? onSelectRecord;
  final int weeksToShow;

  const GithubHeatmap({
    super.key,
    required this.records,
    this.selectedDate,
    this.onSelectRecord,
    this.weeksToShow = 20, // 默认显示最近 20 周
  });

  @override
  State<GithubHeatmap> createState() => _GithubHeatmapState();
}

class _GithubHeatmapState extends State<GithubHeatmap> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // 默认横向滚动到最右侧（即最近的今天）
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 计算每天的活跃度级别 0 ~ 4
  int _getLevel(int totalTokens) {
    if (totalTokens <= 0) return 0;
    if (totalTokens < 100000) return 1; // < 100K
    if (totalTokens < 500000) return 2; // < 500K
    if (totalTokens < 2000000) return 3; // < 2M
    return 4; // >= 2M
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final levels = AppColors.getHeatmapLevels(isLight);

    // 将 records 映射为以日期为 key 的 Map
    final Map<String, DailyUsageRecord> recordMap = {
      for (var r in widget.records) r.date: r,
    };

    // 构建最近 N 周的日期矩阵 (7 行 x N 列)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // 今天所在的星期几 (1: 周一, ..., 7: 周日)
    final currentWeekday = today.weekday;
    // 距本周最后一天的偏移，构建完整对齐的网格
    final endDate = today.add(Duration(days: 7 - currentWeekday));
    final startDate = endDate.subtract(Duration(days: widget.weeksToShow * 7 - 1));

    final List<List<DateTime>> weeks = [];
    DateTime cursor = startDate;
    for (int w = 0; w < widget.weeksToShow; w++) {
      final List<DateTime> weekDays = [];
      for (int d = 0; d < 7; d++) {
        weekDays.add(cursor);
        cursor = cursor.add(const Duration(days: 1));
      }
      weeks.add(weekDays);
    }

    final mutedText = isLight ? AppColors.lightTextMuted : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 热力图网格区域 (支持横向滑动)
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 星期标签 (周一、周三、周五、周日)
              Padding(
                padding: const EdgeInsets.only(right: 6, top: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWeekdayLabel('一', mutedText),
                    _buildWeekdayLabel('三', mutedText),
                    _buildWeekdayLabel('五', mutedText),
                    _buildWeekdayLabel('日', mutedText),
                  ],
                ),
              ),

              // 可滚动热力方格
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: weeks.map((week) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Column(
                          children: week.map((date) {
                            final dateKey = _formatDateKey(date);
                            final isFuture = date.isAfter(today);
                            final record = recordMap[dateKey];
                            final totalTokens = record?.totalTokens ?? 0;
                            final level = isFuture ? 0 : _getLevel(totalTokens);
                            final isSelected = widget.selectedDate == dateKey;

                            final color = isFuture
                                ? (isLight ? const Color(0xFFF1F5F9) : const Color(0xFF0D111A))
                                : levels[level];

                            return GestureDetector(
                              onTap: isFuture
                                  ? null
                                  : () {
                                      widget.onSelectRecord?.call(record ?? DailyUsageRecord(date: dateKey));
                                    },
                              child: Container(
                                width: 13,
                                height: 13,
                                margin: const EdgeInsets.symmetric(vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(3),
                                  border: isSelected
                                      ? Border.all(
                                          color: isLight ? AppColors.warmYellowDark : AppColors.iceBlueLight,
                                          width: 2,
                                        )
                                      : (totalTokens > 0
                                          ? Border.all(
                                              color: (isLight ? Colors.black : Colors.white).withOpacity(0.08),
                                              width: 0.5,
                                            )
                                          : null),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 底部图例说明: Less [0][1][2][3][4] More
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '滑动浏览最近 ${widget.weeksToShow} 周活跃轨迹',
              style: TextStyle(
                color: mutedText,
                fontSize: 11,
              ),
            ),
            Row(
              children: [
                Text(
                  '少',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                ...levels.map((c) => Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )),
                const SizedBox(width: 4),
                Text(
                  '多',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdayLabel(String label, Color color) {
    return SizedBox(
      height: 24,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
