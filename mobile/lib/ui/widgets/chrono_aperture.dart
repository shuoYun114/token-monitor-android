import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 瑞士国际主义算力视窗 (Swiss Typographic Chrono-Grid Aperture)
/// 遵循 Josef Müller-Brockmann 数学栅格法则：大比例字阶对比、方圆互锁几何张力、发丝线骨架与瑞士精准红点睛
class ChronoApertureWidget extends StatefulWidget {
  final int totalTokens;
  final String shortTokensText;
  final String exactTokensText;
  final String costText;
  final String secondaryCostText;
  final int modelsCount;
  final int clientsCount;
  final bool isLight;
  final VoidCallback? onTap;

  const ChronoApertureWidget({
    super.key,
    required this.totalTokens,
    required this.shortTokensText,
    required this.exactTokensText,
    required this.costText,
    required this.secondaryCostText,
    this.modelsCount = 0,
    this.clientsCount = 0,
    required this.isLight,
    this.onTap,
  });

  @override
  State<ChronoApertureWidget> createState() => _ChronoApertureWidgetState();
}

class _ChronoApertureWidgetState extends State<ChronoApertureWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // 匀速缓慢旋转瑞士精密刻度环 (32 秒周期，从容理性)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = widget.isLight;
    final accent = AppColors.getThemeAccent(isLight); // 瑞士精准红
    final surfaceBg = isLight ? AppColors.swissLightSurface : AppColors.swissDarkSurface;
    final borderCol = isLight ? AppColors.swissLightBorder : AppColors.swissDarkBorder;
    final textPrimary = isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary;
    final textSecondary = isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary;
    final textMuted = isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceBg,
          borderRadius: BorderRadius.circular(10), // 现代精致 10px 微倒角
          border: Border.all(color: borderCol, width: 0.8), // 0.8px 优雅发丝线
          boxShadow: [
            BoxShadow(
              color: isLight ? const Color(0x0609090B) : Colors.black.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Stack(
            children: [
              // 顶部瑞士精准红定位条
              Positioned(
                top: 0,
                left: 18,
                child: Container(
                  width: 28,
                  height: 2.0,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 标头行：清晰简约，绝不横向堆叠
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
                            const SizedBox(width: 8),
                            Text(
                              '今日算力遥测',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'TODAY',
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: isLight ? const Color(0xFFF1F3F5) : const Color(0xFF16161A),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderCol, width: 0.7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: AppColors.emerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '实时同步',
                                style: TextStyle(
                                  color: isLight ? AppColors.swissLightTextSecondary : AppColors.swissDarkTextSecondary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 中间核心：非对称方圆互锁排版 (左侧巨幕数据，右侧瑞士精密动态罗盘)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 左侧巨幕大字阶排版
                        // 左侧主数据栏 (舒展透气，绝不溢出)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '累计消耗 (TOKENS)',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 4),

                              // 巨幕主数值：FittedBox 确保任何大数均不溢出
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.shortTokensText,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                    letterSpacing: -1.0,
                                    height: 1.0,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),

                              // 精确计数值
                              Text(
                                '${widget.exactTokensText} tokens',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                              ),

                              const SizedBox(height: 10),

                              // 费用估算块 (纯净胶囊)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                                decoration: BoxDecoration(
                                  color: isLight ? const Color(0xFFF4F5F7) : const Color(0xFF16161B),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isLight ? const Color(0xFFE2E4E8) : const Color(0xFF282830),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: accent,
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.costText,
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.secondaryCostText,
                                      style: TextStyle(
                                        color: textMuted,
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 14),

                        // 右侧瑞士精密微刻度动态旋转仪 (精致紧凑，88x88，留出呼吸感)
                        SizedBox(
                          width: 88,
                          height: 88,
                          child: AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _SwissDialPainter(
                                  rotationValue: _rotationController.value,
                                  isLight: isLight,
                                  accentColor: accent,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 13,
                                        height: 13,
                                        decoration: BoxDecoration(
                                          color: accent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.add, size: 9, color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'SWISS',
                                        style: TextStyle(
                                          color: textPrimary,
                                          fontSize: 7,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'monospace',
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 底部发丝线与拓扑状态条 (去除多余伪条码)
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: borderCol,
                            width: 0.7,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_mosaic_rounded,
                                size: 12,
                                color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '接入 ${widget.modelsCount} 款模型',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${widget.clientsCount} 款工具活跃',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// 绘制右侧方圆互锁瑞士精密刻度旋转罗盘
class _SwissDialPainter extends CustomPainter {
  final double rotationValue; // 0.0 ~ 1.0
  final bool isLight;
  final Color accentColor;

  _SwissDialPainter({
    required this.rotationValue,
    required this.isLight,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 2;

    // 1. 最外层 0.8px 发丝底圈
    final trackPaint = Paint()
      ..color = isLight ? const Color(0xFFD4D4D8) : const Color(0xFF27272A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, maxRadius, trackPaint);

    // 2. 60 单元高精度物理刻度线 (逢 5 加长并带有瑞士红强调)
    const tickCount = 60;
    for (int i = 0; i < tickCount; i++) {
      final angle = (i * 6) * math.pi / 180.0;
      final isMajor = i % 5 == 0;
      final isRedQuarter = i % 15 == 0;
      final length = isMajor ? 5.5 : 2.5;

      final p1 = Offset(
        center.dx + (maxRadius - length) * math.cos(angle),
        center.dy + (maxRadius - length) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );

      final tickPaint = Paint()
        ..color = isRedQuarter
            ? accentColor
            : (isMajor
                ? (isLight ? const Color(0xFF18181B) : const Color(0xFFFAFAFA))
                : (isLight ? const Color(0xFFA1A1AA) : const Color(0xFF52525B)))
        ..strokeWidth = isMajor ? 1.2 : 0.7;

      canvas.drawLine(p1, p2, tickPaint);
    }

    // 3. 动态旋转的瑞士双轨红白能量弧
    final innerRadius = maxRadius - 10;
    final rotAngle = rotationValue * 2 * math.pi;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotAngle);

    final arcPaint = Paint()
      ..color = accentColor.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.square; // 瑞士风格：硬朗方头笔触，拒绝圆滑

    // 绘制对角双弧
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: innerRadius),
      0,
      math.pi * 0.45,
      false,
      arcPaint,
    );

    final whiteArcPaint = Paint()
      ..color = isLight ? const Color(0xFF18181B) : const Color(0xFFE4E4E7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.square;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: innerRadius),
      math.pi,
      math.pi * 0.45,
      false,
      whiteArcPaint,
    );

    // 旋转点
    final dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(innerRadius, 0), 2.0, dotPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SwissDialPainter oldDelegate) =>
      oldDelegate.rotationValue != rotationValue ||
      oldDelegate.isLight != isLight ||
      oldDelegate.accentColor != accentColor;
}
