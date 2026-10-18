import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 环形 AI 额度进度仪表盘组件
class RadialGauge extends StatelessWidget {
  final double remainingPercent; // 0.0 - 100.0
  final String title;
  final String? subtitle;
  final Color? activeColor;
  final double size;

  const RadialGauge({
    super.key,
    required this.remainingPercent,
    required this.title,
    this.subtitle,
    this.activeColor,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final color = activeColor ?? _getColorByPercent(remainingPercent);
    final percentInt = remainingPercent.clamp(0.0, 100.0).round();

    final cardBg = isLight ? const Color(0xFFF1F2F4) : const Color(0xFF18181D);
    final trackColor = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);
    final titleColor = isLight ? AppColors.swissLightTextPrimary : AppColors.swissDarkTextPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6), // 瑞士硬朗 6px
        border: Border.all(
          color: isLight ? AppColors.swissLightBorder : AppColors.swissDarkBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: _GaugePainter(
                    percent: remainingPercent.clamp(0.0, 100.0) / 100.0,
                    activeColor: color,
                    trackColor: trackColor,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$percentInt',
                          style: TextStyle(
                            color: color,
                            fontSize: size * 0.28,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '%',
                          style: TextStyle(
                            color: color.withOpacity(0.8),
                            fontSize: size * 0.14,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 86,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: color.withOpacity(isLight ? 0.08 : 0.15),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: color.withOpacity(0.35),
                  width: 0.8,
                ),
              ),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getColorByPercent(double p) {
    if (p > 60) return AppColors.emerald;
    if (p > 25) return AppColors.amber;
    return AppColors.swissRedBright;
  }
}

class _GaugePainter extends CustomPainter {
  final double percent;
  final Color activeColor;
  final Color trackColor;

  _GaugePainter({
    required this.percent,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const strokeWidth = 5.5;

    // 1. 底层轨道 (微晶暗环)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (percent <= 0.001) return;

    // 2. 霓虹发光光晕层 (Blur)
    final glowPaint = Paint()
      ..color = activeColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final sweepAngle = 2 * pi * percent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    // 3. 高亮主线环
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      activePaint,
    );

    // 4. 端点发光圆珠 (Head Dot)
    final endAngle = -pi / 2 + sweepAngle;
    final dotX = center.dx + radius * cos(endAngle);
    final dotY = center.dy + radius * sin(endAngle);

    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(dotX, dotY), strokeWidth * 0.45, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
