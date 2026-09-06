import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 全息算力天体视窗 (Chrono-Telemetry Aperture)
/// 融合航天遥测精密仪器 (Aerospace Telemetry) 与瑞士复杂机械陀飞轮 (Haute Horlogerie) 美学
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
    // 匀速缓慢旋转机械陀飞轮能量环 (28 秒完整周期，带机械阻尼从容感)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
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
    final accent = AppColors.getThemeAccent(isLight);

    // 舱体底色与结构质感
    final podBg = isLight ? const Color(0xFFFFFFFF) : const Color(0xFF0C0F17);
    final podBorder = isLight ? const Color(0xFFCBD5E1) : const Color(0xFF222B3D);
    final boltColor = isLight ? AppColors.aeroBoltLight : AppColors.aeroBoltDark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: podBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: podBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: isLight
                  ? const Color(0x140F172A)
                  : Colors.black.withOpacity(0.6),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            if (!isLight)
              BoxShadow(
                color: accent.withOpacity(0.08),
                blurRadius: 36,
                spreadRadius: -4,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // 物理机舱内衬微纹理与四角螺栓刻线
              Positioned.fill(
                child: CustomPaint(
                  painter: _AeroChassisPainter(
                    isLight: isLight,
                    boltColor: boltColor,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  children: [
                    // 1. 顶部工业遥测编号标头与运行状态
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
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withOpacity(0.8),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'CHRONO-TELEMETRY // APERTURE-01',
                              style: TextStyle(
                                color: isLight
                                    ? AppColors.lightTextSecondary
                                    : AppColors.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'monospace',
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.emerald.withOpacity(0.3),
                              width: 0.6,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, size: 10, color: AppColors.emerald),
                              SizedBox(width: 2),
                              Text(
                                'ENGAGED',
                                style: TextStyle(
                                  color: AppColors.emerald,
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

                    const SizedBox(height: 10),

                    // 2. 核心：瑞士机械腕表全息天体视窗 (Chrono Dial)
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(double.infinity, 240),
                          painter: _ChronoDialPainter(
                            rotationValue: _rotationController.value,
                            isLight: isLight,
                            accentColor: accent,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 240,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 微标
                                  Text(
                                    'TODAY COMPUTE ACCUMULATION',
                                    style: TextStyle(
                                      color: isLight
                                          ? AppColors.lightTextMuted
                                          : AppColors.textMuted,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'monospace',
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Token 巨幕数值与单位
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        widget.shortTokensText,
                                        style: TextStyle(
                                          color: isLight
                                              ? AppColors.lightTextPrimary
                                              : Colors.white,
                                          fontSize: 38,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'monospace',
                                          letterSpacing: -1.2,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'TOKENS',
                                        style: TextStyle(
                                          color: accent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'monospace',
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // 精确数字
                                  Text(
                                    widget.exactTokensText,
                                    style: TextStyle(
                                      color: isLight
                                          ? AppColors.lightTextMuted
                                          : AppColors.warmWhiteMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'monospace',
                                      letterSpacing: 0.5,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // 嵌套式精密折合成本金属胶囊
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isLight
                                          ? const Color(0xFFFEF3C7).withOpacity(0.8)
                                          : const Color(0xFF141A28),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isLight
                                            ? AppColors.warmYellowDark.withOpacity(0.35)
                                            : accent.withOpacity(0.35),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isLight
                                                  ? AppColors.warmYellowDark
                                                  : accent)
                                              .withOpacity(0.12),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: isLight
                                                ? AppColors.warmYellowDark
                                                : AppColors.warmYellow,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          widget.costText,
                                          style: TextStyle(
                                            color: isLight
                                                ? AppColors.warmYellowDark
                                                : AppColors.warmYellow,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'monospace',
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          widget.secondaryCostText,
                                          style: TextStyle(
                                            color: isLight
                                                ? AppColors.lightTextMuted
                                                : AppColors.textMuted,
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
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // 3. 底部工业点阵遥测状态条
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLight
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFF111624),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLight
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF1E283C),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildLedDot(true, accent),
                              const SizedBox(width: 4),
                              _buildLedDot(true, accent),
                              const SizedBox(width: 4),
                              _buildLedDot(true, accent),
                              const SizedBox(width: 4),
                              _buildLedDot(false, accent),
                              const SizedBox(width: 8),
                              Text(
                                'CLUSTER TELEMETRY',
                                style: TextStyle(
                                  color: isLight
                                      ? AppColors.lightTextSecondary
                                      : AppColors.textMuted,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'MODELS: ${widget.modelsCount} // TOOLS: ${widget.clientsCount}',
                            style: TextStyle(
                              color: isLight
                                  ? AppColors.lightTextMuted
                                  : AppColors.textMuted,
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

  Widget _buildLedDot(bool active, Color color) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: active ? color : color.withOpacity(0.2),
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withOpacity(0.8),
                  blurRadius: 3,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
    );
  }
}

/// 绘制机舱背景四角螺栓与微雕辅助定位线
class _AeroChassisPainter extends CustomPainter {
  final bool isLight;
  final Color boltColor;

  _AeroChassisPainter({required this.isLight, required this.boltColor});

  @override
  void paint(Canvas canvas, Size size) {
    final boltPaint = Paint()
      ..color = boltColor.withOpacity(isLight ? 0.4 : 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = boltColor.withOpacity(isLight ? 0.3 : 0.4)
      ..style = PaintingStyle.fill;

    // 四角微雕精密螺栓点缀 (距离各边 10px)
    final corners = [
      const Offset(10, 10),
      Offset(size.width - 10, 10),
      Offset(10, size.height - 10),
      Offset(size.width - 10, size.height - 10),
    ];

    for (final c in corners) {
      canvas.drawCircle(c, 2.8, boltPaint);
      canvas.drawCircle(c, 1.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AeroChassisPainter oldDelegate) =>
      oldDelegate.isLight != isLight;
}

/// 核心：全息天体双轨精密陀飞轮表盘绘制器
class _ChronoDialPainter extends CustomPainter {
  final double rotationValue; // 0.0 ~ 1.0
  final bool isLight;
  final Color accentColor;

  _ChronoDialPainter({
    required this.rotationValue,
    required this.isLight,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 6;

    // 1. 绘制底层全息聚光微波光晕
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: isLight
            ? [
                accentColor.withOpacity(0.09),
                const Color(0xFFF1F5F9).withOpacity(0.0),
              ]
            : [
                accentColor.withOpacity(0.12),
                const Color(0xFF0C0F17).withOpacity(0.0),
              ],
        stops: const [0.2, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));
    canvas.drawCircle(center, maxRadius, glowPaint);

    // 2. 绘制最外层精密刻度外圈底轨
    final outerTrackPaint = Paint()
      ..color = isLight
          ? const Color(0xFFE2E8F0)
          : const Color(0xFF1E283C).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, maxRadius, outerTrackPaint);

    // 3. 绘制 60 单元高精度物理刻度线 (逢 5 加长加粗)
    final tickRadius = maxRadius;
    final tickLengthMajor = 7.0;
    final tickLengthMinor = 3.5;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * math.pi / 180.0;
      final isMajor = i % 5 == 0;
      final length = isMajor ? tickLengthMajor : tickLengthMinor;

      final p1 = Offset(
        center.dx + (tickRadius - length) * math.cos(angle),
        center.dy + (tickRadius - length) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + tickRadius * math.cos(angle),
        center.dy + tickRadius * math.sin(angle),
      );

      final tickPaint = Paint()
        ..color = isMajor
            ? (isLight ? AppColors.aeroTickLight : accentColor.withOpacity(0.8))
            : (isLight ? const Color(0xFFCBD5E1) : const Color(0xFF334155))
        ..strokeWidth = isMajor ? 1.5 : 0.8;

      canvas.drawLine(p1, p2, tickPaint);
    }

    // 4. 绘制陀飞轮中层双轨能量旋转弧线 (随时间缓慢旋转)
    final midRadius = maxRadius - 14;
    final rotAngle = rotationValue * 2 * math.pi;

    // 旋转图层
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotAngle);

    final energyPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          accentColor.withOpacity(0.1),
          accentColor.withOpacity(0.7),
          accentColor,
          accentColor.withOpacity(0.2),
        ],
        stops: const [0.0, 0.45, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: midRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    // 绘制 3 段非对称能量弧
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: midRadius),
      0,
      math.pi * 0.55,
      false,
      energyPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: midRadius),
      math.pi * 0.85,
      math.pi * 0.45,
      false,
      energyPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: midRadius),
      math.pi * 1.5,
      math.pi * 0.35,
      false,
      energyPaint,
    );

    // 齿轮微雕刻痕点缀
    final gearDotPaint = Paint()
      ..color = accentColor.withOpacity(isLight ? 0.6 : 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(midRadius, 0), 2.2, gearDotPaint);
    canvas.drawCircle(Offset(-midRadius, 0), 2.2, gearDotPaint);

    canvas.restore();

    // 5. 绘制内层精密圆环与核心聚光圈
    final innerRadius = midRadius - 8;
    final innerPaint = Paint()
      ..color = isLight
          ? const Color(0xFFF1F5F9).withOpacity(0.9)
          : const Color(0xFF131A27).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, innerRadius, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _ChronoDialPainter oldDelegate) =>
      oldDelegate.rotationValue != rotationValue ||
      oldDelegate.isLight != isLight ||
      oldDelegate.accentColor != accentColor;
}
