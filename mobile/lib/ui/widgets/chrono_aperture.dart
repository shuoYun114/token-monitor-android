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
          borderRadius: BorderRadius.circular(8), // 瑞士硬朗 8px 微倒角
          border: Border.all(color: borderCol, width: 0.9), // 0.9px 发丝线
          boxShadow: [
            BoxShadow(
              color: isLight ? const Color(0x0A09090B) : Colors.black.withOpacity(0.45),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Stack(
            children: [
              // 1. 瑞士版面四角十字对齐标 (+)
              Positioned.fill(
                child: CustomPaint(
                  painter: _SwissCrosshairGridPainter(isLight: isLight),
                ),
              ),

              // 2. 顶部瑞士精准红定位条
              Positioned(
                top: 0,
                left: 16,
                child: Container(
                  width: 32,
                  height: 2.4,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标头行：结构索引 + 活跃状态
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Text(
                                'CH-01',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SWISS TELEMETRY // CORE APERTURE',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'monospace',
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: accent.withOpacity(0.4), width: 0.7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 4.5,
                                height: 4.5,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'SYNCHRONIZED',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // 中间核心：非对称方圆互锁排版 (左侧巨幕数据，右侧瑞士精密动态罗盘)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 左侧巨幕大字阶排版
                        Expanded(
                          flex: 11,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TODAY TOKEN ACCUMULATION',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // 巨幕主数值
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    widget.shortTokensText,
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                      letterSpacing: -1.5,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'TOKENS',
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // 精确计数值
                              Text(
                                widget.exactTokensText,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.8,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // 费用估算块 (瑞士红高光胶囊)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isLight ? const Color(0xFFF1F2F4) : const Color(0xFF18181D),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isLight ? const Color(0xFFCBD5E1) : const Color(0xFF2E2E36),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
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
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.secondaryCostText,
                                      style: TextStyle(
                                        color: textMuted,
                                        fontSize: 9.5,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 右侧瑞士精密微刻度动态旋转仪 (方圆互锁几何)
                        Expanded(
                          flex: 8,
                          child: Center(
                            child: SizedBox(
                              width: 124,
                              height: 124,
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
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: accent,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Icon(Icons.add, size: 10, color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'SWISS',
                                            style: TextStyle(
                                              color: textPrimary,
                                              fontSize: 7.5,
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'monospace',
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 底部发丝线与拓扑状态条
                    Container(
                      padding: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: borderCol,
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '||| | ||||| ||',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 8,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'CLUSTER MESH',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'MODELS: ${widget.modelsCount} // CLIENTS: ${widget.clientsCount}',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
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

/// 绘制瑞士版面对位十字准星 (+)
class _SwissCrosshairGridPainter extends CustomPainter {
  final bool isLight;

  _SwissCrosshairGridPainter({required this.isLight});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = (isLight ? const Color(0xFF71717A) : const Color(0xFFA1A1AA)).withOpacity(isLight ? 0.3 : 0.4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const offset = 8.0;
    const arm = 3.5;

    final corners = [
      Offset(offset, offset),
      Offset(size.width - offset, offset),
      Offset(offset, size.height - offset),
      Offset(size.width - offset, size.height - offset),
    ];

    for (final c in corners) {
      canvas.drawLine(Offset(c.dx - arm, c.dy), Offset(c.dx + arm, c.dy), linePaint);
      canvas.drawLine(Offset(c.dx, c.dy - arm), Offset(c.dx, c.dy + arm), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SwissCrosshairGridPainter oldDelegate) =>
      oldDelegate.isLight != isLight;
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
